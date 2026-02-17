//
//  ChallengeExpeditionMemberListView.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import SwiftUI

struct ChallengeExpeditionMember: Identifiable {
    let id: Int
    let name: String
    let profileImageUrl: String?
    let isSelf: Bool
    let isLeader: Bool
    let isKickPending: Bool
}

extension ChallengeExpeditionMember {
    static let sampleMembers: [ChallengeExpeditionMember] = [
        ChallengeExpeditionMember(id: 1, name: "서리", profileImageUrl: nil, isSelf: true, isLeader: true, isKickPending: false),
        ChallengeExpeditionMember(id: 2, name: "쥬디", profileImageUrl: nil, isSelf: false, isLeader: false, isKickPending: false),
        ChallengeExpeditionMember(id: 3, name: "키미", profileImageUrl: nil, isSelf: false, isLeader: false, isKickPending: false),
        ChallengeExpeditionMember(id: 4, name: "써니", profileImageUrl: nil, isSelf: false, isLeader: false, isKickPending: false),
        ChallengeExpeditionMember(id: 5, name: "핀", profileImageUrl: nil, isSelf: false, isLeader: false, isKickPending: true)
    ]
}

struct ChallengeExpeditionMemberListView: View {
    let title: String
    let memberCountText: String
    let isHost: Bool
    let members: [ChallengeExpeditionMember]
    let isLoading: Bool
    let errorMessage: String?
    var onClose: () -> Void
    var onRefresh: () -> Void
    var onKick: (Int) -> Void
    var onKickCancel: (Int) -> Void
    private var sortedMembers: [ChallengeExpeditionMember] {
        members.sorted { lhs, rhs in
            if lhs.isSelf != rhs.isSelf { return lhs.isSelf }
            if lhs.isKickPending != rhs.isKickPending { return !lhs.isKickPending }
            if lhs.isLeader != rhs.isLeader { return lhs.isLeader }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private var hasKickedMembers: Bool {
        sortedMembers.contains { $0.isKickPending }
    }

    private var approvedMembers: [ChallengeExpeditionMember] {
        sortedMembers.filter { !$0.isKickPending }
    }

    private var kickedMembers: [ChallengeExpeditionMember] {
        sortedMembers.filter { $0.isKickPending }
    }

    private func memberDisplayName(_ member: ChallengeExpeditionMember) -> String {
        if member.isSelf {
            return "\(member.name) (나)"
        }
        if member.isLeader {
            return "\(member.name) (탐험대장)"
        }
        return member.name
    }

    @ViewBuilder
    private var memberListContent: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 140)
                .padding(.top, 20)
        } else if let errorMessage {
            Text(errorMessage)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color("25-Text"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 140)
                .padding(.top, 20)
        } else if sortedMembers.isEmpty {
            Text("탐험대원이 없습니다.")
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color("25-Text"))
                .frame(maxWidth: .infinity, minHeight: 140)
                .padding(.top, 20)
        } else {
            VStack(spacing: 0) {
                ForEach(approvedMembers) { member in
                    MemberRow(
                        member: member,
                        isHost: isHost,
                        onKick: onKick,
                        onKickCancel: onKickCancel,
                        displayName: memberDisplayName(member)
                    )
                }

                if hasKickedMembers {
                    Divider()
                        .background(Color.gray.opacity(0.15))
                        .padding(.vertical, 2)

                    ForEach(kickedMembers) { member in
                        MemberRow(
                            member: member,
                            isHost: isHost,
                            onKick: onKick,
                            onKickCancel: onKickCancel,
                            displayName: memberDisplayName(member)
                        )
                    }
                }
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
                        memberListContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    onRefresh()
                }

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
                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(Color(.primaryColorVarient65))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
    }
}

private struct MemberRow: View {
    let member: ChallengeExpeditionMember
    let isHost: Bool
    let onKick: (Int) -> Void
    let onKickCancel: (Int) -> Void
    let displayName: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.white)
                )

            Text(displayName)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color("5-Text"))

            Spacer()

            actionButton
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var actionButton: some View {
        if !isHost || member.isSelf {
            EmptyView()
        } else {
            Button(member.isKickPending ? "퇴출 해제" : "퇴출") {
                if member.isKickPending {
                    onKickCancel(member.id)
                } else {
                    onKick(member.id)
                }
            }
            .buttonStyle(ExpeditionMemberActionStyle(isHighlighted: true))
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
        isHost: true,
        members: ChallengeExpeditionMember.sampleMembers,
        isLoading: false,
        errorMessage: nil,
        onClose: {},
        onRefresh: {},
        onKick: { _ in },
        onKickCancel: { _ in }
    )
}
