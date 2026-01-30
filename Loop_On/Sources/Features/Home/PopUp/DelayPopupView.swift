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
    var onDelaySuccess: ((String) -> Void)?
    
    // 모드 제어를 위한 프로퍼티 추가
    var isReadOnly: Bool = false // 사유 확인 모드 여부
    @State private var isEditMode: Bool = false // 수정 모드 전환 상태
    
    // ViewModel 주입
    @StateObject private var viewModel = DelayPopupViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    // 초기 사유가 있으면 확인
    var initialReason: String? = nil
    
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
        .onAppear {
            if isReadOnly, let reason = initialReason, !reason.isEmpty {
                // 미루기 보기(읽기 전용) 모드일 때만 기존 사유 세팅
                viewModel.setupInitialReason(reason)
            } else {
                // 처음 미루기를 누른 경우 모든 상태 초기화
                viewModel.selectedReason = nil
                viewModel.customReason = ""
                isEditMode = false // 수정 모드도 해제
            }
        }
    }
    
    // MARK: - UI Components
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                // 모드에 따라 타이틀 변경
                Text(isEditMode ? "미룬 루틴 수정하기" : (isReadOnly ? "미룬 루틴" : "루틴 미루기"))
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
                .disabled(isReadOnly && !isEditMode)
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
            
            Button(action: {
                isTextFieldFocused = false
                isPresented = false // API 요청 없이 창만 닫음
            }) {
                Text(isEditMode || isReadOnly ? "취소" : "닫기")
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(isEditMode || isReadOnly ? Color(.primaryColorVarient65) : .red)
                    .frame(maxWidth: .infinity, minHeight: 56)
            }

            Divider().frame(width: 1, height: 56)

//            Button(action: {
//                viewModel.submitDelay(routineIndex: index) { success in
//                    if success {
//                        onDelaySuccess?()
//                        isPresented = false
//                    }
//                }
//            }) {
//                if viewModel.isSubmitting {
//                    ProgressView()
//                        .frame(maxWidth: .infinity, minHeight: 56)
//                } else {
//                    Text("미루기")
//                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
//                        .foregroundStyle(viewModel.canSubmit ? Color(.primaryColorVarient65) : Color.gray.opacity(0.4))
//                        .frame(maxWidth: .infinity, minHeight: 56)
//                }
//            }
//            .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
            Button(action: {
                if isReadOnly && !isEditMode {
                    isEditMode = true // 수정 모드로 진입
                } else {
                    viewModel.submitDelay(routineIndex: index) { success in
                        if success {
                            DispatchQueue.main.async {
                                // 팝업에서 선택/입력된 최종 사유를 부모 뷰로 전달
                                onDelaySuccess?(viewModel.finalReason)
                                isPresented = false
                            }
                        }
                    }
                }
            }) {
                Text(isEditMode ? "저장" : (isReadOnly ? "수정하기" : "미루기"))
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundStyle(viewModel.canSubmit ? Color(.primaryColorVarient65) : Color.gray.opacity(0.4))
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .disabled(!viewModel.canSubmit && isEditMode)
        }
    }
}

#Preview {
    struct DelayPopupPreviewContainer: View {
        @State private var isPresented = true
        @State private var mockRoutine = RoutineModel(
            id: 1, title: "매일 아침 스트레칭 하기",
            time: "08:00 알림 예정",
            isCompleted: false,
            isDelayed: false,
            delayReason: "컨디션이 좋지 않아요"
        )
        
        var body: some View {
            // 프리뷰에서 실제 HomeView와 유사한 환경 제공
            NavigationStack {
                VStack {
                    RoutineCardView(
                        routine: mockRoutine,
                        onConfirm: {},
                        onDelay: { isPresented = true },
                        onViewDelay: {}
                    )
                    Spacer()
                }
                .padding()
                .navigationTitle("프리뷰 테스트")
                // 팝업 시뮬레이션
                .overlay {
                    if isPresented {
                        DelayPopupView(
                            index: 1,
                            title: mockRoutine.title,
                            isPresented: $isPresented,
                            onDelaySuccess: { reason in
                                mockRoutine.isDelayed = true
                                mockRoutine.delayReason = reason // 받은 사유를 모델에 저장
                                mockRoutine.time = "00:00 알림 완료"
                            }
                        )
                    }
                }
            }
        }
    }
    return DelayPopupPreviewContainer()
}
