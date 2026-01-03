//
//  ConnectionManager.swift
//  SwiftStick
//
//  Created by SwiftStick AI on 03/01/2026.
//

import Foundation
import MultipeerConnectivity
import SwiftUI
import Combine

class ConnectionManager: NSObject, ObservableObject {
    private let serviceType = "rc-swiftstick"
    private let myPeerId = MCPeerID(displayName: ProcessInfo.processInfo.hostName)
    private var session: MCSession
    
    // Advertisers/Browsers
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var foundPeers: [MCPeerID] = [] // For iOS to show list
    @Published var isConnected = false
    @Published var connectionState: MCSessionState = .notConnected
    
    // Callback for received input (Mac side mainly)
    var onInputReceived: ((GamePacket) -> Void)?
    
    override init() {
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        self.session.delegate = self
        
        start()
    }
    
    deinit {
        stop()
    }
    
    func start() {
        #if os(macOS)
        // Mac acts as the Host/Receiver
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceAdvertiser?.delegate = self
        self.serviceAdvertiser?.startAdvertisingPeer()
        #else
        // iOS acts as the Client/Sender
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        self.serviceBrowser?.delegate = self
        self.serviceBrowser?.startBrowsingForPeers()
        #endif
    }
    
    func stop() {
        serviceAdvertiser?.stopAdvertisingPeer()
        serviceBrowser?.stopBrowsingForPeers()
        session.disconnect()
    }
    
    // MARK: - Sender (iOS)
    
    func invitePeer(_ peerID: MCPeerID) {
        // Invite the found Mac
        serviceBrowser?.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func sendInput(_ packet: GamePacket) {
        guard !session.connectedPeers.isEmpty else { return }
        
        do {
            let data = try JSONEncoder().encode(packet)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending data: \(error.localizedDescription)")
        }
    }
}

// MARK: - MCSessionDelegate
extension ConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectionState = state
            self.connectedPeers = session.connectedPeers
            self.isConnected = (state == .connected)
            
            // Notification Logic (Mac specific) could go here or observed in view
            #if os(macOS)
            if state == .connected {
                // Post notification or callback
                print("Mac: New peer connected: \(peerID.displayName)")
            }
            #endif
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Decode and handle input
        do {
            let packet = try JSONDecoder().decode(GamePacket.self, from: data)
            DispatchQueue.main.async {
                self.onInputReceived?(packet)
            }
        } catch {
            print("Failed to decode packet: \(error)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate (Mac)
extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept for frictionless experience
        // Or could prompt. For MVP, we auto-accept.
        invitationHandler(true, self.session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate (iOS)
extension ConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.foundPeers.contains(peerID) {
                self.foundPeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.foundPeers.removeAll { $0 == peerID }
        }
    }
}
