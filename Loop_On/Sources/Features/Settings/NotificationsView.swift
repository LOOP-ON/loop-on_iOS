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
    @State private var isShowingTimePicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                allNotificationsSection
                routineNotificationsSection
                journeyNotificationsSection
                systemNotificationsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(Color("45-Text"))
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
        .sheet(isPresented: $isShowingTimePicker) {
            TimePickerSheet(
                selectedDate: $viewModel.endOfDayNotificationTime,
                onSave: {
                    isShowingTimePicker = false
                },
                onClose: {
                    isShowingTimePicker = false
                }
            )
            .presentationDetents([.height(300)])
        }
    }

    private var endOfDayNotificationRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 토글 행
            HStack {
                Text("하루 종료 알림")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color("25-Text"))
                Spacer()
                Toggle("", isOn: $viewModel.isEndOfDayNotificationOn)
                    .labelsHidden()
                    .tint(Color("PrimaryColor55"))
            }
            .padding(.vertical, 14)

            // 시간 선택 버튼 (토글이 켜져있을 때만 표시)
            if viewModel.isEndOfDayNotificationOn {
                HStack {
                    Spacer()
                    Button(action: {
                        isShowingTimePicker = true
                    }) {
                        Text(timeString)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color("25-Text"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color("85"), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color("100"))
                            )
                    )
                }

                .padding(.bottom, 14)
            }
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a HH:mm"
        return formatter.string(from: viewModel.endOfDayNotificationTime)
    }

    // MARK: - Section Containers (iOS 설정 앱 스타일 카드)

    private var allNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            notificationSectionTitle("전체 알림")

            VStack(spacing: 0) {
                notificationToggleRow("전체 알림", isOn: $viewModel.isAllNotificationsOn)
            }
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
            )
        }
    }

    private var routineNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            notificationSectionTitle("루틴 알림")

            VStack(spacing: 0) {
                routineVerificationRow

                Divider()
                    // 텍스트와 동일한 시작 위치를 위해, 카드 내부 공통 padding(20)만 사용

                notificationToggleRow("미완료 리마인드 알림", isOn: $viewModel.isUnfinishedReminderOn)
            }
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
            )
        }
    }

    private var journeyNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            notificationSectionTitle("여정 관련 알림")

            VStack(spacing: 0) {
                notificationToggleRow("오늘 여정 기록 알림", isOn: $viewModel.isTodayJourneyLogOn)

                Divider()
                    // 텍스트 시작 위치와 맞추기 위해 추가 leading padding 제거

                endOfDayNotificationRow

                Divider()
                    // 텍스트 시작 위치와 맞추기 위해 추가 leading padding 제거

                notificationToggleRow("여정 완료 알림", isOn: $viewModel.isJourneyCompleteOn)
            }
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
            )
        }
    }

    private var systemNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            notificationSectionTitle("시스템 알림")

            VStack(spacing: 0) {
                notificationToggleRow("친구 신청 알림", isOn: $viewModel.isFriendRequestOn)

                Divider()
                    // 텍스트 시작 위치와 맞추기 위해 추가 leading padding 제거

                notificationToggleRow("좋아요 알림", isOn: $viewModel.isLikeOn)

                Divider()
                    // 텍스트 시작 위치와 맞추기 위해 추가 leading padding 제거

                notificationToggleRow("댓글 알림", isOn: $viewModel.isCommentOn)

                Divider()
                    // 텍스트 시작 위치와 맞추기 위해 추가 leading padding 제거

                notificationToggleRow("공지/업데이트 알림", isOn: $viewModel.isAnnouncementOn)
            }
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
            )
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
