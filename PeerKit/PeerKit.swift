//
//  PeerKit.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/5/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// MARK: Type Aliases

public typealias PeerBlock = ((_ myPeerID: MCPeerID, _ peerID: MCPeerID) -> Void)
public typealias EventBlock = ((_ peerID: MCPeerID, _ event: String, _ object: AnyObject?) -> Void)
public typealias ObjectBlock = ((_ peerID: MCPeerID, _ object: AnyObject?) -> Void)
public typealias ResourceBlock = ((_ myPeerID: MCPeerID, _ resourceName: String, _ peer: MCPeerID, _ localURL: URL?) -> Void)

// MARK: Event Blocks

public var onConnecting: PeerBlock?
public var onConnect: PeerBlock?
public var onDisconnect: PeerBlock?
public var onEvent: EventBlock?
public var onEventObject: ObjectBlock?
public var onFinishReceivingResource: ResourceBlock?
public var eventBlocks = [String: ObjectBlock]()

// MARK: PeerKit Globals

#if os(iOS)
import UIKit
public let myName = UIDevice.current.name
#else
public let myName = Host.current().localizedName ?? ""
#endif

public var transceiver = Transceiver(displayName: myName)
public var session: MCSession?

// MARK: Event Handling

func didConnecting(myPeerID: MCPeerID, peer: MCPeerID) {
    if let onConnecting = onConnecting {
        DispatchQueue.main.async {
            onConnecting(myPeerID, peer)
        }
    }
}

func didConnect(myPeerID: MCPeerID, peer: MCPeerID) {
    if session == nil {
        session = transceiver.session.mcSession
    }
    if let onConnect = onConnect {
        DispatchQueue.main.async {
            onConnect(myPeerID, peer)
        }
    }
}

func didDisconnect(myPeerID: MCPeerID, peer: MCPeerID) {
    if let onDisconnect = onDisconnect {
        DispatchQueue.main.async {
            onDisconnect(myPeerID, peer)
        }
    }
}

func didReceiveData(_ data: Data, fromPeer peer: MCPeerID) {
    if let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: AnyObject],
        let event = dict["event"] as? String,
        let object = dict["object"] {
            DispatchQueue.main.async {
                if let onEvent = onEvent {
                    onEvent(peer, event, object)
                }
                if let eventBlock = eventBlocks[event] {
                    eventBlock(peer, object)
                }
            }
    }
}

func didFinishReceivingResource(myPeerID: MCPeerID, resourceName: String, fromPeer peer: MCPeerID, atURL localURL: URL?) {
    if let onFinishReceivingResource = onFinishReceivingResource {
        DispatchQueue.main.async {
            onFinishReceivingResource(myPeerID, resourceName, peer, localURL)
        }
    }
}

// MARK: Advertise/Browse

public func transceive(serviceType: String, discoveryInfo: [String: String]? = nil) {
    transceiver.startTransceiving(serviceType: serviceType, discoveryInfo: discoveryInfo)
}

public func advertise(serviceType: String, discoveryInfo: [String: String]? = nil) {
    transceiver.startAdvertising(serviceType: serviceType, discoveryInfo: discoveryInfo)
}

public func browse(serviceType: String) {
    transceiver.startBrowsing(serviceType: serviceType)
}

public func stopTransceiving() {
    transceiver.stopTransceiving()
    session = nil
}

// MARK: Events

public func sendEvent(_ event: String, object: AnyObject? = nil, toPeers peers: [MCPeerID]? = session?.connectedPeers) {
    guard let peers = peers, !peers.isEmpty else {
        return
    }

    var rootObject: [String: AnyObject] = ["event": event as AnyObject]

    if let object: AnyObject = object {
        rootObject["object"] = object
    }

    let data = NSKeyedArchiver.archivedData(withRootObject: rootObject)

    do {
        try session?.send(data, toPeers: peers, with: .reliable)
    } catch _ {
    }
}

public func sendResourceAtURL(_ resourceURL: URL,
                   withName resourceName: String,
  toPeers peers: [MCPeerID]? = session?.connectedPeers,
  withCompletionHandler completionHandler: ((Error?) -> Void)?) -> [Progress?]? {

    if let session = session {
        return peers?.map { peerID in
            return session.sendResource(at: resourceURL, withName: resourceName, toPeer: peerID, withCompletionHandler: completionHandler)
        }
    }
    return nil
}
