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
    func receivedData(myPeerID: MCPeerID, data: Data, fromPeer peer: MCPeerID)
    func finishReceivingResource(myPeerID: MCPeerID, resourceName: String, fromPeer peer: MCPeerID, atURL localURL: URL?)
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

    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .connecting:
                delegate?.connecting(myPeerID: myPeerID, toPeer: peerID)
            case .connected:
                delegate?.connected(myPeerID: myPeerID, toPeer: peerID)
            case .notConnected:
                delegate?.disconnected(myPeerID: myPeerID, fromPeer: peerID)
        }
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate?.receivedData(myPeerID: myPeerID, data: data, fromPeer: peerID)
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // unused
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // unused
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        if (error == nil) {
            delegate?.finishReceivingResource(myPeerID: myPeerID, resourceName: resourceName, fromPeer: peerID, atURL: localURL)
        }
    }
}
