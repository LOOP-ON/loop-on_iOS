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
                Image("airplane")
                    .resizable()
                    .frame(width:32, height:27)
                    .foregroundStyle(Color(.primaryColorVarient65))
                
                Text(tagline)
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AuthHeader(
        logoImageName: "Logo",
        tagline: "2박 3일 여정을 시작해볼까요?\nLOOP 모드를 켜주세요"
    )
}
