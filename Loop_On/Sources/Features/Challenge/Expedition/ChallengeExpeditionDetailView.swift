//
//  ChallengeExpeditionDetailView.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import SwiftUI

struct ChallengeExpeditionDetailView: View {
    let expeditionName: String
    private let networkManager = DefaultNetworkManager<ChallengeAPI>()
    @State private var cards: [ChallengeCard] = ChallengeCard.samplePlaza
    @State private var isShowingMemberList = false
    @State private var isOwner = true
    @State private var isShowingDeleteAlert = false
    @State private var isShowingLeaveAlert = false
    @State private var currentMemberCount = 18
    @State private var maxMemberCount = 50
    /// 게시물 삭제 확인 팝업용 타겟 ID (탐험대 상세 피드)
    @State private var deleteTargetId: Int? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                memberRow
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach($cards) { $card in
                            ChallengeCardView(
                                card: $card,
                                onDelete: { id in
                                    deleteTargetId = id
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
            }

            Button {
                // TODO: API 연결 시 탐험대로 게시물 올리기 처리
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
            .padding(.bottom, 30)
        }
        .fullScreenCover(isPresented: $isShowingMemberList) {
            ChallengeExpeditionMemberListView(
                title: "탐험대 명단",
                memberCountText: memberCountText,
                isOwner: isOwner,
                members: ChallengeExpeditionMember.sampleMembers,
                onClose: { isShowingMemberList = false },
                onKick: { _ in
                    // TODO: API 연결 시 탐험대원 퇴출 처리
                },
                onKickCancel: { _ in
                    // TODO: API 연결 시 퇴출 해제 처리
                },
                onFriendRequest: { _ in
                    // TODO: API 연결 시 친구 신청 처리
                }
            )
            .presentationBackground(.clear)
        }
        .alert(
            deleteAlertTitle,
            isPresented: $isShowingDeleteAlert
        ) {
            Button("취소", role: .cancel) { }
            Button("탐험대 삭제", role: .destructive) {
                // TODO: API 연결 시 탐험대 삭제 처리
            }
        } message: {
            Text(deleteAlertMessage)
        }
        .alert(
            leaveAlertTitle,
            isPresented: $isShowingLeaveAlert
        ) {
            Button("취소", role: .cancel) { }
            Button("탐험대 탈퇴", role: .destructive) {
                // TODO: API 연결 시 탐험대 탈퇴 처리
            }
        } message: {
            Text(leaveAlertMessage)
        }
        // 게시물 삭제 확인: 전체 화면(세이프에어리어·탭바 포함) 덮고, 팝업은 화면 정중앙
        .fullScreenCover(isPresented: Binding(
            get: { deleteTargetId != nil },
            set: { if !$0 { deleteTargetId = nil } }
        )) {
            deleteConfirmFullScreen
        }
    }
}

private extension ChallengeExpeditionDetailView {
    var header: some View {
        HStack(spacing: 8) {
            Button {
                // TODO: 라우팅 연결 (뒤로가기)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(Color("5-Text"))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(expeditionName)
                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                .foregroundStyle(Color("5-Text"))

            Spacer()

            Button {
                // TODO: API 연결 시 탐험대 수정/삭제 메뉴 처리
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color("5-Text"))
            }
            .buttonStyle(.plain)
        }
    }

    var memberRow: some View {
        HStack(spacing: 8) {
            Button {
                isShowingMemberList = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color(.primaryColorVarient65))

                    Text("탐험대 명단")
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color("5-Text"))
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                if isOwner {
                    isShowingDeleteAlert = true
                } else {
                    isShowingLeaveAlert = true
                }
            } label: {
                Text(isOwner ? "탐험대 삭제" : "탐험대 탈퇴")
                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.primaryColorVarient65))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
    }

    var deleteAlertTitle: String {
        "정말로 '\(expeditionName)' 탐험대를 삭제할까요?"
    }

    var deleteAlertMessage: String {
        "탐험대를 삭제하면 모든 탐험대 인원은 더 이상 이 탐험대에 접근할 수 없으며, 삭제된 탐험대는 복구할 수 없습니다."
    }

    var leaveAlertTitle: String {
        "정말로 '\(expeditionName)' 탐험대를 탈퇴할까요?"
    }

    var leaveAlertMessage: String {
        "탐험대 탈퇴 후에는 이 탐험대의 기록과 활동을 확인할 수 없습니다."
    }

    var memberCountText: String {
        "\(currentMemberCount)/\(maxMemberCount)"
    }
}

// MARK: - Delete Confirm Popup (Expedition Detail) — 전체 화면 + 정중앙

extension ChallengeExpeditionDetailView {
    private var deleteConfirmFullScreen: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    deleteTargetId = nil
                }

            if let targetId = deleteTargetId {
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
                            networkManager.requestStatusCode(target: ChallengeAPI.deleteChallenge(challengeId: targetId)) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        cards.removeAll { $0.challengeId == targetId }
                                    case .failure:
                                        break
                                    }
                                    deleteTargetId = nil
                                }
                            }
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

#Preview {
    ChallengeExpeditionDetailView(expeditionName: "갓생 루틴 공유방")
        .environment(NavigationRouter())
}
