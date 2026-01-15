//
//  DelayPopupView.swift
//  Loop_On
//
//  Created by 이경민 on 1/15/26.
//

import Foundation
import SwiftUI

struct DelayPopupView: View {
    let index: Int      // 루틴의 순서
    let title: String
    @Binding var isPresented: Bool
    
    @State private var selectedReason: String? = nil
    @State private var customReason: String = "" // 직접 입력 텍스트 저장
    @FocusState private var isTextFieldFocused: Bool // 키보드 포커스 제어
    
    let reasons = ["시간이 부족해요.", "컨디션이 좋지 않아요.", "다른 할 일이 많아요.", "너무 귀찮아요.", "직접 입력"]

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isTextFieldFocused = false // 배경 터치 시 키보드 내림
                    isPresented = false
                }

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    // 타이틀 및 루틴 정보 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("루틴 미루기")
                            .font(.system(size: 20, weight: .bold))
                        
                        HStack(spacing: 4) {
                            Text("오늘의 루틴 \(index)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color(.primaryColorVarient65))
                                .padding(.horizontal, 4)
                                .background(Color(.primaryColorVarient65).opacity(0.1))
                            
                            Text(title)
                                .font(.system(size: 15))
                        }
                    }

                    Text("루틴을 미루려는 이유가 무엇인가요?")
                        .font(.system(size: 16, weight: .bold))

                    // 사유 리스트 및 직접 입력창
                    VStack(spacing: 10) {
                        ForEach(reasons, id: \.self) { reason in
                            VStack(spacing: 10) {
                                Button(action: {
                                    selectedReason = reason
                                    if reason == "직접 입력" {
                                        isTextFieldFocused = true // 키보드 활성화
                                    } else {
                                        isTextFieldFocused = false // 다른 사유 클릭 시 키보드 내림
                                    }
                                }) {
                                    HStack {
                                        Text(reason)
                                            .font(.system(size: 14))
                                            .foregroundStyle(.black)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedReason == reason ? Color(.primaryColorVarient65) : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                
                                // "직접 입력" 선택 시 나타나는 TextField
                                if reason == "직접 입력" && selectedReason == "직접 입력" {
                                    TextField("사유를 입력해주세요.", text: $customReason)
                                        .focused($isTextFieldFocused)
                                        .font(.system(size: 14))
                                        .padding()
                                        .frame(height: 44)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.systemGray6))
                                        )
                                        .transition(.opacity) // 부드럽게 나타남
                                }
                            }
                        }
                    }
                }
                .padding(24)

                Divider()

                // 하단 버튼 섹션
                HStack(spacing: 0) {
                    Button(action: { isPresented = false }) {
                        Text("닫기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }

                    Divider().frame(width: 1, height: 56)

                    Button(action: {
                        if canSubmit {
                            // 최종 사유 결정 로직
                            let finalReason = (selectedReason == "직접 입력") ? customReason : selectedReason
                            print("미루기 사유: \(finalReason ?? "")")
                            isPresented = false
                        }
                    }) {
                        Text("미루기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(canSubmit ? Color.gray : Color.gray.opacity(0.4))
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 30)
            // 키보드가 올라올 때 팝업이 가려지지 않도록 살짝 위로 이동
            .offset(y: isTextFieldFocused ? -40 : 0)
            .animation(.spring(), value: isTextFieldFocused)
        }
    }
    
    // 미루기 버튼 활성화 조건
    private var canSubmit: Bool {
        if selectedReason == "직접 입력" {
            return !customReason.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return selectedReason != nil
    }
}
