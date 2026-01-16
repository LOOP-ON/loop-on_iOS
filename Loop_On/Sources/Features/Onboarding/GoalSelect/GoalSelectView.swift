
//  2.2 온보딩 목표 선택 화면
//  화면 ID : onboarding_goal_select
//
//  Created by 써니/김세은
//

import SwiftUI

struct GoalSelectView: View {
    @StateObject private var viewModel = GoalSelectViewModel()
    
    var body: some View {
        ZStack {
            Color("100")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 60)
                
                // 질문
                questionTextView
                    .padding(.top, 44)
                
                goalSelectionView
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                
                Spacer()
                
                nextButtonView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
            }
        }
    }
    
    // MARK: - 1. 헤더/컨텍스트 영역
    private var headerView: some View {
        VStack(spacing: 20) {
            // 여행 가방 아이콘
            Image(systemName: "suitcase.fill")
                .font(.system(size: 60, weight: .regular))
                .foregroundStyle(Color("PrimaryColor-Varient65"))
            
            // 타이틀
            VStack(spacing: 4) {
                Text("여정을 떠나기 전 CHECKLIST")
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                    .foregroundStyle(Color("25-Text"))
                
                Text("(1/2)")
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                    .foregroundStyle(Color("25-Text"))
            }
            
        }
    }
    
    private var questionTextView: some View {
        (
            Text(viewModel.nickname)
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 20)) +
            Text(" 님의 목표는 무엇인가요?")
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 20))
        )
        .foregroundStyle(Color("5-Text"))
    }
    
    // MARK: - 2. 선택 영역 (목표 카드)
    private var goalSelectionView: some View {
        VStack(spacing: 16) {
            ForEach(GoalType.allCases, id: \.self) { goal in
                GoalCardView(
                    goal: goal,
                    isSelected: viewModel.selectedGoal == goal,
                    onTap: {
                        viewModel.selectGoal(goal)
                    }
                )
            }
        }
    }
    
    // MARK: - 3. 하단 CTA 영역
    private var nextButtonView: some View {
        Button {
            viewModel.proceedToNext()
        } label: {
            Text("다음으로")
                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(Color("100"))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .background(viewModel.canProceed ? Color("PrimaryColor-Varient65") : Color("65"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(
            color: viewModel.canProceed ? .black.opacity(0.2) : .clear,
            radius: viewModel.canProceed ? 4 : 0,
            x: viewModel.canProceed ? 1 : 0,
            y: viewModel.canProceed ? 2 : 0
        )
        .disabled(!viewModel.canProceed)
        .opacity(viewModel.canProceed ? 1 : 0.6)
    }
}

// MARK: - Goal Card View
private struct GoalCardView: View {
    let goal: GoalType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 이모지
                Text(goal.emoji)
                    .font(.system(size: 32))
                    .frame(width: 40, height: 40)
                
                // 텍스트
                Text(goal.title)
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(isSelected ? Color("PrimaryColor-Varient65") : Color("25-Text"))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 48)
            .background(Color("100"))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? Color("PrimaryColor-Varient65") : Color("65"),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(
                color: isSelected ? .black.opacity(0.2) : .clear,
                radius: isSelected ? 4 : 0,
                x: isSelected ? 1 : 0,
                y: isSelected ? 2 : 0
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("iPhone 15 Pro") {
    GoalSelectView()
}
