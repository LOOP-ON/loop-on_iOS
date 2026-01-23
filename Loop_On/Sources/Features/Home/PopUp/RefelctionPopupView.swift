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
    @State private var selectedImages: [UIImage] = [] // 선택된 이미지 저장용
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

                    // 입력 필드 및 사진 추가 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("3일차의 여정 기록하기")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                            Text("오늘의 루틴들을 수행하며 느낀 점, 어려웠던 점 등을 자유롭게 기록하세요.")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundStyle(Color("45-Text"))
                        }
                        
                        // 텍스트 입력창
                        TextField("예시 : ~~~", text: $reflectionText, axis: .vertical)
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .lineLimit(15, reservesSpace: true)
                            .frame(minHeight: 180)
                            .padding()
                            .focused($isTextFieldFocused)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )

                        // 이미지 + 사진 추가 버튼 영역
                        HStack(alignment: .center, spacing: 12) {
                            
                            // 선택된 이미지들 (왼쪽부터)
                            if !selectedImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 60, height: 60)
                                                    .cornerRadius(10)
                                                    .clipped()
                                                
                                                Button {
                                                    selectedImages.remove(at: index)
                                                } label: {
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
                                .clipped()
                            }
                            
                            Spacer()
                            
                            // 사진 추가 버튼 (우측)
                            Button(action: {
                                if selectedImages.count < 3 {
                                    checkPhotoLibraryPermission { granted in
                                        if granted {
                                            isShowingPicker = true
                                        } else {
                                            isShowingPermissionAlert = true
                                        }
                                    }
                                }
                            }) {
                                Text("사진 추가")
                                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .foregroundStyle(.white)
                                    .frame(width: 68, height: 30)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.primaryColorVarient65))
                                    )
                            }
                            .disabled(selectedImages.count >= 3)
                            .opacity(selectedImages.count >= 3 ? 0.5 : 1.0)
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
            PhotoPicker(images: $selectedImages, selectionLimit: 3 - selectedImages.count)
        }
        // 권한 거부 시 안내 알림
        .alert("사진 라이브러리 접근 권한이 없습니다.", isPresented: $isShowingPermissionAlert) {
            Button("설정으로 이동") {
                // 설정 앱의 내 앱 페이지로 바로 이동
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("여정 기록에 사진을 추가하려면 설정에서 사진 접근 권한을 '모든 사진' 또는 '선택한 사진'으로 허용해주세요.")
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
