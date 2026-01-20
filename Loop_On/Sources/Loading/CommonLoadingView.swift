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
                Spacer()
            }
        }
    }
}

#Preview{
    CommonLoadingView(
        message: "2번째 여정을 생성중입니다", lottieFileName: "Loading 51 _ Monoplane"
    )
}
