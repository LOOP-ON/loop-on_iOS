//  2.1 온보딩 - 여정 시작 안내 화면
//  화면 ID :
//
//  Created by 써니/김세은
//

import SwiftUI

struct IntroView: View {
    var body: some View {
        ZStack {
            Color("100")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 60)
                
                Spacer()
                
                mainMessageView
                
                Spacer()
                
                startJourneyButtonView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
            }
        }
    }
    
    // MARK: - 1. 헤더/컨텍스트 영역 - LOOP:ON 로고
    private var headerView: some View {
        VStack(spacing: 0) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .accessibilityLabel("LOOP:ON 로고")
        }
    }
    
    // MARK: - 2. 메인 메시지 영역
    private var mainMessageView: some View {
        VStack(spacing: 32) {
            // 원형 그래픽 (연한 빨간색-주황색 배경, 어두운 빨간색-주황색 비행기 아이콘)
            ZStack {
                Circle()
                    .fill(Color("PrimaryColor-Varient95"))
                    .frame(width: 200, height: 200)
                
                Image("airplane")
                    .renderingMode(.template)
                    .foregroundStyle(Color("PrimaryColor-Varient65"))
            }
            
            // 메인 메시지
            Text("여정을 떠나기 전 \n 몇 가지 질문이 있어요")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(Color("5-Text"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - 3. CTA 버튼 영역
    private var startJourneyButtonView: some View {
        Button {
            // TODO: 온보딩 목표 선택 화면으로 이동
        } label: {
            Text("여정 시작하기")
                .foregroundStyle(Color("100"))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .background(Color("PrimaryColor-Varient65"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 4, x: 1, y: 2)
    }
}

#Preview("iPhone 15 Pro") {
    IntroView()
}


#Preview("iPhone 16 Pro Max") {
    IntroView()
}
