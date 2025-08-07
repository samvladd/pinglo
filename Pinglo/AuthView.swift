//
//  AuthView.swift
//  Pinglo
//
//  Created by Pinglo Team on 8/4/25.
//

import SwiftUI
import UIKit

struct AuthView: View {
    var onContinue: (() -> Void)? = nil
    enum AuthStep { case welcome, email, signupForm, signup2FA, signinPassword }
    @State private var step: AuthStep = .welcome
    @State private var email = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var code = ""
    @State private var error: String?
    @State private var isLoading = false
    @State private var isSignUp = false
    @FocusState private var focusedField: Field?
    @StateObject private var globalAppearance = GlobalAppearance.shared
    @State private var animateSweep = false
    
    enum Field: Hashable { case email, firstName, lastName, password, confirmPassword, code }
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    globalAppearance.accentColor.opacity(0.9),
                    Color.purple.opacity(0.6),
                    Color.blue.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            // Floating mesh particles
            MeshParticles(color: globalAppearance.accentColor)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Hero
                    VStack(spacing: 10) {
                        ZStack {
                            PulsingRings(color: globalAppearance.accentColor)
                                .frame(width: 100, height: 100)
                            Image(systemName: "wave.3.right.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(globalAppearance.accentColor)
                                .shadow(color: globalAppearance.accentColor.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        Text("Pinglo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        // Animated tagline chip
                        Text("Message. Anywhere.")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.white.opacity(0.18)))
                            .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 36)
                    // Main card
                    VStack(spacing: 20) {
                    if step == .welcome {
                        VStack(spacing: 8) {
                            Text(isSignUp ? "Create your Pinglo account" : "Sign in to Pinglo")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            Text("Message anywhere. Even without internet.")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                            Text("Phones nearby create a private mesh so your chats keep moving — fast, simple, and secure.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        Button(action: { withAnimation { step = .email } }) {
                            Text(isSignUp ? "Get Started" : "Continue with Email")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(globalAppearance.accentColor)
                                .cornerRadius(12)
                        }
                            .padding(.top, 6)
                        Divider().padding(.vertical, 8)
                        VStack(spacing: 12) {
                            SignInWithAppleButton()
                            SignInWithGoogleButton()
                        }
                    } else if step == .email {
                        VStack(spacing: 16) {
                            Text("Enter your email")
                                .font(.title3)
                                .fontWeight(.medium)
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textContentType(.emailAddress)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .focused($focusedField, equals: .email)
                                .submitLabel(.done)
                            if let error = error {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            Button(action: {
                                withAnimation {
                                    if isSignUp {
                                        step = .signupForm
                                    } else {
                                        step = .signinPassword
                                    }
                                }
                            }) {
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(globalAppearance.accentColor)
                                    .cornerRadius(12)
                            }
                        }
                    } else if step == .signupForm {
                        VStack(spacing: 16) {
                            Text("Create your profile")
                                .font(.title3)
                                .fontWeight(.medium)
                            TextField("First Name", text: $firstName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .focused($focusedField, equals: .firstName)
                            TextField("Last Name", text: $lastName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .focused($focusedField, equals: .lastName)
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .focused($focusedField, equals: .password)
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .focused($focusedField, equals: .confirmPassword)
                            Button(action: { withAnimation { step = .signup2FA } }) {
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(globalAppearance.accentColor)
                                    .cornerRadius(12)
                            }
                        }
                    } else if step == .signup2FA {
                        VStack(spacing: 16) {
                            Text("Enter the 2FA code sent to your email")
                                .font(.title3)
                                .fontWeight(.medium)
                            CodeField(code: $code)
                                .focused($focusedField, equals: .code)
                            Button(action: { /* TODO: Complete sign up */ }) {
                                Text("Verify & Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(globalAppearance.accentColor)
                                    .cornerRadius(12)
                            }
                            Button("Resend code") {}
                                .font(.caption)
                                .foregroundColor(globalAppearance.accentColor)
                                .padding(.top, 4)
                        }
                    } else if step == .signinPassword {
                        VStack(spacing: 16) {
                            Text("Enter your password")
                                .font(.title3)
                                .fontWeight(.medium)
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .focused($focusedField, equals: .password)
                            Button(action: { /* TODO: Complete sign in */ }) {
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(globalAppearance.accentColor)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
                    .padding(.horizontal)
                    .animation(.easeInOut, value: step)
                    // Switch sign in/up
                    Button(action: { withAnimation { isSignUp.toggle(); step = .welcome } }) {
                        Text(isSignUp ? "Already have an account? Sign in" : "Don’t have an account? Sign up")
                            .font(.footnote)
                            .foregroundColor(globalAppearance.accentColor)
                            .padding(.vertical, 8)
                    }
                    if let onContinue = onContinue {
                        Button(action: { onContinue() }) {
                            Text("Continue as John Doe")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        }
                    }
                    Spacer(minLength: 20)
                }
            }
        }
        .onAppear { withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) { animateSweep.toggle() } }
    }
}

struct CodeField: View {
    @Binding var code: String
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<6) { i in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .frame(width: 40, height: 48)
                    Text(code.count > i ? String(code[code.index(code.startIndex, offsetBy: i)]) : "")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
        .onTapGesture { UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil) }
        .background(
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .opacity(0.01)
        )
    }
}

struct SignInWithAppleButton: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "applelogo")
                    .font(.title2)
                Text("Sign in with Apple")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .cornerRadius(12)
        }
    }
}

struct SignInWithGoogleButton: View {
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                GoogleLogoView()
                    .frame(width: 18, height: 18)
                Text("Sign in with Google")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray3), lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
    }
}

 struct GoogleLogoView: View {
     var body: some View {
         Group {
             if let uiImg = UIImage(named: "GoogleLogo") {
                 Image(uiImage: uiImg).resizable().scaledToFit()
             } else {
                 // Fallback simple G if asset missing
                 Image(systemName: "g.circle.fill").resizable().scaledToFit().foregroundColor(.blue)
             }
         }
     }
 }

struct PulsingRings: View {
    let color: Color
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.25), lineWidth: 2)
                .scaleEffect(animate ? 1.25 : 0.9)
                .opacity(animate ? 0.0 : 1.0)
            Circle()
                .stroke(color.opacity(0.35), lineWidth: 2)
                .scaleEffect(animate ? 1.5 : 1.0)
                .opacity(animate ? 0.0 : 1.0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                animate.toggle()
            }
        }
    }
}

// MARK: - Bullets
struct Bullet: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
                .font(.subheadline)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Mesh Particles Background
struct MeshParticles: View {
    let color: Color
    @State private var phases: [Particle] = (0..<14).map { _ in Particle.random }
    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                for p in phases {
                    var rect = CGRect(x: p.x * size.width, y: p.y * size.height, width: 6, height: 6)
                    rect = rect.offsetBy(dx: sin(p.speed * Date().timeIntervalSinceReferenceDate + p.seed) * 10,
                                          dy: cos(p.speed * Date().timeIntervalSinceReferenceDate + p.seed) * 10)
                    let circle = Path(ellipseIn: rect)
                    context.fill(circle, with: .color(color.opacity(0.18)))
                }
            }
        }
        .allowsHitTesting(false)
    }
    struct Particle {
        let x: CGFloat
        let y: CGFloat
        let speed: CGFloat
        let seed: CGFloat
        static var random: Particle {
            Particle(x: .random(in: 0...1), y: .random(in: 0...1), speed: .random(in: 0.2...0.8), seed: .random(in: 0...6.28))
        }
    }
}

#Preview {
    AuthView()
}