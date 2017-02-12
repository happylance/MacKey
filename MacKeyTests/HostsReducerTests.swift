//
//  HostsReducerTests.swift
//  MacKey
//
//  Created by Liu Liang on 11/02/2017.
//  Copyright © 2017 Liu Liang. All rights reserved.
//

import XCTest
@testable import MacKey

class HostsReducerTests: XCTestCase {
    
    let initialState = HostsState(
        allHosts: [
            "h1": HostInfo(alias: "h1", host: "host1", user: "u1", password: "p1", requireTouchID: true),
            "h2": HostInfo(alias: "h2", host: "host2", user: "u2", password: "p2", requireTouchID: true)
        ],
        latestHostAlias: "h1")
    
    func testAddHost() {
        let newHost = HostInfo(alias: "h3", host: "host3", user: "u3", password: "p3", requireTouchID: true)
        let newState = HostsReducer.handleAction(AddHost(host:newHost), state: initialState)
        
        XCTAssertEqual(newState.allHosts.count, 3)
        XCTAssertEqual(newState.allHosts["h3"], newHost)
    }
    
    func testRemoveHost() {
        let hostToRemove = HostInfo(alias: "h1", host: "host1", user: "u1", password: "p1", requireTouchID: true)
        let newState = HostsReducer.handleAction(RemoveHost(host:hostToRemove), state: initialState)
        
        XCTAssertEqual(newState.allHosts.count, 1)
        XCTAssertEqual(newState.allHosts["h1"], nil)
        XCTAssertEqual(newState.latestHostAlias, "")
    }
    
    func testSelectHost() {
        let hostToSelect = HostInfo(alias: "h2", host: "host2", user: "u2", password: "p2", requireTouchID: true)
        let newState = HostsReducer.handleAction(SelectHost(host:hostToSelect), state: initialState)
        
        XCTAssertEqual(newState.allHosts.count, 2)
        XCTAssertEqual(newState.latestHostAlias, "h2")
    }
    
    func testUpdateHostAliasChanged() {
        let oldHost = HostInfo(alias: "h1", host: "host1", user: "u1", password: "p1", requireTouchID: true)
        let newHost = HostInfo(alias: "h3", host: "host3", user: "u3", password: "p3", requireTouchID: true)
        let newState = HostsReducer.handleAction(UpdateHost(oldHost:oldHost, newHost:newHost), state: initialState)
        
        XCTAssertEqual(newState.allHosts.count, 2)
        XCTAssertEqual(newState.allHosts["h3"], newHost)
        XCTAssertEqual(newState.allHosts["h1"], nil)
        XCTAssertEqual(newState.latestHostAlias, "h3")
    }

    
    func testUpdateHostAliasChangedNotSelected() {
        let oldHost = HostInfo(alias: "h2", host: "host2", user: "u2", password: "p2", requireTouchID: true)
        let newHost = HostInfo(alias: "h3", host: "host3", user: "u3", password: "p3", requireTouchID: true)
        let newState = HostsReducer.handleAction(UpdateHost(oldHost:oldHost, newHost:newHost), state: initialState)
        
        XCTAssertEqual(newState.allHosts.count, 2)
        XCTAssertEqual(newState.allHosts["h3"], newHost)
        XCTAssertEqual(newState.allHosts["h2"], nil)
        XCTAssertEqual(newState.latestHostAlias, "h1")
    }
    
    func testUpdateHostAliasNotChanged() {
        let oldHost = HostInfo(alias: "h1", host: "host1", user: "u1", password: "p1", requireTouchID: true)
        let newHost = HostInfo(alias: "h1", host: "host3", user: "u3", password: "p3", requireTouchID: true)
        let newState = HostsReducer.handleAction(UpdateHost(oldHost:oldHost, newHost:newHost), state: initialState)
        
        XCTAssertEqual(newState.allHosts.count, 2)
        XCTAssertEqual(newState.allHosts["h1"], newHost)
        XCTAssertEqual(newState.latestHostAlias, "h1")
    }
}

