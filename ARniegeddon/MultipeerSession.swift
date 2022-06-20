//
//  MultipeerSession.swift
//  ARniegeddon
//
//  Created by Anatolich Mixaill on 20.06.2022.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import MultipeerConnectivity
class MultipeerSession: NSObject {
  
  private var session: MCSession!
  private let myPeerID = MCPeerID(displayName: UIDevice.current.name)

  var connectedPeers: [MCPeerID] {
      return session.connectedPeers
  }
//  Send collaboration data to others
  func sendToPeers(_ data: Data, reliably: Bool, peers: [MCPeerID]) {
    guard !peers.isEmpty else { return }
    do {
      try session.send(data, toPeers: peers, with: reliably ? .reliable : .unreliable)
    } catch {
      print("error sending data to peers \(peers): \(error.localizedDescription)")
    }
  }
  
  func sendToAllPeers(_ data: Data, reliably: Bool) {
      sendToPeers(data, reliably: reliably, peers: connectedPeers)
  }
  
}
