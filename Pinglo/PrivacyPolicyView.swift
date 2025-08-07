//
//  PrivacyPolicyView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Group {
                    Text("Last updated: August 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("1. Information We Collect")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("We collect information you provide directly to us, such as when you create an account, send messages, or use our discovery features. This may include your name, email address, username, and profile information.")
                    
                    Text("2. How We Use Your Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("We use the information we collect to provide, maintain, and improve our services, communicate with you, and ensure the security of our platform.")
                    
                    Text("3. Information Sharing")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy or as required by law.")
                    
                    Text("4. Data Security")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("We implement appropriate security measures to protect your personal information. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.")
                    
                    Text("5. Data Retention")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("We retain your information for as long as necessary to provide our services and comply with legal obligations. You may request deletion of your data at any time.")
                    
                    Text("6. Your Rights")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("You have the right to access, correct, or delete your personal information. You may also opt out of certain communications and control your privacy settings within the app.")
                    
                    Text("7. Third-Party Services")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Our service may integrate with third-party services. These services have their own privacy policies, and we are not responsible for their practices.")
                    
                    Text("8. Children's Privacy")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Our service is not intended for children under 13. We do not knowingly collect personal information from children under 13.")
                    
                    Text("9. International Transfers")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place for such transfers.")
                    
                    Text("10. Changes to This Policy")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("We may update this privacy policy from time to time. We will notify you of any material changes by posting the new policy in the app.")
                    
                    Text("11. Disclaimer")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("PINGLO MAKES NO WARRANTIES REGARDING THE SECURITY OR PRIVACY OF YOUR INFORMATION. USE OF THIS SERVICE IS AT YOUR OWN RISK. PINGLO SHALL NOT BE LIABLE FOR ANY UNAUTHORIZED ACCESS TO OR USE OF YOUR PERSONAL INFORMATION.")
                    
                    Text("12. Contact Us")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("If you have questions about this privacy policy, please contact us at appsproutorg@gmail.com")
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView()
    }
} 