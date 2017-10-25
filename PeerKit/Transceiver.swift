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
    let session: Session
    let advertiser: Advertiser
    let browser: Browser

    public init(displayName: String!) {
        session = Session(displayName: displayName, delegate: nil)
        advertiser = Advertiser(mcSession: session.mcSession)
        browser = Browser(mcSession: session.mcSession)
        session.delegate = self
    }

    func startTransceiving(serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser.startAdvertising(serviceType: serviceType, discoveryInfo: discoveryInfo)
        browser.startBrowsing(serviceType: serviceType)
        transceiverMode = .Both
    }

    func stopTransceiving() {
        session.delegate = nil
        advertiser.stopAdvertising()
        browser.stopBrowsing()
        session.disconnect()
    }

    func startAdvertising(serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser.startAdvertising(serviceType: serviceType, discoveryInfo: discoveryInfo)
        transceiverMode = .Advertise
    }

    func startBrowsing(serviceType: String) {
        browser.startBrowsing(serviceType: serviceType)
        transceiverMode = .Browse
    }

    public func connecting(myPeerID: MCPeerID, toPeer peer: MCPeerID) {
        didConnecting(myPeerID: myPeerID, peer: peer)
    }

    public func connected(myPeerID: MCPeerID, toPeer peer: MCPeerID) {
        didConnect(myPeerID: myPeerID, peer: peer)
    }

    public func disconnected(myPeerID: MCPeerID, fromPeer peer: MCPeerID) {
        didDisconnect(myPeerID: myPeerID, peer: peer)
    }

    public func receivedData(myPeerID: MCPeerID, data: Data, fromPeer peer: MCPeerID) {
        didReceiveData(data, fromPeer: peer)
    }

    public func finishReceivingResource(myPeerID: MCPeerID, resourceName: String, fromPeer peer: MCPeerID, atURL localURL: URL?) {
        didFinishReceivingResource(myPeerID: myPeerID, resourceName: resourceName, fromPeer: peer, atURL: localURL)
    }
}
