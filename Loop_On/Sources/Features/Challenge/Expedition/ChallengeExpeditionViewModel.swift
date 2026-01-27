//
//  ChallengeExpeditionViewModel.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import Foundation

final class ChallengeExpeditionViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedCategories: Set<String> = []
    @Published var isShowingCreateModal = false
    @Published var isShowingMemberPicker = false
    @Published var isShowingCreateSuccessAlert = false
    @Published var isShowingDeleteAlert = false
    @Published var isShowingLeaveAlert = false
    @Published var isShowingJoinPrivateAlert = false
    @Published var joinPassword: String = ""
    @Published var createName: String = ""
    @Published var createMemberCount: Int = 10
    @Published var isPublicExpedition: Bool = true
    @Published var password: String = ""
    @Published var selectedCreateCategories: Set<String> = []

    let categories = ["역량 강화", "생활 루틴", "내면 관리"]

    private var allMyExpeditions: [ChallengeExpedition]
    private var allRecommendedExpeditions: [ChallengeExpedition]
    private var pendingDeleteExpeditionID: UUID?
    private var pendingDeleteExpeditionName: String = ""
    private var pendingLeaveExpeditionID: UUID?
    private var pendingLeaveExpeditionName: String = ""
    private var pendingJoinExpeditionID: UUID?
    private var pendingJoinExpeditionName: String = ""

    init(
        myExpeditions: [ChallengeExpedition] = ChallengeExpedition.sampleMyExpeditions,
        recommendedExpeditions: [ChallengeExpedition] = ChallengeExpedition.sampleRecommendedExpeditions
    ) {
        self.allMyExpeditions = myExpeditions
        self.allRecommendedExpeditions = recommendedExpeditions
    }

    var myExpeditions: [ChallengeExpedition] {
        filterExpeditions(allMyExpeditions)
    }

    var recommendedExpeditions: [ChallengeExpedition] {
        filterExpeditions(allRecommendedExpeditions)
    }

    func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    func clearSearch() {
        searchText = ""
    }

    func handleAction(_ expedition: ChallengeExpedition) {
        if expedition.isMember {
            if expedition.isOwner {
                requestDelete(expedition)
            } else {
                requestLeave(expedition)
            }
        } else {
            if expedition.isPrivate {
                requestJoinPrivate(expedition)
            } else {
                // TODO: API 연결 시 탐험대 가입 처리 (expedition.id)
            }
        }
    }

    func createExpedition() {
        // TODO: API 연결 시 탐험대 생성 처리 (createName, createMemberCount, isPublicExpedition, password, selectedCreateCategories)
        isShowingCreateModal = false
        isShowingCreateSuccessAlert = true
    }

    func requestDelete(_ expedition: ChallengeExpedition) {
        pendingDeleteExpeditionID = expedition.id
        pendingDeleteExpeditionName = expedition.name
        isShowingDeleteAlert = true
    }

    func confirmDelete() {
        // TODO: API 연결 시 탐험대 삭제 처리 (pendingDeleteExpeditionID)
        if let id = pendingDeleteExpeditionID {
            allMyExpeditions.removeAll { $0.id == id }
        }
        pendingDeleteExpeditionID = nil
        pendingDeleteExpeditionName = ""
        isShowingDeleteAlert = false
    }

    func cancelDelete() {
        pendingDeleteExpeditionID = nil
        pendingDeleteExpeditionName = ""
        isShowingDeleteAlert = false
    }

    func requestLeave(_ expedition: ChallengeExpedition) {
        pendingLeaveExpeditionID = expedition.id
        pendingLeaveExpeditionName = expedition.name
        isShowingLeaveAlert = true
    }

    func confirmLeave() {
        // TODO: API 연결 시 탐험대 탈퇴 처리 (pendingLeaveExpeditionID)
        if let id = pendingLeaveExpeditionID {
            allMyExpeditions.removeAll { $0.id == id }
        }
        pendingLeaveExpeditionID = nil
        pendingLeaveExpeditionName = ""
        isShowingLeaveAlert = false
    }

    func cancelLeave() {
        pendingLeaveExpeditionID = nil
        pendingLeaveExpeditionName = ""
        isShowingLeaveAlert = false
    }

    func requestJoinPrivate(_ expedition: ChallengeExpedition) {
        pendingJoinExpeditionID = expedition.id
        pendingJoinExpeditionName = expedition.name
        joinPassword = ""
        isShowingJoinPrivateAlert = true
    }

    func confirmJoinPrivate() {
        // TODO: API 연결 시 비공개 탐험대 비밀번호 검증 요청 (pendingJoinExpeditionID, joinPassword)
        pendingJoinExpeditionID = nil
        pendingJoinExpeditionName = ""
        joinPassword = ""
        isShowingJoinPrivateAlert = false
    }

    func cancelJoinPrivate() {
        pendingJoinExpeditionID = nil
        pendingJoinExpeditionName = ""
        joinPassword = ""
        isShowingJoinPrivateAlert = false
    }

    func openCreateModal() {
        isShowingCreateModal = true
    }

    func closeCreateModal() {
        isShowingCreateModal = false
    }

    func closeCreateSuccessAlert() {
        isShowingCreateSuccessAlert = false
    }

    var createSuccessMessage: String {
        let name = createName.isEmpty ? "탐험대" : createName
        return "'\(name)' 탐험대가 생성되었습니다."
    }

    var deleteAlertTitle: String {
        let name = pendingDeleteExpeditionName.isEmpty ? "탐험대" : pendingDeleteExpeditionName
        return "정말로 '\(name)' 탐험대를 삭제할까요?"
    }

    var deleteAlertMessage: String {
        "탐험대를 삭제하면 모든 탐험대 인원은 더 이상 이 탐험대에 접근할 수 없으며, 삭제된 탐험대는 복구할 수 없습니다."
    }

    var leaveAlertTitle: String {
        let name = pendingLeaveExpeditionName.isEmpty ? "탐험대" : pendingLeaveExpeditionName
        return "정말로 '\(name)' 탐험대를 탈퇴할까요?"
    }

    var leaveAlertMessage: String {
        "탐험대 탈퇴 후에는 이 탐험대의 기록과 활동을 확인할 수 없습니다."
    }

    var joinPrivateAlertTitle: String {
        let name = pendingJoinExpeditionName.isEmpty ? "탐험대" : pendingJoinExpeditionName
        return "'\(name)' 탐험대에 가입하기 위해 암호를 입력해주세요."
    }

    func openMemberPicker() {
        isShowingMemberPicker = true
    }

    func closeMemberPicker() {
        isShowingMemberPicker = false
    }

    func toggleCreateCategory(_ category: String) {
        if selectedCreateCategories.contains(category) {
            selectedCreateCategories.remove(category)
        } else {
            selectedCreateCategories.insert(category)
        }
    }

    var isCreateValid: Bool {
        let trimmedName = createName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        guard !selectedCreateCategories.isEmpty else { return false }
        if isPublicExpedition {
            return true
        }
        return isPasswordValid
    }

    var isPasswordValid: Bool {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (4...8).contains(trimmed.count) else { return false }
        return trimmed.allSatisfy { $0.isNumber }
    }

    private func filterExpeditions(_ list: [ChallengeExpedition]) -> [ChallengeExpedition] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredByKeyword = keyword.isEmpty
            ? list
            : list.filter {
                $0.name.localizedCaseInsensitiveContains(keyword) ||
                $0.category.localizedCaseInsensitiveContains(keyword) ||
                $0.leaderName.localizedCaseInsensitiveContains(keyword)
            }

        guard !selectedCategories.isEmpty else { return filteredByKeyword }
        return filteredByKeyword.filter { selectedCategories.contains($0.category) }
    }
}
