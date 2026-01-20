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
    @Binding var isPresented: Bool
    @Binding var isCompleted: Bool
    @State private var reflectionText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedImage: UIImage? = nil // 선택된 이미지 저장용
    @State private var isShowingPicker = false // 앨범 표시 여부
    @State private var isShowingPermissionAlert = false // 권한 거부 알림용

    var body: some View {
        ZStack {
            // 배경 어둡게 처리
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isTextFieldFocused = false
                }

            // 중앙 팝업 카드
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 24) {
                    // 1. 타이틀 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("오늘의 여정 기록")
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                        
                        // 하이라이트가 들어간 목표 텍스트 (이미지 참고)
                        HStack(spacing: 4) {
                            Text("오늘의 목표")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .foregroundStyle(Color(.primaryColorVarient65))
                                .padding(.horizontal, 4)
                                .background(Color(.primaryColorVarient65).opacity(0.1))
                            
                            Text("새해 맞이 건강한 생활 만들기")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                        }
                    }

                    // 2. 입력 필드 및 사진 추가 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("3일차의 여정 기록하기")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                            Text("오늘의 루틴들을 수행하며 느낀 점, 어려웠던 점 등을 자유롭게 기록하세요.")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .foregroundStyle(Color("45-Text"))
                        }
                        
                        // 텍스트 입력창
                        TextField("예시 : ~~~", text: $reflectionText, axis: .vertical)
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .lineLimit(selectedImage == nil ? 10 : 7, reservesSpace: true) // 이미지 있으면 높이 줄임
                            .padding()
                            .focused($isTextFieldFocused)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        
                        if let image = selectedImage{
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(10)
                                    .clipped()
                                
                                // 사진 삭제 버튼
                                Button(action: { selectedImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.gray)
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .padding(5)
                            }
                        }
                        
                        // 사진 추가 버튼
                        HStack {
                            Spacer()
                            Button(action: {
                                checkPhotoLibraryPermission { granted in
                                    if granted {
                                        isShowingPicker = true
                                    } else {
                                        isShowingPermissionAlert = true
                                    }
                                }
                            }) {
                                Text("사진 추가")
                                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundStyle(Color.white)
                                    .frame(width: 68, height: 30)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.primaryColorVarient65))
                                    )
                            }
                        }
                    }
                }
                .padding(24)

                Divider()

                // 하단 버튼 섹션 (닫기 / 저장)
                HStack(spacing: 0) {
                    Button(action: { isPresented = false }) {
                        Text("닫기")
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }

                    Divider().frame(width: 1, height: 56)

                    Button(action: {
                        if !reflectionText.isEmpty {
                            isCompleted = true
                            isPresented = false
                        }
                    }) {
                        Text("저장")
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                            .foregroundStyle(reflectionText.isEmpty ? Color.gray.opacity(0.4) : Color(.primaryColorVarient65))
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }
                    .disabled(reflectionText.isEmpty)
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 30)
            .offset(y: isTextFieldFocused ? -100 : 0) // 키보드 가림 방지
        }
        .sheet(isPresented: $isShowingPicker) {
            PhotoPicker(image: $selectedImage) // 앨범 시트 호출
        }
        // 권한 거부 시 안내 알림
        .alert("사진 라이브러리 접근 권한이 없습니다.", isPresented: $isShowingPermissionAlert) {
            Button("확인") { }
        } message: {
            Text("설정에서 사진 접근 권한을 허용해주세요.")
        }
        .animation(.spring(), value: isTextFieldFocused)
    }
    
    // 갤러리 접근 권한 요청
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }
}


// MARK: - Preview
#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        ReflectionPopupView(isPresented: .constant(true), isCompleted: .constant(false))
    }
}
