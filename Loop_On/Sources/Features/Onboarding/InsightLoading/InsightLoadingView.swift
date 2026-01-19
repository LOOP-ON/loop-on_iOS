//  2.4 인사이트 생성 중 로딩 화면
//  화면 ID : onboarding_insight_loading
//
//  Created by 써니/김세은
//

import SwiftUI

struct InsightLoadingView: View {
    @StateObject private var viewModel = InsightLoadingViewModel()

    var body: some View {
        ZStack {
            Color("PrimaryColor-Varient65")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image("airplane")
                    .renderingMode(.template)
                    .foregroundStyle(Color("100"))
                    .frame(height: 104)

                Text(viewModel.message)
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                    .foregroundStyle(Color("100"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                Spacer()
            }
        }
        .onAppear {
            viewModel.startLoading()
        }
    }
}

#Preview("iPhone 15 Pro") {
    InsightLoadingView()
}

#Preview("iPhone 16 Pro Max") {
    InsightLoadingView()
}


