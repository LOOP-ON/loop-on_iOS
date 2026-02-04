//
//  PersonalProfileView.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import SwiftUI

struct PersonalProfileView: View {
    @Environment(NavigationRouter.self) private var router
    @StateObject private var viewModel = PersonalProfileViewModel()
    @State private var isShowingProfileEdit = false
    @State private var isShowingShareJourney = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 헤더 (HomeView와 동일: Logo + passport + 설정)
                HomeHeaderView(onSettingsTapped: {
                    router.push(.app(.settings))
                })
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                if let user = viewModel.user {
                    // 프로필 섹션 (고정)
                    VStack(spacing: 0) {
                        profileSection(user: user)
                            .padding(.top, 24)
                            .padding(.horizontal, 36)
                        
                        // 디바이더 (별도 패딩 적용)
                        Divider()
                            .background(Color(.separator))
                            .padding(.horizontal, 28)
                            .padding(.top, 24)
                    }
                    
                    // 콘텐츠 그리드 (스크롤 가능)
                    ScrollView {
                        contentGrid
                            .padding(.top, 20)
                            .padding(.horizontal, 36)
                            .padding(.bottom, 100) // 탭바 공간 확보
                    }
                    .scrollIndicators(.hidden)
                } else if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 100)
                } else {
                    Text("프로필을 불러올 수 없습니다")
                        .font(.system(size: 16))
                        .foregroundStyle(Color("45-Text"))
                        .padding(.top, 100)
                }
            }
            .safeAreaPadding(.top, 1)
        }
        .fullScreenCover(isPresented: $isShowingShareJourney) {
            ShareJourneyView()
        }
        .fullScreenCover(isPresented: $isShowingProfileEdit) {
            if let user = viewModel.user {
                ProfileEditPopupView(
                    isPresented: $isShowingProfileEdit,
                    initialUser: user
                )
                .presentationBackground(.clear)
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
            }
        }
    }
    
    // MARK: - Profile Section
    private func profileSection(user: UserModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 20) {
                // 프로필 이미지 (왼쪽)
                ZStack(alignment: .bottomTrailing) {
                    if let imageURL = user.profileImageURL, !imageURL.isEmpty {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color("85"))
                        }
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color("85"))
                            .frame(width: 110, height: 110)
                    }
                    
                    // 카메라 아이콘
                    Button {
                        // TODO: 프로필 이미지 편집
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 36, height: 36)
                            
                            Image("photo_camera")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .offset(x: -2, y: -2)
                }
                
                // 사용자 정보 (오른쪽)
                VStack(alignment: .leading, spacing: 6) {
                    Text(user.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color("5-Text"))
                    
                    if !user.bio.isEmpty {
                        // bio를 줄바꿈으로 분리
                        let bioLines = user.bio.components(separatedBy: "\n")
                        ForEach(Array(bioLines.enumerated()), id: \.offset) { _, line in
                            if !line.isEmpty {
                                Text(line)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundStyle(Color("45-Text"))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
            }
            
            // 액션 버튼들
            HStack(alignment: .center, spacing: 20) {
                ProfileActionButton(title: "프로필 편집") {
                    isShowingProfileEdit = true
                }
                ProfileActionButton(title: "챌린지 추가") {
                    isShowingShareJourney = true
                }
            }
            .padding(.top, 24)
        }
    }
    
    // MARK: - Content Grid
    private var contentGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(0..<viewModel.challengeImages.count, id: \.self) { index in
                challengeImageCell(imageURL: viewModel.challengeImages[index])
            }
        }
    }
    
    private func challengeImageCell(imageURL: String?) -> some View {
        ZStack {
            // 흰색 배경 카드 (검은 테두리 제거, 외곽 그림자 추가)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color("100"))
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            
            if let imageURL = imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    // 산 아이콘 플레이스홀더
                    Image(systemName: "mountain.2")
                        .font(.system(size: 24))
                        .foregroundStyle(Color("5-Text"))
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                // 산 아이콘 플레이스홀더
                Image(systemName: "mountain.2")
                    .font(.system(size: 24))
                    .foregroundStyle(Color("5-Text"))
            }
        }
    }
}

// MARK: - ProfileActionButton
private struct ProfileActionButton: View {
    let title: String
    let action: () -> Void
    
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color("100"))
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.95, green: 0.45, blue: 0.35))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

#Preview {
    PersonalProfileView()
        .environment(NavigationRouter())
        .environment(SessionStore())
}
