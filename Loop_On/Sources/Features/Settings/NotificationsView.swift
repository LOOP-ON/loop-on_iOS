//
//  NotificationsView.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(NavigationRouter.self) private var router
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 전체 알림
                notificationSectionTitle("전체 알림")
                    .padding(.top, 24)
                    .padding(.bottom, 12)

                notificationToggleRow("전체 알림", isOn: $viewModel.isAllNotificationsOn)

                // 루틴 알림
                notificationSectionTitle("루틴 알림")
                    .padding(.top, 32)
                    .padding(.bottom, 12)

                routineVerificationRow
                notificationToggleRow("미완료 리마인드 알림", isOn: $viewModel.isUnfinishedReminderOn)

                // 여정 관련 알림
                notificationSectionTitle("여정 관련 알림")
                    .padding(.top, 32)
                    .padding(.bottom, 12)

                notificationToggleRow("오늘 여정 기록 알림", isOn: $viewModel.isTodayJourneyLogOn)
                notificationToggleRow("여정 완료 알림", isOn: $viewModel.isJourneyCompleteOn)

                // 시스템 알림
                notificationSectionTitle("시스템 알림")
                    .padding(.top, 32)
                    .padding(.bottom, 12)

                notificationToggleRow("친구 신청 알림", isOn: $viewModel.isFriendRequestOn)
                notificationToggleRow("좋아요 알림", isOn: $viewModel.isLikeOn)
                notificationToggleRow("댓글 알림", isOn: $viewModel.isCommentOn)
                notificationToggleRow("공지/업데이트 알림", isOn: $viewModel.isAnnouncementOn)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
        .navigationTitle("알림")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.primary)
                }
            }
        }
    }

    private func notificationSectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color("25-Text"))
    }

    private func notificationToggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color("25-Text"))
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color("PrimaryColor55"))
        }
        .padding(.vertical, 14)
    }

    private var routineVerificationRow: some View {
        HStack(alignment: .center) {
            Text("루틴 인증 알림")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color("25-Text"))
            Spacer()
            routineVerificationSegmentedControl
        }
        .padding(.vertical, 14)
    }

    private var routineVerificationSegmentedControl: some View {
        HStack(spacing: 6) {
            ForEach(RoutineVerificationMode.allCases, id: \.self) { mode in
                Button {
                    viewModel.routineVerificationMode = mode
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(viewModel.routineVerificationMode == mode ? Color("100") : Color("25-Text"))
                        .frame(minWidth: 48)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(viewModel.routineVerificationMode == mode ? Color("PrimaryColor55") : Color("85"))
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environment(NavigationRouter())
            .environment(SessionStore())
    }
}
