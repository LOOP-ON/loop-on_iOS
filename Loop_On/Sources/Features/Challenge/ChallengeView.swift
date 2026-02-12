//
//  ChallengeView.swift
//  Loop_On
//
//  Created by 이경민 on 1/15/26.
//

import Foundation
import SwiftUI
import UIKit

struct ChallengeView: View {
    @Environment(NavigationRouter.self) private var router
    /// 프로필 탭 시 타인뷰 오버레이로 열기 (RootTabView에서 설정 → 하단 탭바 유지)
    var onOpenOtherProfile: ((Int) -> Void)? = nil

    @SceneStorage("challenge.selectedTopTab") private var selectedTopTabRawValue: Int = ChallengeTopTab.plaza.rawValue
    @State private var selectedTopTab: ChallengeTopTab = .plaza
    @State private var hasLoadedStoredTab = false
    @StateObject private var friendsViewModel = ChallengeFriendsViewModel()
    @StateObject private var expeditionViewModel = ChallengeExpeditionViewModel()
    @State private var isShowingShareJourney = false
    /// 수정 모드로 ShareJourney 열 때 사용 (nil이면 새로 올리기)
    @State private var editChallengeId: Int? = nil
    /// 여정 광장 피드에서 삭제 팝업을 띄우기 위한 타겟 ID와 실제 삭제 실행 클로저
    @State private var deleteTargetId: Int? = nil
    @State private var deleteAction: ((Int) -> Void)? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HomeHeaderView(onSettingsTapped: {
                    router.push(.app(.settings))
                })
                .padding(.horizontal, 20)
                .padding(.top, 12)

                topTabBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                TabView(selection: $selectedTopTab) {
                    ChallengePlazaView(
                        onOpenOtherProfile: onOpenOtherProfile,
                        onRequestDelete: { id, performDelete in
                            deleteTargetId = id
                            deleteAction = performDelete
                        },
                        onEdit: { id in
                            editChallengeId = id
                            isShowingShareJourney = true
                        }
                    )
                        .tag(ChallengeTopTab.plaza)

                    ChallengeFriendsView(viewModel: friendsViewModel)
                        .tag(ChallengeTopTab.friend)

                    ChallengeExpeditionView(viewModel: expeditionViewModel)
                        .tag(ChallengeTopTab.expedition)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            if selectedTopTab == .plaza {
                Button {
                    editChallengeId = nil
                    isShowingShareJourney = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color(.primaryColorVarient65))
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, bottomPaddingAboveTabBar)
            }

        }
        .fullScreenCover(isPresented: $friendsViewModel.isShowingRequestSheet) {
            ZStack {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        friendsViewModel.closeRequestSheet()
                    }

                ChallengeFriendRequestSheet(
                    requests: friendsViewModel.friendRequests,
                    isLoadingMore: friendsViewModel.isLoadingFriendRequests,
                    onAccept: friendsViewModel.acceptRequest,
                    onReject: friendsViewModel.rejectRequest,
                    onAcceptAll: friendsViewModel.acceptAllRequests,
                    onRejectAll: friendsViewModel.rejectAllRequests,
                    onClose: friendsViewModel.closeRequestSheet,
                    onRequestRowAppear: friendsViewModel.loadMoreFriendRequestsIfNeeded
                )
                .frame(maxWidth: 320, maxHeight: 540)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
            }
            .presentationBackground(.clear)
        }
        .fullScreenCover(isPresented: $isShowingShareJourney, onDismiss: { editChallengeId = nil }) {
            ShareJourneyView(editChallengeId: editChallengeId)
        }
        .onAppear {
            if !hasLoadedStoredTab {
                selectedTopTab = ChallengeTopTab(rawValue: selectedTopTabRawValue) ?? .plaza
                hasLoadedStoredTab = true
                if selectedTopTab == .expedition {
                    expeditionViewModel.loadMyExpeditionsIfNeeded()
                }
            }
        }
        .onChange(of: selectedTopTab) { _, newValue in
            selectedTopTabRawValue = newValue.rawValue
            if newValue == .expedition {
                expeditionViewModel.loadMyExpeditionsIfNeeded()
            }
        }
        .onChange(of: selectedTopTabRawValue) { _, newValue in
            let tab = ChallengeTopTab(rawValue: newValue) ?? .plaza
            if tab != selectedTopTab {
                selectedTopTab = tab
            }
        }
        // 게시물 삭제 확인 팝업: CommonPopupView와 동일한 디자인으로 통일
        .fullScreenCover(isPresented: Binding(
            get: { deleteTargetId != nil },
            set: { if !$0 { deleteTargetId = nil; deleteAction = nil } }
        )) {
            ZStack {
                CommonPopupView(
                    isPresented: Binding(
                        get: { deleteTargetId != nil },
                        set: { if !$0 { deleteTargetId = nil; deleteAction = nil } }
                    ),
                    title: "정말로 게시물을 삭제하시겠습니까?",
                    message: "삭제 시 게시물이 영구적으로 삭제되며, 복구할 수 없습니다.",
                    leftButtonText: "취소",
                    rightButtonText: "삭제",
                    leftAction: {
                        deleteTargetId = nil
                        deleteAction = nil
                    },
                    rightAction: {
                        if let id = deleteTargetId, let action = deleteAction { action(id) }
                        deleteTargetId = nil
                        deleteAction = nil
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationBackground(.clear)
        }
    }
}

private extension ChallengeView {
    var topTabBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                ForEach(ChallengeTopTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTopTab = tab
                    } label: {
                        Text(tab.title)
                            .font(selectedTopTab == tab
                                ? LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16)
                                : LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 16)
                            )
                            .foregroundStyle(selectedTopTab == tab ? Color(.primaryColor55) : Color.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }

            GeometryReader { proxy in
                let tabWidth = proxy.size.width / CGFloat(ChallengeTopTab.allCases.count)
                Rectangle()
                    .fill(Color(.primaryColor55))
                    .frame(width: tabWidth, height: 2)
                    .offset(x: tabWidth * CGFloat(selectedTopTab.index), y: 0)
                    .animation(.easeInOut(duration: 0.2), value: selectedTopTab)
            }
            .frame(height: 2)
        }
    }

    var safeAreaBottomHeight: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.bottom ?? 0
    }

    /// 하단 탭바 높이 + safe area. '+' 버튼이 탭바에 가리지 않도록 사용
    private var bottomPaddingAboveTabBar: CGFloat {
        let tabBarContentHeight: CGFloat = 56
        return tabBarContentHeight + safeAreaBottomHeight
    }
}

private enum ChallengeTopTab: Int, CaseIterable, Hashable {
    case plaza
    case friend
    case expedition

    var title: String {
        switch self {
        case .plaza:
            return "여정 광장"
        case .friend:
            return "친구"
        case .expedition:
            return "탐험대"
        }
    }

    var index: Int { rawValue }
}

#Preview {
    ChallengeView()
        .environment(NavigationRouter())
}
