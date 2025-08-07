//
//  PrivacyView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct PrivacyView: View {
    @State private var stealthModeEnabled = false
    @State private var autoDeleteOption = "Never"
    @State private var showingPanicWipeAlert = false
    @State private var showingPanicWipeConfirmation = false
    
    let autoDeleteOptions = ["24 hours", "7 days", "30 days", "Never"]
    
    var body: some View {
        List {
            Section {
                // Stealth Mode
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Stealth Mode")
                            .font(.body)
                        Text("Hide yourself from new discover scans")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $stealthModeEnabled)
                        .labelsHidden()
                }
                
                // Auto-delete Messages
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Auto-delete Messages")
                            .font(.body)
                        Text("Automatically delete messages after a period")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Menu {
                        ForEach(autoDeleteOptions, id: \.self) { option in
                            Button(option) {
                                autoDeleteOption = option
                            }
                        }
                    } label: {
                        HStack {
                            Text(autoDeleteOption)
                                .foregroundColor(.blue)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Section {
                // Panic Wipe
                Button(action: {
                    showingPanicWipeAlert = true
                }) {
                    HStack {
                        Spacer()
                        Text("Panic Wipe")
                            .font(.body)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .alert("Panic Wipe", isPresented: $showingPanicWipeAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Wipe All Data", role: .destructive) {
                        showingPanicWipeConfirmation = true
                    }
                } message: {
                    Text("Are you sure? This will permanently delete all your data and cannot be undone.")
                }
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingPanicWipeConfirmation) {
            PanicWipeConfirmationView()
        }
    }
}

struct PanicWipeConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding = false
    @State private var showingWipeProgress = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Warning Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            // Title
            Text("Emergency Data Wipe")
                .font(.title2)
                .fontWeight(.bold)
            
            // Description
            Text("Hold the red button for 3 seconds to permanently delete all your data. This action cannot be undone.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Hold to confirm button
            VStack(spacing: 16) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: holdProgress)
                        .stroke(Color.red, lineWidth: 8)
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    // Hold button
                    Circle()
                        .fill(Color.red)
                        .frame(width: 100, height: 100)
                        .scaleEffect(isHolding ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isHolding)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !isHolding {
                                        startHold()
                                    }
                                }
                                .onEnded { _ in
                                    if !showingWipeProgress {
                                        cancelHold()
                                    }
                                }
                        )
                    
                    // Icon
                    Image(systemName: "trash.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                if showingWipeProgress {
                    Text("Wiping all data...")
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                } else {
                    Text("Hold to confirm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Cancel button
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.blue)
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func startHold() {
        isHolding = true
        
        // Start haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Animate progress over 3 seconds
        withAnimation(.linear(duration: 3.0)) {
            holdProgress = 1.0
        }
        
        // Complete after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if isHolding {
                completeWipe()
            }
        }
    }
    
    private func cancelHold() {
        isHolding = false
        
        // Reset progress
        withAnimation(.easeOut(duration: 0.3)) {
            holdProgress = 0
        }
    }
    
    private func completeWipe() {
        showingWipeProgress = true
        
        // Heavy haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Success haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Simulate wipe process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dismiss()
        }
    }
}

#Preview {
    NavigationView {
        PrivacyView()
    }
} 