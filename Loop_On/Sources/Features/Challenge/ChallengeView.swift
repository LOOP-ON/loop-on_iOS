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
        .fullScreenCover(isPresented: $isShowingShareJourney, onDismiss: {
            editChallengeId = nil
            // 여정 광장에서 연 공유 흐름은 닫힌 뒤에도 여정 광장 탭 유지
            selectedTopTab = .plaza
            selectedTopTabRawValue = ChallengeTopTab.plaza.rawValue
        }) {
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
        // 게시물 삭제 확인 팝업: 전체 화면(세이프에어리어·탭바 포함) 덮고, 팝업은 화면 정중앙
        .fullScreenCover(isPresented: Binding(
            get: { deleteTargetId != nil },
            set: { if !$0 { deleteTargetId = nil; deleteAction = nil } }
        )) {
            deleteConfirmFullScreen
        }
    }
}

// MARK: - Delete Confirm Popup (Challenge Tab) — 전체 화면 + 정중앙

extension ChallengeView {
    private var deleteConfirmFullScreen: some View {
        ZStack {
            // 회색 오버레이: 노치·상태바·하단 탭바·홈인디케이터까지 전부 덮음
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    deleteTargetId = nil
                    deleteAction = nil
                }

            if let targetId = deleteTargetId {
                // 팝업 카드: 전체 화면 기준 가로·세로 정중앙
                VStack(spacing: 16) {
                    Text("정말로 게시물을 삭제하시겠습니까?")
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 17))
                        .foregroundStyle(Color("5-Text"))

                    Text("삭제 시 게시물이 영구적으로 삭제되며, 복구할 수 없으며, 다시 되돌릴 수 없습니다.")
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color("45-Text"))
                        .multilineTextAlignment(.center)

                    // 텍스트와 버튼 영역을 시각적으로 구분하는 상단 구분선 (카드 양끝까지)
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                        .padding(.top, 4)
                        // VStack 전체에 걸린 .padding(.horizontal, 24)를 상쇄해서 팝업 안쪽 양끝까지 라인 확장
                        .padding(.horizontal, -24)

                    HStack(spacing: 8) {
                        Button {
                            deleteTargetId = nil
                            deleteAction = nil
                        } label: {
                            Text("취소")
                                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundStyle(Color("5-Text"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color("100"))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }

                        Button {
                            if let action = deleteAction {
                                action(targetId)
                            }
                            deleteTargetId = nil
                            deleteAction = nil
                        } label: {
                            Text("삭제")
                                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(red: 0.95, green: 0.45, blue: 0.35))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                )
                .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationBackground(.clear)
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
