//
//  Advertiser.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Advertiser: Session, MCNearbyServiceAdvertiserDelegate {
    private var advertiser: MCNearbyServiceAdvertiser?

    func startAdvertising(#serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopAdvertising() {
        advertiser?.delegate = nil
        advertiser?.stopAdvertisingPeer()
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        var runningTime = -timeStarted.timeIntervalSinceNow
        var peerRunningTime = NSTimeInterval()
        context.getBytes(&peerRunningTime)
        let isPeerOlder = (peerRunningTime > runningTime)
        invitationHandler(isPeerOlder, mcSession)
        if isPeerOlder {
            stopAdvertising()
        }
    }
}
