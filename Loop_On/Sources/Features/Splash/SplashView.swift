//  SplashView.swift
//  LOOP_ON
//  Created by 이경민 on 12/31/25.
import Foundation
import SwiftUI

struct SplashView: View {
    @Binding var isFinishedSplash: Bool
    
    var body: some View {
        ZStack {
            // 배경색(임시)
            Color(.primaryColorVarient65)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer().frame(height: 140)
                // 로고 이미지
                Image("loopOnLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.5)
                
                // 하단 텍스트
                VStack(spacing: 8) {
                    Text("3일마다 다시 떠나는 나의 여정,")
                    Text("LOOP:ON")
                }
                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.center)
                
                Spacer()
                Spacer()
            }
            .padding(.bottom, 50)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isFinishedSplash = true
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SplashView(isFinishedSplash: .constant(false))
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("iPhone 15 Pro")
            
            SplashView(isFinishedSplash: .constant(false))
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
        }
    }
}
