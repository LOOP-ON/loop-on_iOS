//
//  DelayPopupView.swift
//  Loop_On
//
//  Created by 이경민 on 1/15/26.
//

import SwiftUI

struct DelayPopupView: View {
    let index: Int
    let title: String
    @Binding var isPresented: Bool
    
    // ViewModel 주입
    @StateObject private var viewModel = DelayPopupViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isTextFieldFocused = false
                    isPresented = false
                }

            VStack(alignment: .leading, spacing: 0) {
                contentSection
                
                Divider()

                buttonSection
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 30)
            .offset(y: isTextFieldFocused ? -40 : 0)
            .animation(.spring(), value: isTextFieldFocused)
        }
    }
    
    // MARK: - UI Components
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("루틴 미루기")
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                
                HStack(spacing: 4) {
                    Text("오늘의 루틴 \(index)")
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                        .foregroundStyle(Color(.primaryColorVarient65))
                        .padding(.horizontal, 4)
                        .background(Color(.primaryColorVarient65).opacity(0.1))
                    
                    Text(title)
                        .font(.system(size: 15))
                }
            }

            Text("루틴을 미루려는 이유가 무엇인가요?")
                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))

            reasonList
        }
        .padding(24)
    }
    
    private var reasonList: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.reasons) { reason in
                VStack(spacing: 10) {
                    Button(action: {
                        viewModel.selectedReason = reason
                        isTextFieldFocused = reason.isCustomInput
                    }) {
                        HStack {
                            Text(reason.text)
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                // 선택 여부에 따라 텍스트 색상 변경 (선택 시 검정, 미선택 시 회색)
                                .foregroundStyle(viewModel.selectedReason == reason ? .black : .gray)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.selectedReason == reason ? Color(.primaryColorVarient65) : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    }
                    
                    if reason.isCustomInput && viewModel.selectedReason?.isCustomInput == true {
                        TextField("사유를 입력해주세요.", text: $viewModel.customReason)
                            .focused($isTextFieldFocused)
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .padding()
                            .frame(height: 44)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
                            .transition(.opacity)
                    }
                }
            }
        }
    }

    private var buttonSection: some View {
        HStack(spacing: 0) {
            Button(action: { isPresented = false }) {
                Text("닫기")
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, minHeight: 56)
            }

            Divider().frame(width: 1, height: 56)

            Button(action: {
                viewModel.submitDelay(routineIndex: index) { success in
                    if success { isPresented = false }
                }
            }) {
                if viewModel.isSubmitting {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 56)
                } else {
                    Text("미루기")
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .foregroundStyle(viewModel.canSubmit ? Color(.primaryColorVarient65) : Color.gray.opacity(0.4))
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
            }
            .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
        }
    }
}

#Preview {
    // 프리뷰 내에서 Binding 상태를 제어하기 위한 Wrapper 뷰
    struct DelayPopupPreviewContainer: View {
        @State private var isPresented = true
        
        var body: some View {
            ZStack {
                // 실제 배경이 되는 뷰
                VStack {
                    Text("LOOP_ON 메인 화면")
                        .font(.largeTitle)
                        .padding()
                    
                    Button("팝업 다시 열기") {
                        isPresented = true
                    }
                }
                .blur(radius: isPresented ? 3 : 0) // 팝업 시 배경 블러 처리 예시
                
                // 팝업 뷰
                if isPresented {
                    DelayPopupView(
                        index: 1,
                        title: "매일 아침 스트레칭 하기",
                        isPresented: $isPresented
                    )
                }
            }
            .animation(.easeInOut, value: isPresented)
        }
    }
    
    return DelayPopupPreviewContainer()
}
