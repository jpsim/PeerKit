//
//  PeerKitTests.swift
//  PeerKitTests
//
//  Created by JP Simard on 11/6/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif
import XCTest
import PeerKit

class PeerKitTests: XCTestCase {
    func testDeviceName() {
        XCTAssert(count(myName) > 0, "Device name should be a non-empty string")
    }
}
