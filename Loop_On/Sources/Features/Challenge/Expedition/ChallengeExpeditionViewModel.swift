//
//  ChallengeExpeditionViewModel.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import Foundation

final class ChallengeExpeditionViewModel: ObservableObject {
    private let networkManager: DefaultNetworkManager<ExpeditionAPI>
    private var hasLoadedMyExpeditions = false

    @Published var searchText: String = ""
    @Published var selectedCategories: Set<String> = []
    @Published var searchResults: [ChallengeExpedition] = []
    @Published var hasSearched: Bool = false
    @Published var isSearching: Bool = false
    @Published var searchErrorMessage: String?
    @Published var isShowingCreateModal = false
    @Published var isShowingMemberPicker = false
    @Published var isShowingCreateSuccessAlert = false
    @Published var isShowingDeleteAlert = false
    @Published var isShowingLeaveAlert = false
    @Published var isShowingJoinPrivateAlert = false
    @Published var joinPassword: String = ""
    @Published var joinResultTitle: String = "탐험대 가입"
    @Published var joinResultMessage: String?
    @Published var isShowingJoinResultAlert: Bool = false
    @Published var createName: String = ""
    @Published var createMemberCount: Int = 10
    @Published var isPublicExpedition: Bool = true
    @Published var password: String = ""
    @Published var selectedCreateCategories: Set<String> = []
    @Published var isLoadingMyExpeditions: Bool = false
    @Published var loadMyExpeditionsErrorMessage: String?
    @Published var isCreatingExpedition: Bool = false
    @Published var createErrorTitle: String = "탐험대 오류"
    @Published var createErrorMessage: String?
    @Published var isShowingCreateErrorAlert: Bool = false

    let categories = ["역량 강화", "생활 루틴", "내면 관리"]

    private var allMyExpeditions: [ChallengeExpedition]
    private var allRecommendedExpeditions: [ChallengeExpedition]
    private var pendingDeleteExpeditionID: Int?
    private var pendingDeleteExpeditionName: String = ""
    private var pendingLeaveExpeditionID: Int?
    private var pendingLeaveExpeditionName: String = ""
    private var pendingJoinExpeditionID: Int?
    private var pendingJoinExpeditionName: String = ""
    private var pendingJoinIsPrivate: Bool = false
    private var isJoiningExpedition: Bool = false
    private var lastCreatedExpeditionName: String = ""

    init(
        myExpeditions: [ChallengeExpedition] = [],
        recommendedExpeditions: [ChallengeExpedition] = ChallengeExpedition.sampleRecommendedExpeditions,
        networkManager: DefaultNetworkManager<ExpeditionAPI> = DefaultNetworkManager<ExpeditionAPI>()
    ) {
        self.allMyExpeditions = myExpeditions
        self.allRecommendedExpeditions = recommendedExpeditions
        self.networkManager = networkManager
    }

    var myExpeditions: [ChallengeExpedition] {
        filterExpeditions(allMyExpeditions)
    }

    var recommendedExpeditions: [ChallengeExpedition] {
        filterExpeditions(allRecommendedExpeditions)
    }

    var isShowingSearchResults: Bool {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return hasSearched && !keyword.isEmpty
    }

    func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }

        if isShowingSearchResults {
            searchExpeditions()
        }
    }

    func clearSearch() {
        searchText = ""
        clearSearchResults()
    }

    func clearSearchResults() {
        hasSearched = false
        isSearching = false
        searchResults = []
        searchErrorMessage = nil
    }

    func searchExpeditions() {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else {
            clearSearchResults()
            return
        }

        hasSearched = true
        isSearching = true
        searchErrorMessage = nil

        let categories = categoriesForSearchQuery()
        print("✅ [Expedition] searchExpeditions start: GET /api/expeditions/search")
        networkManager.request(
            target: .searchExpeditions(keyword: keyword, categories: categories, page: 0, size: 20),
            decodingType: ChallengeExpeditionSearchPageDTO.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isSearching = false
                switch result {
                case .success(let page):
                    print("✅ [Expedition] searchExpeditions success: count=\(page.content.count)")
                    page.content.forEach { item in
                        print("  - id=\(item.expeditionId), title=\(item.title), category=\(item.category), admin=\(item.admin), currentMembers=\(item.currentMembers), capacity=\(item.capacity), visibility=\(item.visibility), isJoined=\(item.isJoined)")
                    }
                    self.searchResults = page.content.map {
                        ChallengeExpedition(dto: $0, isMember: $0.isJoined)
                    }
                case .failure(let error):
                    print("❌ [Expedition] searchExpeditions failed: \(error)")
                    self.searchResults = []
                    self.searchErrorMessage = "검색 결과를 불러오지 못했어요.\n네트워크 상태를 확인해 주세요."
                }
            }
        }
    }

    func loadMyExpeditionsIfNeeded() {
        guard !hasLoadedMyExpeditions else { return }
        loadMyExpeditions()
    }

    func refreshMyExpeditions() {
        hasLoadedMyExpeditions = false
        loadMyExpeditions()
    }

    func loadMyExpeditions() {
        isLoadingMyExpeditions = true
        loadMyExpeditionsErrorMessage = nil
        print("✅ [Expedition] loadMyExpeditions start: GET /api/expeditions")

        networkManager.request(
            target: .getMyExpeditions,
            decodingType: ChallengeMyExpeditionListDTO.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoadingMyExpeditions = false
                self.hasLoadedMyExpeditions = true

                switch result {
                case .success(let dto):
                    self.loadMyExpeditionsErrorMessage = nil
                    self.allMyExpeditions = dto.expeditionGetResponses.map { ChallengeExpedition(dto: $0) }
                    print("✅ [Expedition] loadMyExpeditions success: count=\(self.allMyExpeditions.count)")
                case .failure(let error):
                    print("❌ [Expedition] loadMyExpeditions failed: \(error)")
                    self.loadMyExpeditionsErrorMessage = "탐험대 목록을 불러오지 못했어요.\n네트워크 상태를 확인해 주세요."
                }
            }
        }
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
                joinExpedition(
                    expeditionId: expedition.id,
                    expeditionName: expedition.name,
                    isPrivate: false,
                    password: nil
                )
            }
        }
    }

    func createExpedition() {
        guard isCreateValid else { return }

        let trimmedName = createName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let categoryDisplayName = categories.first(where: { selectedCreateCategories.contains($0) }) ?? "역량 강화"
        let categoryCode = ChallengeExpedition.categoryCode(from: categoryDisplayName)

        let request = CreateExpeditionRequest(
            title: trimmedName,
            capacity: createMemberCount,
            visibility: isPublicExpedition ? "PUBLIC" : "PRIVATE",
            category: categoryCode,
            password: isPublicExpedition ? nil : trimmedPassword
        )

        isCreatingExpedition = true
        logCreateExpeditionRequest(request)
        print("✅ [Expedition] createExpedition start: POST /api/expeditions")
        networkManager.request(
            target: .createExpedition(request: request),
            decodingType: CreateExpeditionResponseDTO.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isCreatingExpedition = false
                switch result {
                case .success(let data):
                    print("✅ [Expedition] createExpedition success: expeditionId=\(data.expeditionId)")
                    self.lastCreatedExpeditionName = trimmedName
                    self.isShowingCreateModal = false
                    self.isShowingCreateSuccessAlert = true
                    self.resetCreateInputs()
                    self.refreshMyExpeditions()
                case .failure(let error):
                    print("❌ [Expedition] createExpedition failed: \(error)")
                    self.createErrorTitle = "탐험대 생성 실패"
                    self.createErrorMessage = "탐험대를 생성하지 못했어요.\n입력값 또는 네트워크 상태를 확인해 주세요."
                    self.isShowingCreateErrorAlert = true
                }
            }
        }
    }

    func requestDelete(_ expedition: ChallengeExpedition) {
        pendingDeleteExpeditionID = expedition.id
        pendingDeleteExpeditionName = expedition.name
        isShowingDeleteAlert = true
    }

    func confirmDelete() {
        guard let id = pendingDeleteExpeditionID else {
            pendingDeleteExpeditionName = ""
            isShowingDeleteAlert = false
            return
        }

        print("✅ [Expedition] deleteExpedition start: DELETE /api/expeditions/\(id)")
        networkManager.requestStatusCode(
            target: .deleteExpedition(expeditionId: id)
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success:
                    print("✅ [Expedition] deleteExpedition success: expeditionId=\(id)")
                    self.allMyExpeditions.removeAll { $0.id == id }
                    self.pendingDeleteExpeditionID = nil
                    self.pendingDeleteExpeditionName = ""
                    self.isShowingDeleteAlert = false
                case .failure(let error):
                    print("❌ [Expedition] deleteExpedition failed: \(error)")
                    self.pendingDeleteExpeditionID = nil
                    self.pendingDeleteExpeditionName = ""
                    self.isShowingDeleteAlert = false
                    self.createErrorTitle = "탐험대 삭제 실패"
                    self.createErrorMessage = "탐험대 삭제에 실패했어요.\n잠시 후 다시 시도해 주세요."
                    self.isShowingCreateErrorAlert = true
                }
            }
        }
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
        guard let id = pendingLeaveExpeditionID else {
            pendingLeaveExpeditionName = ""
            isShowingLeaveAlert = false
            return
        }

        print("✅ [Expedition] withdrawExpedition start: DELETE /api/expeditions/\(id)/withdraw")
        networkManager.request(
            target: .withdrawExpedition(expeditionId: id),
            decodingType: CreateExpeditionResponseDTO.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success:
                    print("✅ [Expedition] withdrawExpedition success: expeditionId=\(id)")
                    self.allMyExpeditions.removeAll { $0.id == id }
                    self.pendingLeaveExpeditionID = nil
                    self.pendingLeaveExpeditionName = ""
                    self.isShowingLeaveAlert = false
                case .failure(let error):
                    print("❌ [Expedition] withdrawExpedition failed: \(error)")
                    self.pendingLeaveExpeditionID = nil
                    self.pendingLeaveExpeditionName = ""
                    self.isShowingLeaveAlert = false
                    self.createErrorTitle = "탐험대 탈퇴 실패"
                    self.createErrorMessage = "탐험대 탈퇴에 실패했어요.\n잠시 후 다시 시도해 주세요."
                    self.isShowingCreateErrorAlert = true
                }
            }
        }
    }

    func cancelLeave() {
        pendingLeaveExpeditionID = nil
        pendingLeaveExpeditionName = ""
        isShowingLeaveAlert = false
    }

    func requestJoinPrivate(_ expedition: ChallengeExpedition) {
        pendingJoinExpeditionID = expedition.id
        pendingJoinExpeditionName = expedition.name
        pendingJoinIsPrivate = true
        joinPassword = ""
        isShowingJoinPrivateAlert = true
    }

    func confirmJoinPrivate() {
        guard let id = pendingJoinExpeditionID else {
            joinPassword = ""
            isShowingJoinPrivateAlert = false
            return
        }
        let name = pendingJoinExpeditionName
        let password = joinPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        isShowingJoinPrivateAlert = false
        joinExpedition(
            expeditionId: id,
            expeditionName: name,
            isPrivate: pendingJoinIsPrivate,
            password: password
        )
    }

    func cancelJoinPrivate() {
        pendingJoinExpeditionID = nil
        pendingJoinExpeditionName = ""
        pendingJoinIsPrivate = false
        joinPassword = ""
        isShowingJoinPrivateAlert = false
    }

    func openCreateModal() {
        isShowingCreateModal = true
    }

    func closeCreateModal() {
        isShowingCreateModal = false
        resetCreateInputs()
    }

    func closeCreateSuccessAlert() {
        isShowingCreateSuccessAlert = false
        lastCreatedExpeditionName = ""
    }

    func closeCreateErrorAlert() {
        isShowingCreateErrorAlert = false
        createErrorTitle = "탐험대 오류"
    }

    func closeJoinResultAlert() {
        isShowingJoinResultAlert = false
        joinResultTitle = "탐험대 가입"
        joinResultMessage = nil
    }

    var createSuccessMessage: String {
        let name = lastCreatedExpeditionName.isEmpty ? "탐험대" : lastCreatedExpeditionName
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
            selectedCreateCategories = [category]
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

    private func resetCreateInputs() {
        createName = ""
        createMemberCount = 10
        isPublicExpedition = true
        password = ""
        selectedCreateCategories = []
    }

    private func logCreateExpeditionRequest(_ request: CreateExpeditionRequest) {
        let passwordLog = request.password == nil ? "nil" : "********"
        print("""
✅ [Expedition] createExpedition payload
- title: \(request.title)
- capacity: \(request.capacity)
- visibility: \(request.visibility)
- category: \(request.category)
- password: \(passwordLog)
""")
    }

    private func joinExpedition(expeditionId: Int, expeditionName: String, isPrivate: Bool, password: String?) {
        guard !isJoiningExpedition else { return }
        let request = JoinExpeditionRequest(
            expeditionId: expeditionId,
            expeditionVisibility: isPrivate ? "PRIVATE" : "PUBLIC",
            password: isPrivate ? password : nil
        )
        let passwordLog = request.password == nil ? "nil" : "********"
        print("""
✅ [Expedition] joinExpedition payload
- expeditionId: \(request.expeditionId)
- expeditionVisibility: \(request.expeditionVisibility)
- password: \(passwordLog)
""")
        print("✅ [Expedition] joinExpedition start: POST /api/expeditions/join")
        isJoiningExpedition = true

        networkManager.request(
            target: .joinExpedition(request: request),
            decodingType: JoinExpeditionResponseDTO.self
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isJoiningExpedition = false
                self.pendingJoinExpeditionID = nil
                self.pendingJoinExpeditionName = ""
                self.pendingJoinIsPrivate = false
                self.joinPassword = ""

                switch result {
                case .success:
                    print("✅ [Expedition] joinExpedition success: expeditionId=\(expeditionId)")
                    self.joinResultTitle = "가입 완료"
                    self.joinResultMessage = "'\(expeditionName)' 탐험대에 가입되었습니다."
                    self.isShowingJoinResultAlert = true
                    self.refreshMyExpeditions()
                    if self.isShowingSearchResults {
                        self.searchExpeditions()
                    }
                case .failure(let error):
                    print("❌ [Expedition] joinExpedition failed: \(error)")
                    let (title, message) = self.joinFailureAlert(expeditionName: expeditionName, error: error)
                    self.joinResultTitle = title
                    self.joinResultMessage = message
                    self.isShowingJoinResultAlert = true
                }
            }
        }
    }

    private func joinFailureAlert(expeditionName: String, error: NetworkError) -> (String, String) {
        if case let .serverError(_, rawMessage) = error {
            let message = rawMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            if message.contains("비밀번호") || message.contains("암호") {
                return ("잘못된 암호입니다.", "비공개 탐험대에 가입하기 위해 올바른 암호를 입력해주세요.")
            }
            if message.contains("정원") || message.contains("가득") {
                return ("탐험대에 가입할 수 없습니다.", "'\(expeditionName)' 탐험대의 정원이 가득 차 가입할 수 없습니다.")
            }
            if message.contains("최대") || message.contains("가입할 수 없습니다") {
                return ("탐험대에 가입할 수 없습니다.", message)
            }
            return ("탐험대 가입 실패", message.isEmpty ? "잠시 후 다시 시도해 주세요." : message)
        }
        return ("탐험대 가입 실패", "잠시 후 다시 시도해 주세요.")
    }

    private func categoriesForSearchQuery() -> [Bool] {
        if selectedCategories.isEmpty {
            return [true, true, true]
        }
        return [
            selectedCategories.contains("역량 강화"),
            selectedCategories.contains("생활 루틴"),
            selectedCategories.contains("내면 관리")
        ]
    }

    private func filterExpeditions(_ list: [ChallengeExpedition]) -> [ChallengeExpedition] {
        guard !selectedCategories.isEmpty else { return list }
        return list.filter { selectedCategories.contains($0.category) }
    }
}
