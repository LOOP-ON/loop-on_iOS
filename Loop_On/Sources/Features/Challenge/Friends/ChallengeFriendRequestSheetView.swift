//
//  ChallengeFriendRequestSheetView.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import SwiftUI

struct ChallengeFriendRequestSheet: View {
    let requests: [ChallengeFriendRequest]
    let isLoadingMore: Bool
    var onAccept: (Int) -> Void
    var onReject: (Int) -> Void
    var onAcceptAll: () -> Void
    var onRejectAll: () -> Void
    var onClose: () -> Void
    var onRequestRowAppear: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 26)
                .padding(.bottom, 8)

            if requests.isEmpty {
                emptyState
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(requests.indices, id: \.self) { index in
                            let request = requests[index]
                            RequestRow(
                                request: request,
                                onAccept: onAccept,
                                onReject: onReject
                            )
                            .onAppear {
                                onRequestRowAppear(request.id)
                            }

                            if index < requests.count - 1 {
                                Divider()
                                    .background(Color.gray.opacity(0.15))
                            }
                        }

                        if isLoadingMore {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.bottom, 8)
                }
                .scrollIndicators(.hidden)
                .frame(maxHeight: .infinity)
            }

            actionButtons
                .padding(.top, 12)
                .padding(.bottom, 16)

            Divider()
                .background(Color.gray.opacity(0.2))

            Button("닫기") {
                onClose()
            }
            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
            .foregroundStyle(Color(.primaryColorVarient65))
            .padding(.vertical, 12)
        }
    }
}

private extension ChallengeFriendRequestSheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("친구 신청")
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(requests.isEmpty ? "새로운 친구 신청 알림 없어요" : "새로운 친구 신청 알림 있어요")
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color(.primaryColorVarient65))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Text("친구 요청이 없습니다.")
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }

    var actionButtons: some View {
        HStack(spacing: 12) {
            Button("모두 수락") {
                onAcceptAll()
            }
            .buttonStyle(ChallengeRequestActionStyle(isEnabled: !requests.isEmpty))
            .disabled(requests.isEmpty)

            Button("모두 거절") {
                onRejectAll()
            }
            .buttonStyle(ChallengeRequestActionStyle(isEnabled: !requests.isEmpty))
            .disabled(requests.isEmpty)
        }
    }
}

private struct RequestRow: View {
    let request: ChallengeFriendRequest
    var onAccept: (Int) -> Void
    var onReject: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(request.name)
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                    .foregroundStyle(Color("5-Text"))

                Text(request.subtitle)
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(Color.gray)
            }

            Spacer()

            VStack(spacing: 8) {
                Button("수락") {
                    onAccept(request.id)
                }
                .buttonStyle(ChallengeRequestChipStyle(isPrimary: true))

                Button("거절") {
                    onReject(request.id)
                }
                .buttonStyle(ChallengeRequestChipStyle(isPrimary: false))
            }
        }
        .padding(.vertical, 12)
    }
}

private struct ChallengeRequestActionStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isEnabled ? Color(.primaryColorVarient65) : Color.gray.opacity(0.3))
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

private struct ChallengeRequestChipStyle: ButtonStyle {
    let isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isPrimary ? Color(.primaryColorVarient65) : Color.gray.opacity(0.4))
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

#Preview {
    ChallengeFriendRequestSheet(
        requests: ChallengeFriendRequest.sampleRequests,
        isLoadingMore: false,
        onAccept: { _ in },
        onReject: { _ in },
        onAcceptAll: {},
        onRejectAll: {},
        onClose: {},
        onRequestRowAppear: { _ in }
    )
    .frame(maxWidth: 320, maxHeight: 540)
    .padding(24)
    .background(Color.black.opacity(0.2))
}
