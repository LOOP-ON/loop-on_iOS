//
//  PersonalProfileView.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import SwiftUI

struct PersonalProfileView: View {
    /// true: 내 프로필, false: 타인 프로필
    let isOwnProfile: Bool
    /// 타인 프로필을 오버레이로 띄울 때 닫기 콜백 (설정 시 뒤로가기가 이걸 호출)
    var onClose: (() -> Void)? = nil

    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PersonalProfileViewModel()
    @State private var isShowingProfileEdit = false
    @State private var isShowingShareJourney = false
    /// 그리드에서 탭한 썸네일 인덱스 → 피드 상세 화면에서 해당 피드가 최상단에 오도록
    @State private var feedDetailSelectedIndex: Int? = nil

    init(isOwnProfile: Bool = true, onClose: (() -> Void)? = nil) {
        self.isOwnProfile = isOwnProfile
        self.onClose = onClose
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 내 프로필: 기존 홈 헤더 (Logo + 설정)
                // 타인 프로필: 기존 로고 자리에 뒤로가기 + Logo 조합
                if isOwnProfile {
                    HomeHeaderView(onSettingsTapped: {
                        router.push(.app(.settings))
                    })
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                } else {
                    // 다른 화면과 동일: 로고가 시작하는 지점(leading 20)에 뒤로가기 화살표
                    HStack(alignment: .center, spacing: 0) {
                        Button {
                            if let onClose = onClose {
                                onClose()
                            } else {
                                dismiss()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color("5-Text"))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 164, height: 40)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
                
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
        .fullScreenCover(isPresented: Binding(
            get: { feedDetailSelectedIndex != nil },
            set: { if !$0 { feedDetailSelectedIndex = nil } }
        )) {
            if let index = feedDetailSelectedIndex, index < viewModel.myChallengeItems.count {
                PersonalFeedDetailView(
                    items: viewModel.myChallengeItems,
                    selectedIndex: index,
                    onClose: { feedDetailSelectedIndex = nil }
                )
            }
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
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                Image(systemName: "person.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.white)
                            }
                        }
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                            Image(systemName: "person.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.white)
                        }
                        .frame(width: 110, height: 110)
                    }
                    
                    // 카메라 아이콘 (내 프로필에서만)
                    if isOwnProfile {
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
            if isOwnProfile {
                // 내 프로필: 프로필 편집 / 챌린지 추가 (두 개 버튼)
                HStack(alignment: .center, spacing: 8) {
                    ProfileActionButton(title: "프로필 편집") {
                        isShowingProfileEdit = true
                    }
                    ProfileActionButton(title: "챌린지 추가") {
                        isShowingShareJourney = true
                    }
                }
                .padding(.top, 24)
            } else {
                // 타인 프로필: 한 줄짜리 \"친구 신청\" 버튼
                ProfileActionButton(title: "친구 신청") {
                    // TODO: 친구 신청 API 연결
                }
                .padding(.top, 24)
            }
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
                Button {
                    feedDetailSelectedIndex = index
                } label: {
                    challengeImageCell(imageURL: viewModel.challengeImages[index])
                }
                .buttonStyle(.plain)
                .onAppear {
                    viewModel.loadMoreChallengesIfNeeded(currentIndex: index)
                }
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
