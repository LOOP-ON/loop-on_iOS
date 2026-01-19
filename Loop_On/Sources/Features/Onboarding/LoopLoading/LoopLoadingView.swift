//  2.6 루프 생성 중 로딩 화면
//  화면 ID : onboarding_loop_loading
//
//  Created by 써니/김세은
//

import SwiftUI

struct LoopLoadingView: View {
    @StateObject private var viewModel = LoopLoadingViewModel()

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
    LoopLoadingView()
}

#Preview("iPhone 16 Pro Max") {
    LoopLoadingView()
}


