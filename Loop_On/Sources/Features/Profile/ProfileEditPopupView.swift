//
//  ProfileEditPopupView.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import SwiftUI

struct ProfileEditPopupView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel: ProfileEditViewModel
    
    init(isPresented: Binding<Bool>, initialUser: UserModel) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: ProfileEditViewModel(initialUser: initialUser))
    }
    
    var body: some View {
        ZStack {
            // 배경 오버레이 (어둡게) - 전체 화면 포함
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            // 팝업 컨텐츠
            VStack(spacing: 0) {
                // 타이틀
                Text("프로필 편집")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color("5-Text"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                
                // 입력 필드들
                VStack(spacing: 24) {
                    // 닉네임
                    nicknameField
                    
                    // 한 줄 소개
                    oneLineIntroField
                    
                    // 상태 메시지
                    statusMessageField
                    
                    // 프로필 공개
                    profileVisibilityToggle
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 0)
                
                // 구분선
                Divider()
                    .padding(.top, 24)
                
                // 하단 버튼들
                HStack(spacing: 0) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("취소")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color("StatusRed"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("100"))
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .frame(height: 56)
                    
                    Button {
                        viewModel.saveProfile()
                        isPresented = false
                    } label: {
                        Text("저장")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color("25-Text"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("100"))
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color("100"))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            .frame(width: 340, height: 540)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
    }
    
    // MARK: - Nickname Field
    private var nicknameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("닉네임")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color("5-Text"))
            
            HStack(spacing: 8) {
                TextField("", text: $viewModel.nickname)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color("5-Text"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color("background"))
                    )
                    .overlay(alignment: .trailing) {
                        // 중복확인 결과: 사용 가능 → 체크, 중복 → 엑스, 확인 중 → 로딩
                        if viewModel.duplicationCheckResult == .available {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color("StatusGreen"))
                                .padding(.trailing, 14)
                        } else if viewModel.duplicationCheckResult == .duplicated {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color("StatusRed"))
                                .padding(.trailing, 14)
                        } else if viewModel.duplicationCheckResult == .checking {
                            ProgressView()
                                .scaleEffect(0.8)
                                .padding(.trailing, 14)
                        }
                    }
                    .onChange(of: viewModel.nickname) { _, _ in
                        // 닉네임이 변경되면 중복확인 결과 초기화
                        if viewModel.duplicationCheckResult != .idle {
                            viewModel.duplicationCheckResult = .idle
                        }
                    }
                
                Button {
                    viewModel.checkNicknameDuplication()
                } label: {
                    Text("중복 확인")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(viewModel.isNicknameChanged ? Color("100") : Color("25-Text"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(viewModel.duplicationCheckResult == .available ? Color("85") : (viewModel.isNicknameChanged ? Color("PrimaryColor-Varient65") : Color("85")))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.isNicknameChanged || viewModel.duplicationCheckResult == .checking)
            }
        }
    }
    
    // MARK: - One Line Intro Field
    private var oneLineIntroField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("한 줄 소개")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color("5-Text"))
            
            HStack(spacing: 8) {
                TextField("", text: $viewModel.oneLineIntro)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color("5-Text"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color("background"))
                    )
            }
        }
    }
    
    // MARK: - Status Message Field
    private var statusMessageField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("상태 메세지")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color("5-Text"))
            
            HStack(spacing: 8) {
                TextField("", text: $viewModel.statusMessage)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color("5-Text"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color("background"))
                    )
            }
        }
    }
    
    // MARK: - Profile Visibility Toggle
    private var profileVisibilityToggle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("프로필 공개")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color("5-Text"))
            
            HStack(spacing: 8) {
                Button {
                    viewModel.isPublic = true
                } label: {
                    Text("공개")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(viewModel.isPublic ? Color("100") : Color("25-Text"))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(viewModel.isPublic ? Color("PrimaryColor-Varient65") : Color("85"))
                        )
                }
                .buttonStyle(.plain)
                
                Button {
                    viewModel.isPublic = false
                } label: {
                    Text("비공개")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(!viewModel.isPublic ? Color("100") : Color("25-Text"))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(!viewModel.isPublic ? Color("PrimaryColor-Varient65") : Color("85"))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        
        ProfileEditPopupView(
            isPresented: .constant(true),
            initialUser: UserModel(
                id: "1",
                name: "서리",
                profileImageURL: nil,
                bio: "LOOP:ON 디자이너 서리/최서정\n룸온팀 파이팅!!"
            )
        )
    }
}
