//
//  AuthView.swift
//  Pinglo
//
//  Created by Pinglo Team on 8/4/25.
//

import SwiftUI

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
    
    enum Field: Hashable { case email, firstName, lastName, password, confirmPassword, code }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.5), Color(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                // Logo or pulse
                VStack(spacing: 8) {
                    Image(systemName: "wave.3.right.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
                    Text("Pinglo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                Spacer(minLength: 10)
                // Main card
                VStack(spacing: 24) {
                    if step == .welcome {
                        Text(isSignUp ? "Create your Pinglo account" : "Sign in to Pinglo")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        Button(action: { withAnimation { step = .email } }) {
                            Text(isSignUp ? "Get Started" : "Continue with Email")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.top)
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
                                    .background(Color.blue)
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
                                    .background(Color.blue)
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
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            Button("Resend code") {}
                                .font(.caption)
                                .foregroundColor(.blue)
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
                                    .background(Color.blue)
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
                Spacer()
                // Switch sign in/up
                Button(action: { withAnimation { isSignUp.toggle(); step = .welcome } }) {
                    Text(isSignUp ? "Already have an account? Sign in" : "Don’t have an account? Sign up")
                        .font(.footnote)
                        .foregroundColor(.blue)
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
            }
        }
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
            HStack {
                Image(uiImage: UIImage(named: "google-logo") ?? UIImage())
                    .resizable()
                    .frame(width: 22, height: 22)
                Text("Sign in with Google")
                    .font(.headline)
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

#Preview {
    AuthView()
}