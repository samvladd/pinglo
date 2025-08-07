//
//  ConnectivityView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct ConnectivityView: View {
    @State private var bluetoothMeshEnabled = false
    @State private var wifiAssistEnabled = false
    
    var body: some View {
        List {
            Section {
                // Bluetooth Mesh
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bluetooth Mesh")
                            .font(.body)
                        Text("Enable mesh networking for enhanced connectivity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $bluetoothMeshEnabled)
                        .labelsHidden()
                }
                
                // WiFi Assist
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("WiFi Assist")
                                .font(.body)
                            Text("Coming Soon")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                        Text("Switch to WiFi to support enhanced messaging features")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $wifiAssistEnabled)
                        .labelsHidden()
                        .disabled(true)
                }
            }
        }
        .navigationTitle("Connectivity")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView {
        ConnectivityView()
    }
} 