//
//  SignUpHeaderSection.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI

struct SignUpHeaderSection: View {
    var body: some View {
        VStack(spacing: 14) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 54)

            Image("airplane")
                .resizable()
                .frame(width:32, height:27)

            Text("회원가입을 하고\n나만의 여정을 떠나볼까요?")
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 18))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

#Preview("SignUpHeaderSection") {
    SignUpHeaderSection()
        .padding()
        .background(Color("background"))
}

