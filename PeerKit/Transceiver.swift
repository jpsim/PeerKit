//
//  Transceiver.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum TransceiverMode {
    case Browse, Advertise, Both
}

public class Transceiver: SessionDelegate {

    var transceiverMode = TransceiverMode.Both
    let advertiser: Advertiser
    let browser: Browser

    public init(displayName: String!) {
        advertiser = Advertiser(displayName: displayName)
        browser = Browser(displayName: displayName)
        advertiser.delegate = self
        browser.delegate = self
    }

    func startTransceiving(#serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser.startAdvertising(serviceType: serviceType, discoveryInfo: discoveryInfo)
        browser.startBrowsing(serviceType)
        transceiverMode = .Both
    }

    func startAdvertising(#serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser.startAdvertising(serviceType: serviceType, discoveryInfo: discoveryInfo)
        transceiverMode = .Advertise
    }

    func startBrowsing(#serviceType: String) {
        browser.startBrowsing(serviceType)
        transceiverMode = .Browse
    }

    func sessionForPeer(peerID: MCPeerID) -> MCSession? {
        if (advertiser.mcSession.connectedPeers as [MCPeerID]).filter({ $0 == peerID }).count > 0 {
            return advertiser.mcSession
        }

        if (browser.mcSession.connectedPeers as [MCPeerID]).filter({ $0 == peerID }).count > 0 {
            return browser.mcSession
        }

        return nil
    }

    public func connecting(myPeerID: MCPeerID, toPeer peer: MCPeerID) {
        didConnecting(myPeerID, peer)
    }

    public func connected(myPeerID: MCPeerID, toPeer peer: MCPeerID) {
        didConnect(myPeerID, peer)
    }

    public func disconnected(myPeerID: MCPeerID, fromPeer peer: MCPeerID) {
        didDisconnect(myPeerID, peer)
    }

    public func receivedData(myPeerID: MCPeerID, data: NSData, fromPeer peer: MCPeerID) {
        didReceiveData(data, fromPeer: peer)
    }

    public func finishReceivingResource(myPeerID: MCPeerID, resourceName: String, fromPeer peer: MCPeerID, atURL localURL: NSURL) {
        didFinishReceivingResource(myPeerID, resourceName, fromPeer: peer, atURL: localURL)
    }
}
