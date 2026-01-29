//
//  ChallengeExpeditionMemberListView.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import SwiftUI

struct ChallengeExpeditionMember: Identifiable {
    let id = UUID()
    let name: String
    let isSelf: Bool
    let isLeader: Bool
    let isFriend: Bool
    let isKickPending: Bool
}

extension ChallengeExpeditionMember {
    static let sampleMembers: [ChallengeExpeditionMember] = [
        ChallengeExpeditionMember(name: "서리 (나)", isSelf: true, isLeader: true, isFriend: true, isKickPending: false),
        ChallengeExpeditionMember(name: "쥬디 (탐험대장)", isSelf: false, isLeader: true, isFriend: true, isKickPending: false),
        ChallengeExpeditionMember(name: "키미", isSelf: false, isLeader: false, isFriend: true, isKickPending: false),
        ChallengeExpeditionMember(name: "써니", isSelf: false, isLeader: false, isFriend: false, isKickPending: false),
        ChallengeExpeditionMember(name: "핀", isSelf: false, isLeader: false, isFriend: false, isKickPending: false),
        ChallengeExpeditionMember(name: "허니", isSelf: false, isLeader: false, isFriend: false, isKickPending: true),
        ChallengeExpeditionMember(name: "엠제이", isSelf: false, isLeader: false, isFriend: false, isKickPending: false),
        ChallengeExpeditionMember(name: "우니", isSelf: false, isLeader: false, isFriend: false, isKickPending: false),
        ChallengeExpeditionMember(name: "매티", isSelf: false, isLeader: false, isFriend: false, isKickPending: false)
    ]
}

struct ChallengeExpeditionMemberListView: View {
    let title: String
    let memberCountText: String
    let isOwner: Bool
    let members: [ChallengeExpeditionMember]
    var onClose: () -> Void
    var onKick: (UUID) -> Void
    var onKickCancel: (UUID) -> Void
    var onFriendRequest: (UUID) -> Void
    private var sortedMembers: [ChallengeExpeditionMember] {
        members.sorted { lhs, rhs in
            switch (lhs.isKickPending, rhs.isKickPending) {
            case (true, false):
                return false
            case (false, true):
                return true
            default:
                return false
            }
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 0) {
                header
                    .padding(.top, 24)
                    .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(sortedMembers.indices, id: \.self) { index in
                            let member = sortedMembers[index]
                            MemberRow(
                                member: member,
                                isOwner: isOwner,
                                onKick: onKick,
                                onKickCancel: onKickCancel,
                                onFriendRequest: onFriendRequest
                            )

                            if index < sortedMembers.count - 1,
                               member.isKickPending != sortedMembers[index + 1].isKickPending {
                                Divider()
                                    .background(Color.gray.opacity(0.15))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
                .scrollIndicators(.hidden)

                Divider()

                Button("닫기") {
                    onClose()
                }
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(Color(.primaryColorVarient65))
                .frame(maxWidth: .infinity, minHeight: 56)
            }
            .frame(width: 320, height: 520)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
    }
}

private extension ChallengeExpeditionMemberListView {
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                .foregroundStyle(Color("5-Text"))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(memberCountText)
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(Color(.primaryColorVarient65))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
    }
}

private struct MemberRow: View {
    let member: ChallengeExpeditionMember
    let isOwner: Bool
    var onKick: (UUID) -> Void
    var onKickCancel: (UUID) -> Void
    var onFriendRequest: (UUID) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.white)
                )

            Text(memberDisplayName)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color("5-Text"))

            Spacer()

            actionButton
        }
        .padding(.vertical, 10)
    }

    private var memberDisplayName: String {
        member.name
    }

    @ViewBuilder
    private var actionButton: some View {
        if member.isSelf {
            EmptyView()
        } else if isOwner {
            Button(member.isKickPending ? "퇴출 해제" : "퇴출") {
                if member.isKickPending {
                    onKickCancel(member.id)
                } else {
                    onKick(member.id)
                }
            }
            .buttonStyle(ExpeditionMemberActionStyle(isHighlighted: true))
        } else {
            if member.isFriend {
                Text("친구")
                    .buttonStyle(ExpeditionMemberActionStyle(isHighlighted: false))
            } else {
                Button("친구 신청") {
                    onFriendRequest(member.id)
                }
                .buttonStyle(ExpeditionMemberActionStyle(isHighlighted: true))
            }
        }
    }
}

private struct ExpeditionMemberActionStyle: ButtonStyle {
    let isHighlighted: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
            .foregroundStyle(isHighlighted ? Color.white : Color("25-Text"))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHighlighted ? Color(.primaryColorVarient65) : Color.gray.opacity(0.2))
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

#Preview {
    ChallengeExpeditionMemberListView(
        title: "탐험대 명단",
        memberCountText: "8/10",
        isOwner: true,
        members: ChallengeExpeditionMember.sampleMembers,
        onClose: {},
        onKick: { _ in },
        onKickCancel: { _ in },
        onFriendRequest: { _ in }
    )
}
