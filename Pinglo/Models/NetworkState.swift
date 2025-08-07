//
//  NetworkState.swift
//  Pinglo
//
//  Created by Pinglo Team on 8/4/25.
//

import SwiftUI

enum NetworkState {
    case connected
    case disconnected
    case connecting
    case error(String)
    
    var icon: String {
        switch self {
        case .connected: return "wifi"
        case .disconnected: return "wifi.slash"
        case .connecting: return "wifi.exclamationmark"
        case .error: return "exclamationmark.triangle"
        }
    }
    
    var color: Color {
        switch self {
        case .connected: return .green
        case .disconnected: return .gray
        case .connecting: return .orange
        case .error: return .red
        }
    }
    
    var description: String {
        switch self {
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .error(let message): return message
        }
    }
}

class NetworkStateManager: ObservableObject {
    static let shared = NetworkStateManager()
    
    @Published var state: NetworkState = .disconnected
    @Published var connectedDevices: Int = 0
    
    private init() {}
    
    func updateState(_ newState: NetworkState) {
        withAnimation(.easeInOut(duration: 0.3)) {
            state = newState
        }
    }
}
