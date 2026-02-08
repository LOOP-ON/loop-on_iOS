//  2.4 인사이트 선택 화면
//  화면 ID : onboarding_insight_select
//
//  Created by 써니/김세은
//

import SwiftUI

struct InsightSelectView: View {
    @StateObject private var viewModel: InsightSelectViewModel
    @Environment(NavigationRouter.self) private var router
    @Environment(SessionStore.self) private var session

    init(goalText: String, category: String, insights: [String]) {
        _viewModel = StateObject(
            wrappedValue: InsightSelectViewModel(
                goalText: goalText,
                selectedCategory: category,
                insights: insights
            )
        )
    }

    var body: some View {
        ZStack {
            Color("100")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                    .padding(.top, 60)

                contentView
                    .padding(.top, 44)

                Spacer()

                createLoopButtonView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
            }
        }
    }

    // MARK: - 1. 헤더/컨텍스트 영역
    private var headerView: some View {
        VStack(spacing: 20) {
            Image(systemName: "suitcase.fill")
                .font(.system(size: 60, weight: .regular))
                .foregroundStyle(Color("PrimaryColor-Varient65"))

            VStack(spacing: 4) {
                Text("여정을 떠날 계획을 세워볼까요?")
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                    .foregroundStyle(Color("25-Text"))

//                Text("(2/2)")
//                    .font(.system(size: 16, weight: .regular))
//                    .foregroundStyle(Color("25-Text"))
            }
        }
    }

    // MARK: - 2. 인사이트 선택/Tip 영역
    private var contentView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("\(viewModel.goalTitle) 을(를) 목표로 하는\n다른 사람들은 주로 이런 것들을 해요")
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(Color("5-Text"))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(spacing: 12) {
                ForEach(viewModel.insights) { item in
                    InsightCardView(
                        title: item.title,
                        isSelected: viewModel.selected.contains(item),
                        onTap: { viewModel.toggle(item) }
                    )
                }
            }
            .padding(.horizontal, 20)

            tipView
                .padding(.horizontal, 20)
        }
    }

    private var tipView: some View {
        HStack(spacing: 10) {
            Text("Tip")
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color("100"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color("PrimaryColor55"))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text("원하는 인사이트를 선택하면 루프 생성에 도움이 돼요!")
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color("5-Text"))

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 3. 하단 CTA 영역
    private var createLoopButtonView: some View {
        Button {
            // 인사이트 선택 결과로 루프 생성 흐름 시작
            viewModel.createLoop()
            session.completeOnboarding()
            router.reset()
        } label: {
            Text("루프 생성하기")
                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(Color("100"))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .background(viewModel.canCreateLoop ? Color("PrimaryColor-Varient65") : Color("65"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(
            color: viewModel.canCreateLoop ? .black.opacity(0.2) : .clear,
            radius: viewModel.canCreateLoop ? 4 : 0,
            x: viewModel.canCreateLoop ? 1 : 0,
            y: viewModel.canCreateLoop ? 2 : 0
        )
        .disabled(!viewModel.canCreateLoop)
        .opacity(viewModel.canCreateLoop ? 1 : 0.6)
    }
}

// MARK: - Insight Card
private struct InsightCardView: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(isSelected ? Color("5-Text") : Color("45-Text"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(minHeight: 40)
            .background(Color("100"))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? Color("PrimaryColor-Varient65") : Color("65"),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview("iPhone 15 Pro") {
    InsightSelectView(goalText: "건강한 생활 만들기", category: "ROUTINE",
                      insights: ["아침 공복에 물 마시기", "10분 스트레칭"])
        .environment(NavigationRouter())
        .environment(SessionStore())
}

#Preview("iPhone 16 Pro Max") {
    InsightSelectView(goalText: "역량 강화 목표", category: "SKILL",
                      insights: ["매일 코딩 1시간", "기술 블로그 작성"])
        .environment(NavigationRouter())
        .environment(SessionStore())
}

