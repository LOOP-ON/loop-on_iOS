//
//  AuthHeader.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI

struct AuthHeader: View {
    let logoImageName: String
    let tagline: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(logoImageName)
                .resizable()
                .scaledToFit()
                .frame(height: 54)
                .accessibilityLabel("앱 로고")
            
            VStack(spacing: 10) {
                Image(systemName: "airplane")
                    .font(.system(size: 22, weight: .semibold))
                
                Text(tagline)
                    .font(.system(size: 17, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview{
    AuthView()
}
