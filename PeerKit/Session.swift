//
//  Session.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public protocol SessionDelegate {
    func connecting(myPeerID: MCPeerID, toPeer peer: MCPeerID)
    func connected(myPeerID: MCPeerID, toPeer peer: MCPeerID)
    func disconnected(myPeerID: MCPeerID, fromPeer peer: MCPeerID)
    func receivedData(myPeerID: MCPeerID, data: NSData, fromPeer peer: MCPeerID)
    func finishReceivingResource(myPeerID: MCPeerID, resourceName: String, fromPeer peer: MCPeerID, atURL localURL: NSURL)
}

public class Session: NSObject, MCSessionDelegate {
    public private(set) var myPeerID: MCPeerID
    var delegate: SessionDelegate?
    public private(set) var mcSession: MCSession

    public init(displayName: String, delegate: SessionDelegate? = nil) {
        myPeerID = MCPeerID(displayName: displayName)
        self.delegate = delegate
        mcSession = MCSession(peer: myPeerID)
        super.init()
        mcSession.delegate = self
    }

    public func disconnect() {
        self.delegate = nil
        mcSession.delegate = nil
        mcSession.disconnect()
    }

    // MARK: MCSessionDelegate

    public func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch state {
            case .Connecting:
                delegate?.connecting(myPeerID, toPeer: peerID)
            case .Connected:
                delegate?.connected(myPeerID, toPeer: peerID)
            case .NotConnected:
                delegate?.disconnected(myPeerID, fromPeer: peerID)
        }
    }

    public func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        delegate?.receivedData(myPeerID, data: data, fromPeer: peerID)
    }

    public func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        // unused
    }

    public func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        // unused
    }

    public func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        if (error == nil) {
            delegate?.finishReceivingResource(myPeerID, resourceName: resourceName, fromPeer: peerID, atURL: localURL)
        }
    }
}
