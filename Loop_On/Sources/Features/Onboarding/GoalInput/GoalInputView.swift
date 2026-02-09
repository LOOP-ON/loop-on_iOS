//  2.3 목표 입력 화면
//  화면 ID : onboarding_goal_input
//
//  Created by 써니/김세은
//

import SwiftUI

struct GoalInputView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(SessionStore.self) private var session
    @StateObject private var viewModel: GoalInputViewModel
    @FocusState private var isFieldFocused: Bool

    init(category: String) {
        _viewModel = StateObject(wrappedValue: GoalInputViewModel(category: category))
    }

    var body: some View {
        ZStack {
            Color("100")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                    .padding(.top, 60)

                questionTextView
                    .padding(.top, 44)

                goalInputField
                    .padding(.top, 28)
                    .padding(.horizontal, 20)

                Spacer()

                nextButtonView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
            }
        }
        .onAppear {
            // 화면이 나타날 때 세션의 닉네임을 ViewModel에 동기화
            viewModel.updateNickname(session.currentUserNickname)
            
            // 만약 닉네임이 비어있다면 한 번 더 조회를 요청할 수 있습니다.
            if session.currentUserNickname.isEmpty {
                session.fetchUserProfile()
            }
        }
        // 세션 정보가 업데이트되면 ViewModel도 자동으로 업데이트되도록 설정
        .onChange(of: session.currentUserNickname) { _, newValue in
            viewModel.updateNickname(newValue)
        }
        .onTapGesture {
            isFieldFocused = false
        }
        .alert("안내", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - 1. 상단 영역 (Progress / Context)
    private var headerView: some View {
        VStack(spacing: 20) {
            Image(systemName: "suitcase.fill")
                .font(.system(size: 60, weight: .regular))
                .foregroundStyle(Color("PrimaryColor-Varient65"))

            VStack(spacing: 4) {
                Text("여정을 떠나기 전 CHECKLIST")
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                    .foregroundStyle(Color("25-Text"))

                Text("(2/2)")
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                    .foregroundStyle(Color("25-Text"))
            }
        }
    }

    // MARK: - 2. 질문 영역
    private var questionTextView: some View {
        (
            Text(viewModel.nickname)
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 20)) +
            Text(" 님의 목표는 무엇인가요?")
                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
        )
        .foregroundStyle(Color("5-Text"))
    }

    // MARK: - 3. 목표 입력 영역
    private var goalInputField: some View {
        TextField(
            "",
            text: $viewModel.goalText,
            prompt: Text(viewModel.placeholder)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color("45-Text"))
        )
        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
        .foregroundStyle(Color("5-Text"))
        .lineLimit(1)
        .textFieldStyle(.plain)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .submitLabel(.done)
        .focused($isFieldFocused)
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color("100"))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color("65"), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onChange(of: viewModel.goalText) { _, newValue in
            viewModel.updateGoalText(newValue)
        }
    }

    // MARK: - 4. 하단 CTA 영역
    private var nextButtonView: some View {
        Button {
            // 목표 입력 -> 목표 생성 API 호출
            viewModel.proceedToNextStep { success in
                if success {
                    let trimmedGoal = viewModel.goalText.trimmingCharacters(in: .whitespacesAndNewlines)
                    // 모든 API 성공 시 다음 화면으로 이동
                    router.push(.app(.insightSelect(
                        goalText: trimmedGoal,
                        category: viewModel.category,
                        insights: viewModel.recommendedInsights,
                        journeyId: viewModel.journeyId ?? 0
                    )))
                }
            }
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

#Preview("iPhone 15 Pro") {
    GoalInputView(category: "SKILL")
        .environment(NavigationRouter())
        .environment(SessionStore())
}

#Preview("iPhone 16 Pro Max") {
    GoalInputView(category: "ROUTINE")
        .environment(NavigationRouter())
        .environment(SessionStore())
}


