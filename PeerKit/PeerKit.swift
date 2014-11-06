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

public typealias PeerBlock = ((peerID: MCPeerID) -> Void)
public typealias EventBlock = ((peerID: MCPeerID, event: String, object: AnyObject?) -> Void)
public typealias ObjectBlock = ((peerID: MCPeerID, object: AnyObject?) -> Void)

// MARK: Event Blocks

public var onConnect: PeerBlock?
public var onDisconnect: PeerBlock?
public var onEvent: EventBlock?
public var onEventObject: ObjectBlock?
public var eventBlocks = [String: ObjectBlock]()

// MARK: PeerKit Globals

let myName = UIDevice.currentDevice().name
private let transceiver = Transceiver()
public var session: MCSession?

// MARK: Event Handling

func didConnect(peer: MCPeerID) {
    if session == nil {
        session = transceiver.sessionForPeer(peer)
    }
    if let onConnect = onConnect {
        dispatch_async(dispatch_get_main_queue()) {
            onConnect(peerID: peer)
        }
    }
}

func didDisconnect(peer: MCPeerID) {
    if let onDisconnect = onDisconnect {
        dispatch_async(dispatch_get_main_queue()) {
            onDisconnect(peerID: peer)
        }
    }
}

func didReceiveData(data: NSData, fromPeer peer: MCPeerID) {
    let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [String: AnyObject]
    let event = dict["event"] as String
    let object: AnyObject? = dict["object"]
    dispatch_async(dispatch_get_main_queue()) {
        if let onEvent = onEvent {
            onEvent(peerID: peer, event: event, object: object)
        }
        if let eventBlock = eventBlocks[event] {
            eventBlock(peerID: peer, object: object)
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

// MARK: Events

public func sendEvent(event: String, object: AnyObject? = nil, toPeers peers: [MCPeerID]? = session?.connectedPeers as [MCPeerID]?) {
    if peers == nil {
        return
    }
    var rootObject: [String: AnyObject] = ["event": event]
    if object != nil {
        rootObject["object"] = object!
    }
    let data = NSKeyedArchiver.archivedDataWithRootObject(rootObject)
    session?.sendData(data, toPeers: peers, withMode: .Reliable, error: nil)
}
