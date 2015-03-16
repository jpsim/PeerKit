//
//  Advertiser.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Advertiser: NSObject, MCNearbyServiceAdvertiserDelegate {

    let mcSession: MCSession

    init(mcSession: MCSession) {
        self.mcSession = mcSession
        super.init()
    }

    private var advertiser: MCNearbyServiceAdvertiser?

    func startAdvertising(#serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser = MCNearbyServiceAdvertiser(peer: mcSession.myPeerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopAdvertising() {
        advertiser?.delegate = nil
        advertiser?.stopAdvertisingPeer()
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData?, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        let accept = mcSession.myPeerID.hashValue > peerID.hashValue
        invitationHandler(accept, mcSession)
        if accept {
            stopAdvertising()
        }
    }
}
