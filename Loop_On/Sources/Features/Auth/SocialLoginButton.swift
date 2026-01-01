//
//  SocialLoginSection.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI

struct SocialLoginButton: View {
    enum Style {
        case kakao
        case google
        
        var background: Color {
            switch self {
            case .kakao: return Color(red: 0.98, green: 0.90, blue: 0.27)
            case .google: return Color(.systemBackground)
            }
        }
        
        var foreground: Color {
            switch self {
            case .kakao: return .black
            case .google: return .primary
            }
        }
        
        var borderColor: Color {
            switch self {
            case .kakao: return .clear
            case .google: return Color(.separator)
            }
        }
    }
    
    enum Icon {
        case system(name: String)
        case asset(name: String)
    }
    
    let title: String
    let style: Style
    let icon: Icon
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Spacer()
                iconView
                    .frame(width: 22, height: 22)
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(style.foreground)
        .background(style.background)
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(style.borderColor, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .system(let name):
            Image(systemName: name)
                .resizable()
                .scaledToFit()
        case .asset(let name):
            Image(name)
                .resizable()
                .scaledToFit()
        }
    }
}


#Preview("SocialLoginButton - All") {
    VStack(spacing: 12) {
        SocialLoginButton(
            title: "카카오 계정으로 로그인",
            style: .kakao,
            icon: .system(name: "message.fill"),
            action: { print("Kakao tapped") }
        )

        SocialLoginButton(
            title: "구글 계정으로 로그인",
            style: .google,
            icon: .asset(name: "googleLogo"),
            action: { print("Google tapped") }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

