
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
                
                Spacer()
                
                goalSelectionView
                    .padding(.horizontal, 20)
                
                Spacer()
                
                nextButtonView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
            }
        }
    }
    
    // MARK: - 1. 헤더/컨텍스트 영역
    private var headerView: some View {
        VStack(spacing: 16) {
            // 여행 가방 아이콘
            Image(systemName: "suitcase.fill")
                .font(.system(size: 60, weight: .regular))
                .foregroundStyle(Color("PrimaryColor-Varient65"))
            
            // 타이틀
            VStack(spacing: 4) {
                Text("여정을 떠나기 전 CHECKLIST")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("25-Text"))
                
                Text("(1/2)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("25-Text"))
            }
            
            // 질문
            Text("\(viewModel.nickname)님의 목표는 무엇인가요?")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color("5-Text"))
                .padding(.top, 4)
        }
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
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color("100"))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .background(viewModel.canProceed ? Color("PrimaryColor-Varient65") : Color("65"))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(isSelected ? Color("PrimaryColor-Varient65") : Color("25-Text"))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
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
    GoalSelectView()
}
