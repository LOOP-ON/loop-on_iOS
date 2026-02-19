//
//  RoutineNotificationScheduler.swift
//  Loop_On
//
//  Created by 경민 on 2/19/26.
//

import Foundation
import UserNotifications

enum RoutineNotificationScheduleResult {
    case scheduled
    case denied
    case failed(Error)
}

final class RoutineNotificationScheduler {
    static let shared = RoutineNotificationScheduler()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let identifierPrefix = "routine.verification."

    private init() {}

    func scheduleDailyRoutineNotifications(
        routines: [RoutineCoach],
        completion: @escaping (RoutineNotificationScheduleResult) -> Void
    ) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self.replaceRoutineNotifications(with: routines, completion: completion)
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if let error {
                        completion(.failed(error))
                        return
                    }

                    guard granted else {
                        completion(.denied)
                        return
                    }

                    self.replaceRoutineNotifications(with: routines, completion: completion)
                }
            case .denied:
                completion(.denied)
            @unknown default:
                completion(.denied)
            }
        }
    }

    private func replaceRoutineNotifications(
        with routines: [RoutineCoach],
        completion: @escaping (RoutineNotificationScheduleResult) -> Void
    ) {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }

            let previousRoutineRequestIDs = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(self.identifierPrefix) }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: previousRoutineRequestIDs)

            guard !routines.isEmpty else {
                completion(.scheduled)
                return
            }

            let calendar = Calendar.current
            let dispatchGroup = DispatchGroup()
            var capturedError: Error?

            for routine in routines {
                let routineName = routine.name.trimmingCharacters(in: .whitespacesAndNewlines)
                let title = "루틴 인증 알림"
                let body = "🌟 \(routineName.isEmpty ? "루틴" : routineName)을 실행할 시간이에요! 지금 바로 사진을 촬영해 인증을 해주세요."

                var dateComponents = calendar.dateComponents([.hour, .minute], from: routine.alarmTime)
                dateComponents.second = 0

                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                content.userInfo = [
                    "type": "routine_verification",
                    "routineIndex": routine.index
                ]

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let requestID = "\(identifierPrefix)\(routine.id.uuidString)"
                let request = UNNotificationRequest(
                    identifier: requestID,
                    content: content,
                    trigger: trigger
                )

                dispatchGroup.enter()
                notificationCenter.add(request) { error in
                    if let error, capturedError == nil {
                        capturedError = error
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                if let capturedError {
                    completion(.failed(capturedError))
                } else {
                    completion(.scheduled)
                }
            }
        }
    }
}

