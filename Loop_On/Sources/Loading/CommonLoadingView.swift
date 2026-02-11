//
//  LoadingView.swift
//  Loop_On
//
//  Created by 이경민 on 1/20/26.
//

import Foundation
import SwiftUI

struct CommonLoadingView: View {
    let message: String
    let lottieFileName: String
    @State private var contentOpacity = 0.0 // 내부 요소 전용 투명도
    
    var body: some View {
        ZStack {
            Color(.primaryColorVarient65)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                LottieView(filename:lottieFileName)
                    .frame(width: 250, height: 250)
                
                Text(message)
                    .foregroundStyle(Color.white)
                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 22))
                    .padding(.bottom, 100)
                    .opacity(contentOpacity) // 텍스트만 살짝 늦게 나타나게
                Spacer()
            }
        }
        .onAppear {
            // 로딩 화면이 뜨고 나서 내부 텍스트를 슥 나타나게
            withAnimation(.easeIn(duration: 0.8)) {
                contentOpacity = 1.0
            }
        }
    }
}

#Preview{
    CommonLoadingView(
        message: "2번째 여정을 생성중입니다", lottieFileName: "TriPriend"
    )
}
