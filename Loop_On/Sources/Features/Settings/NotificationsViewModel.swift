//
//  NotificationsViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import Foundation
import SwiftUI

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var isAllNotificationsOn = false
    @Published var routineVerificationMode: RoutineVerificationMode = .sound
    @Published var isUnfinishedReminderOn = false
    @Published var isTodayJourneyLogOn = false
    @Published var isEndOfDayNotificationOn = false
    @Published var endOfDayNotificationTime: Date = {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
    }()
    @Published var isJourneyCompleteOn = false
    @Published var isFriendRequestOn = false
    @Published var isLikeOn = false
    @Published var isCommentOn = false
    @Published var isAnnouncementOn = false
}

enum RoutineVerificationMode: String, CaseIterable {
    case sound = "사운드"
    case vibration = "진동"
    case silent = "무음"
}
