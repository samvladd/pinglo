//
//  TermsView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Group {
                    Text("Last updated: August 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("By downloading, installing, or using the Pinglo application, you agree to be bound by these Terms of Service. If you do not agree to these terms, do not use the application.")
                    
                    Text("2. Use of Service")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Pinglo provides a messaging and discovery platform. You agree to use the service only for lawful purposes and in accordance with these terms.")
                    
                    Text("3. User Content")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("You retain ownership of content you create, but grant Pinglo a worldwide, non-exclusive license to use, store, and display your content in connection with the service.")
                    
                    Text("4. Privacy and Data")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Your privacy is important. Please review our Privacy Policy to understand how we collect, use, and protect your information.")
                    
                    Text("5. Disclaimers and Limitations")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("THE SERVICE IS PROVIDED 'AS IS' WITHOUT WARRANTIES OF ANY KIND. PINGLO DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.")
                    
                    Text("6. Limitation of Liability")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("IN NO EVENT SHALL PINGLO, ITS DIRECTORS, OFFICERS, EMPLOYEES, OR AGENTS BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING BUT NOT LIMITED TO LOSS OF PROFITS, DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, RESULTING FROM YOUR USE OF THE SERVICE.")
                    
                    Text("7. Indemnification")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("You agree to indemnify and hold harmless Pinglo from any claims, damages, or expenses arising from your use of the service or violation of these terms.")
                    
                    Text("8. Termination")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Pinglo may terminate or suspend your access to the service at any time, with or without cause, with or without notice.")
                    
                    Text("9. Changes to Terms")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Pinglo reserves the right to modify these terms at any time. Continued use of the service after changes constitutes acceptance of the new terms.")
                    
                    Text("10. Governing Law")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("These terms shall be governed by and construed in accordance with the laws of the jurisdiction in which Pinglo operates, without regard to conflict of law principles.")
                    
                    Text("11. Contact Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("For questions about these terms, please contact us at appsproutorg@gmail.com")
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView {
        TermsView()
    }
} 