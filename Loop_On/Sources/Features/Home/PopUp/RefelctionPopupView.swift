//
//  RefelctionPopupView.swift
//  Loop_On
//
//  Created by 이경민 on 1/19/26.
//

import Foundation
import SwiftUI
import Photos

struct ReflectionPopupView: View {
    @ObservedObject var viewModel: ReflectionViewModel
    @Binding var isPresented: Bool
    var onSaved: (() -> Void)? = nil
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var isShowingPicker = false
    @State private var isShowingPermissionAlert = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isTextFieldFocused = false }

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 24) {
                    // 타이틀 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("오늘의 여정 기록")
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                        
                        HStack(spacing: 4) {
                            Text("오늘의 목표")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .foregroundStyle(Color(.primaryColorVarient65))
                                .padding(.horizontal, 4)
                                .background(Color(.primaryColorVarient65).opacity(0.1))
                            
                            Text(viewModel.goalTitle)
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                        }
                    }

                    // 입력 필드 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            // 현재 일차 데이터 반영
                            Text("\(viewModel.currentDay)일차의 여정 기록하기")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                            Text("오늘의 루틴들을 수행하며 느낀 점 등을 자유롭게 기록하세요.")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundStyle(Color("45-Text"))
                        }
                        
                        TextField("오늘의 여정은 어떠셨나요?", text: $viewModel.reflectionText, axis: .vertical)
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .lineLimit(10, reservesSpace: true)
                            .frame(minHeight: 150)
                            .padding()
                            .focused($isTextFieldFocused)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))

                        // 이미지 선택 영역
                        imageSelectionHStack
                    }
                }
                .padding(24)

                Divider()

                // 하단 버튼
                footerButtons
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 30)
            .offset(y: isTextFieldFocused ? -100 : 0)
        }
        .sheet(isPresented: $isShowingPicker) {
            PhotoPicker(images: $viewModel.selectedImages, selectionLimit: 3 - viewModel.selectedImages.count)
        }
        .alert(
            "저장 실패",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("확인", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했어요.")
        }
        .animation(.spring(), value: isTextFieldFocused)
    }
}

// MARK: - Subviews 분리
private extension ReflectionPopupView {
    var imageSelectionHStack: some View {
        HStack(alignment: .center, spacing: 12) {
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(10)
                                    .clipped()
                                
                                Button { viewModel.selectedImages.remove(at: index) } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.gray)
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .padding(4)
                            }
                        }
                    }
                }
                .frame(height: 60)
            }
            
            Spacer()
            
            Button(action: { isShowingPicker = true }) {
                Text("사진 추가")
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                    .foregroundStyle(.white)
                    .frame(width: 68, height: 30)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.primaryColorVarient65)))
            }
            .disabled(viewModel.selectedImages.count >= 3)
        }
    }

    var footerButtons: some View {
        HStack(spacing: 0) {
            Button(action: { if !viewModel.isSaving { isPresented = false } }) {
                Text("닫기").foregroundStyle(.red).frame(maxWidth: .infinity, minHeight: 56)
            }
            .disabled(viewModel.isSaving)

            Divider().frame(width: 1, height: 56)

            Button(action: {
                viewModel.saveReflection { success in
                    if success {
                        onSaved?()
                        isPresented = false
                    }
                }
            }) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Text("저장")
                        .foregroundStyle(viewModel.canSave ? Color(.primaryColorVarient65) : .gray.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .disabled(!viewModel.canSave)
        }
    }
}
// MARK: - Preview

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        
        // 임시 뷰모델 생성 (더미 데이터 주입)
        let mockViewModel = ReflectionViewModel(
            loopId: 1,
            currentDay: 3,
            goalTitle: "건강한 생활 만들기",
            progressId: 1
        )
        
        // 새로운 생성자 형식에 맞춰 호출
        ReflectionPopupView(
            viewModel: mockViewModel,
            isPresented: .constant(true),
            onSaved: nil
        )
    }
}
