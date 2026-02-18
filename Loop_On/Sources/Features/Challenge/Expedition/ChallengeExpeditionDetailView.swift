//
//  ChallengeExpeditionDetailView.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import SwiftUI

struct ChallengeExpeditionDetailView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(SessionStore.self) private var session

    let expeditionId: Int
    let expeditionName: String
    let isPrivate: Bool

    private let networkManager = DefaultNetworkManager<ChallengeAPI>()
    private let expeditionNetworkManager = DefaultNetworkManager<ExpeditionAPI>()

    @State private var cards: [ChallengeCard] = []
    @State private var isLoadingCards = false
    @State private var hasLoadedCards = false
    @State private var hasMoreCards = true
    @State private var cardsPage = 0
    private let cardsPageSize = 10
    @State private var isShowingMemberList = false
    @State private var isLoadingMemberList = false
    @State private var hasLoadedMemberList = false
    @State private var memberListErrorMessage: String?
    @State private var memberListIsHost = false
    @State private var memberList: [ChallengeExpeditionMember] = []
    @State private var isShowingDeleteAlert = false
    @State private var isShowingLeaveAlert = false
    @State private var isShowingJoinPrivateAlert = false
    @State private var joinPassword: String = ""
    @State private var isShowingResultAlert = false
    @State private var resultAlertTitle: String = ""
    @State private var resultAlertMessage: String = ""
    @State private var isSubmittingAction = false
    @State private var isShowingSettingModal = false
    @State private var isShowingSettingMemberPicker = false
    @State private var isLoadingSetting = false
    @State private var isSavingSetting = false
    @State private var settingTitle = ""
    @State private var settingUserLimit = 10
    @State private var settingVisibility = "PUBLIC"
    @State private var settingPassword = ""
    @State private var isJoinedState: Bool
    @State private var isAdminState: Bool
    @State private var expeditionNameState: String
    @State private var currentMemberCount = 0
    @State private var maxMemberCount = 0
    @State private var deleteTargetId: Int? = nil

    init(expeditionId: Int, expeditionName: String, isPrivate: Bool, isJoined: Bool, isAdmin: Bool, canJoin _: Bool) {
        self.expeditionId = expeditionId
        self.expeditionName = expeditionName
        self.isPrivate = isPrivate
        _expeditionNameState = State(initialValue: expeditionName)
        _isJoinedState = State(initialValue: isJoined)
        _isAdminState = State(initialValue: isAdmin)
    }

    var body: some View {
        contentView
        .alert(
            deleteAlertTitle,
            isPresented: $isShowingDeleteAlert
        ) {
            Button("취소", role: .cancel) { }
            Button("탐험대 삭제", role: .destructive) {
                performDeleteExpedition()
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
                performWithdrawExpedition()
            }
        } message: {
            Text(leaveAlertMessage)
        }
        .alert(
            "비공개 탐험대",
            isPresented: $isShowingJoinPrivateAlert
        ) {
            TextField("암호를 입력해주세요", text: $joinPassword)
                .keyboardType(.numberPad)
                .onChange(of: joinPassword) { _, newValue in
                    let digitsOnly = newValue.filter { $0.isNumber }
                    if digitsOnly.count > 8 {
                        joinPassword = String(digitsOnly.prefix(8))
                    } else if digitsOnly != newValue {
                        joinPassword = digitsOnly
                    }
                }
            Button("취소", role: .cancel) {
                joinPassword = ""
            }
            Button("탐험대 가입") {
                let trimmed = joinPassword.trimmingCharacters(in: .whitespacesAndNewlines)
                performJoinExpedition(password: trimmed)
            }
        } message: {
            Text("비밀번호를 입력해주세요.")
        }
        .alert(
            resultAlertTitle,
            isPresented: $isShowingResultAlert
        ) {
            Button("확인") {
                isShowingResultAlert = false
            }
        } message: {
            Text(resultAlertMessage)
        }
        .fullScreenCover(isPresented: deleteCoverBinding) {
            deleteConfirmFullScreen
        }
        .sheet(isPresented: $isShowingSettingMemberPicker) {
            ChallengeExpeditionMemberPickerSheet(
                memberCount: $settingUserLimit,
                onClose: { isShowingSettingMemberPicker = false },
                minimumCount: min(max(1, currentMemberCount), 50)
            )
            .presentationDetents([.fraction(0.35)])
        }
        .onAppear {
            loadExpeditionMembersIfNeeded()
            loadExpeditionChallengesIfNeeded()
        }
    }
}

private extension ChallengeExpeditionDetailView {
    var contentView: some View {
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

                cardsScrollView
            }

            bottomActionButton
            memberListOverlay
            settingModalOverlay
        }
    }

    var cardsScrollView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach($cards) { $card in
                    ChallengeCardView(
                        card: $card,
                        onLikeTap: { id, isLiked in expeditionDidToggleLike(id: id, isLiked: isLiked) },
                        onDelete: { id in deleteTargetId = id },
                        onCommentTap: expeditionLoadComments,
                        onLoadMoreComments: expeditionLoadMoreComments,
                        onCommentLike: expeditionLikeComment,
                        onPostComment: expeditionPostComment,
                        onDeleteComment: expeditionDeleteComment
                    )
                    .onAppear {
                        handleCardAppear(currentId: $card.wrappedValue.challengeId)
                    }
                }

                if isLoadingCards {
                    ProgressView()
                        .padding(.vertical, 16)
                } else if cards.isEmpty, hasLoadedCards {
                    Text("탐험대 내 게시물이 없습니다.")
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color("25-Text"))
                        .padding(.vertical, 24)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    var memberListOverlay: some View {
        if isShowingMemberList {
            ChallengeExpeditionMemberListView(
                title: "탐험대 명단",
                memberCountText: memberCountText,
                isHost: memberListIsHost,
                members: memberList,
                isLoading: isLoadingMemberList,
                errorMessage: memberListErrorMessage,
                onClose: { isShowingMemberList = false },
                onRefresh: {
                    loadExpeditionMembers()
                },
                onKick: { userId in
                    performExpelMember(userId: userId)
                },
                onKickCancel: { userId in
                    performCancelExpelMember(userId: userId)
                }
            )
            .zIndex(10)
        }
    }

    @ViewBuilder
    var settingModalOverlay: some View {
        if isShowingSettingModal {
            ChallengeExpeditionSettingModalView(
                title: $settingTitle,
                userLimit: $settingUserLimit,
                currentUsers: currentMemberCount,
                isPublic: Binding(
                    get: { settingVisibility.uppercased() == "PUBLIC" },
                    set: { settingVisibility = $0 ? "PUBLIC" : "PRIVATE" }
                ),
                password: $settingPassword,
                isLoading: isLoadingSetting,
                isSaving: isSavingSetting,
                onClose: { isShowingSettingModal = false },
                onDelete: {
                    isShowingSettingModal = false
                    isShowingDeleteAlert = true
                },
                onOpenMemberPicker: {
                    isShowingSettingMemberPicker = true
                },
                onSave: {
                    saveExpeditionSetting()
                }
            )
            .zIndex(11)
        }
    }

    var deleteCoverBinding: Binding<Bool> {
        Binding(
            get: { deleteTargetId != nil },
            set: { if !$0 { deleteTargetId = nil } }
        )
    }

    var shouldShowJoinActions: Bool {
        !isJoinedState
    }

    var isOwner: Bool {
        isJoinedState && isAdminState
    }

    var topActionTitle: String {
        if shouldShowJoinActions {
            return "탐험대 가입"
        }
        return isOwner ? "탐험대 설정" : "탐험대 탈퇴"
    }

    var bottomActionButton: some View {
        Group {
            if shouldShowJoinActions {
                Button {
                    handleJoinTap()
                } label: {
                    Text("탐험대 가입하기")
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.primaryColorVarient65))
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            } else {
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
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                .padding(.bottom, 30)
            }
        }
    }

    var header: some View {
        HStack(spacing: 8) {
            Button {
                router.pop()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(Color("5-Text"))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(expeditionNameState)
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
                openMemberList()
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
                handleTopActionTap()
            } label: {
                Text(topActionTitle)
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
            .disabled(isSubmittingAction)
        }
        .padding(.vertical, 10)
    }

    var deleteAlertTitle: String {
        "정말로 '\(expeditionNameState)' 탐험대를 삭제할까요?"
    }

    var deleteAlertMessage: String {
        "탐험대를 삭제하면 모든 탐험대 인원은 더 이상 이 탐험대에 접근할 수 없으며, 삭제된 탐험대는 복구할 수 없습니다."
    }

    var leaveAlertTitle: String {
        "정말로 '\(expeditionNameState)' 탐험대를 탈퇴할까요?"
    }

    var leaveAlertMessage: String {
        "탐험대 탈퇴 후에는 이 탐험대의 기록과 활동을 확인할 수 없습니다."
    }

    var memberCountText: String {
        String(format: "%02d/%02d", currentMemberCount, maxMemberCount)
    }

    func openMemberList() {
        isShowingMemberList = true
        if !hasLoadedMemberList && !isLoadingMemberList {
            loadExpeditionMembers()
        }
    }

    func loadExpeditionMembersIfNeeded() {
        guard !hasLoadedMemberList else { return }
        guard !isLoadingMemberList else { return }
        loadExpeditionMembers()
    }

    func loadExpeditionMembers() {
        isLoadingMemberList = true
        memberListErrorMessage = nil
        print("✅ [Expedition] loadExpeditionMembers start: GET /api/expeditions/\(expeditionId)/users")

        expeditionNetworkManager.request(
            target: .getExpeditionMembers(expeditionId: expeditionId),
            decodingType: ExpeditionMemberListResponseDTO.self
        ) { result in
            Task { @MainActor in
                isLoadingMemberList = false
                switch result {
                case .success(let dto):
                    print("✅ [Expedition] loadExpeditionMembers success: isHost=\(dto.isHost), current=\(dto.currentMemberCount), max=\(dto.maxMemberCount), users=\(dto.userList.count)")
                    dto.userList.forEach { user in
                        print("  - userId=\(user.userId), nickname=\(user.nickname), isMe=\(user.isMe), isHost=\(user.isHost), friendStatus=\(user.friendStatus), expeditionUserStatus=\(user.expeditionUserStatus)")
                    }
                    memberListIsHost = dto.isHost
                    currentMemberCount = dto.currentMemberCount
                    maxMemberCount = dto.maxMemberCount
                    hasLoadedMemberList = true
                    memberList = dto.userList.map { user in
                        ChallengeExpeditionMember(
                            id: user.userId,
                            name: user.nickname,
                            profileImageUrl: user.profileImageUrl,
                            isSelf: user.isMe,
                            isLeader: user.isHost,
                            isKickPending: user.expeditionUserStatus.uppercased() != "APPROVED"
                        )
                    }
                case .failure(let error):
                    print("❌ [Expedition] loadExpeditionMembers failed")
                    print("❌ [Expedition] loadExpeditionMembers error detail: \(error)")
                    hasLoadedMemberList = false
                    memberList = []
                    if case let .serverError(statusCode, message) = error,
                       statusCode == 404,
                       message.contains("등록되어있지 않습니다") {
                        memberListErrorMessage = "아직 이 탐험대에 가입되어 있지 않아요.\n가입 후 명단을 확인해 주세요."
                    } else {
                        memberListErrorMessage = "탐험대 명단을 불러오지 못했어요.\n잠시 후 다시 시도해 주세요."
                    }
                }
            }
        }
    }

    func loadExpeditionChallengesIfNeeded() {
        guard !hasLoadedCards else { return }
        loadExpeditionChallenges(reset: true)
    }

    func openSettingModal() {
        isShowingSettingModal = true
        loadExpeditionSetting()
    }

    func loadExpeditionSetting() {
        guard !isLoadingSetting else { return }
        isLoadingSetting = true
        print("✅ [Expedition] loadExpeditionSetting start: GET /api/expeditions/\(expeditionId)")

        expeditionNetworkManager.request(
            target: .getExpeditionSetting(expeditionId: expeditionId),
            decodingType: ExpeditionSettingDTO.self
        ) { result in
            Task { @MainActor in
                isLoadingSetting = false
                switch result {
                case .success(let data):
                    settingTitle = data.title
                    expeditionNameState = data.title
                    settingUserLimit = max(data.capacity, data.currentUsers)
                    settingVisibility = data.visibility.uppercased()
                    settingPassword = data.password ?? ""
                    currentMemberCount = data.currentUsers
                    print("✅ [Expedition] loadExpeditionSetting success: title=\(data.title), visibility=\(data.visibility), userLimit=\(data.capacity)")
                case .failure(let error):
                    print("❌ [Expedition] loadExpeditionSetting failed: \(error)")
                    showResultAlert(
                        title: "탐험대 설정 조회 실패",
                        message: "잠시 후 다시 시도해 주세요."
                    )
                }
            }
        }
    }

    func saveExpeditionSetting() {
        guard !isSavingSetting else { return }
        let trimmedTitle = settingTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            showResultAlert(title: "저장 실패", message: "탐험대 이름을 입력해 주세요.")
            return
        }
        guard settingUserLimit >= currentMemberCount else {
            showResultAlert(
                title: "저장 실패",
                message: "탐험대 인원은 현재 인원(\(currentMemberCount)명) 이상으로 설정해 주세요."
            )
            return
        }
        if settingVisibility.uppercased() != "PUBLIC" {
            let trimmedPassword = settingPassword.trimmingCharacters(in: .whitespacesAndNewlines)
            let isPasswordValid = (4...8).contains(trimmedPassword.count) && trimmedPassword.allSatisfy { $0.isNumber }
            guard isPasswordValid else {
                showResultAlert(title: "저장 실패", message: "비공개 암호는 숫자 4~8자리여야 합니다.")
                return
            }
        }

        isSavingSetting = true
        let request = UpdateExpeditionSettingRequest(
            title: trimmedTitle,
            visibility: settingVisibility.uppercased(),
            password: settingVisibility.uppercased() == "PUBLIC" ? nil : settingPassword.trimmingCharacters(in: .whitespacesAndNewlines),
            userLimit: settingUserLimit
        )
        print("✅ [Expedition] saveExpeditionSetting start: PATCH /api/expeditions/\(expeditionId)")
        expeditionNetworkManager.requestStatusCode(
            target: .updateExpeditionSetting(expeditionId: expeditionId, request: request)
        ) { result in
            Task { @MainActor in
                isSavingSetting = false
                switch result {
                case .success:
                    expeditionNameState = trimmedTitle
                    isShowingSettingModal = false
                    NotificationCenter.default.post(name: .expeditionListNeedsRefresh, object: nil)
                    showResultAlert(
                        title: "저장 완료",
                        message: "탐험대 설정을 저장했습니다."
                    )
                case .failure(let error):
                    print("❌ [Expedition] saveExpeditionSetting failed: \(error)")
                    showResultAlert(
                        title: "저장 실패",
                        message: "잠시 후 다시 시도해 주세요."
                    )
                }
            }
        }
    }

    func loadExpeditionChallenges(reset: Bool = false) {
        if reset {
            cardsPage = 0
            hasMoreCards = true
            hasLoadedCards = false
            cards = []
        }

        guard hasMoreCards else { return }
        guard !isLoadingCards else { return }

        let requestPage = cardsPage
        isLoadingCards = true
        print("✅ [Expedition] loadExpeditionChallenges start: GET /api/expeditions/\(expeditionId)/challenges?page=\(requestPage)&size=\(cardsPageSize)")

        expeditionNetworkManager.request(
            target: .getExpeditionChallenges(
                expeditionId: expeditionId,
                page: requestPage,
                size: cardsPageSize,
                sort: ["createdAt,desc"]
            ),
            decodingType: ExpeditionChallengePageDTO.self
        ) { result in
            Task { @MainActor in
                isLoadingCards = false
                hasLoadedCards = true
                switch result {
                case .success(let page):
                    let mapped = page.content.map { challengeCard(from: $0) }
                    if requestPage == 0 {
                        cards = mapped
                    } else {
                        cards.append(contentsOf: mapped)
                    }
                    let isLastPage = page.last ?? (mapped.count < cardsPageSize)
                    hasMoreCards = !isLastPage
                    if hasMoreCards {
                        cardsPage = requestPage + 1
                    }
                    print("✅ [Expedition] loadExpeditionChallenges success: page=\(requestPage), received=\(mapped.count), hasMore=\(hasMoreCards)")
                case .failure(let error):
                    print("❌ [Expedition] loadExpeditionChallenges failed: \(error)")
                }
            }
        }
    }

    func handleCardAppear(currentId: Int) {
        guard hasMoreCards, !isLoadingCards else { return }
        let threshold = max(cards.count - 2, 0)
        if let idx = cards.firstIndex(where: { $0.challengeId == currentId }), idx >= threshold {
            loadExpeditionChallenges()
        }
    }

    func challengeCard(from dto: ExpeditionChallengeItemDTO) -> ChallengeCard {
        let tags = dto.hashtags.map { $0.hasPrefix("#") ? $0 : "#\($0)" }
        return ChallengeCard(
            challengeId: dto.challengeId,
            title: "\(dto.journeyNumber)번째 여정",
            subtitle: dto.content,
            dateText: formatExpeditionDate(dto.createdAt),
            hashtags: tags,
            authorName: dto.nickName,
            imageUrls: dto.imageUrls,
            profileImageUrl: dto.profileImageUrl,
            isLiked: dto.isLiked,
            likeCount: dto.likeCount,
            isMine: false
        )
    }

    func formatExpeditionDate(_ raw: String) -> String {
        if raw.isEmpty { return "" }
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let withoutFraction = ISO8601DateFormatter()
        withoutFraction.formatOptions = [.withInternetDateTime]
        let parsedDate = withFraction.date(from: raw) ?? withoutFraction.date(from: raw)
        guard let date = parsedDate else { return raw }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    // MARK: - 댓글/좋아요 (ChallengeAPI)

    func expeditionDidToggleLike(id: Int, isLiked: Bool) {
        guard let idx = cards.firstIndex(where: { $0.challengeId == id }) else { return }
        cards[idx].isLiked = isLiked
        let apiIsLiked = !isLiked
        let request = ChallengeLikeRequestDTO(isLiked: apiIsLiked)
        networkManager.request(
            target: ChallengeAPI.likeChallenge(challengeId: id, request: request),
            decodingType: ChallengeLikeDataDTO.self
        ) { result in
            Task { @MainActor in
                guard let idx = cards.firstIndex(where: { $0.challengeId == id }) else { return }
                switch result {
                case .success:
                    if isLiked {
                        cards[idx].likeCount += 1
                    } else {
                        cards[idx].likeCount = max(0, cards[idx].likeCount - 1)
                    }
                case .failure:
                    cards[idx].isLiked.toggle()
                }
            }
        }
    }

    func expeditionLoadComments(for cardId: Int, completion: @escaping ([ChallengeComment]) -> Void) {
        networkManager.request(
            target: ChallengeAPI.getChallengeComments(challengeId: cardId, page: 0, size: 50, sort: nil),
            decodingType: ChallengeCommentsPageDTO.self
        ) { result in
            Task { @MainActor in
                switch result {
                case .success(let page):
                    completion(ChallengePlazaViewModel.flattenComments(from: page.content))
                case .failure:
                    completion([])
                }
            }
        }
    }

    func expeditionLoadMoreComments(challengeId: Int, page: Int, completion: @escaping ([ChallengeComment], Bool) -> Void) {
        networkManager.request(
            target: ChallengeAPI.getChallengeComments(challengeId: challengeId, page: page, size: 20, sort: nil),
            decodingType: ChallengeCommentsPageDTO.self
        ) { result in
            Task { @MainActor in
                switch result {
                case .success(let pageDto):
                    let comments = ChallengePlazaViewModel.flattenComments(from: pageDto.content)
                    let hasMore = pageDto.hasNext ?? !(pageDto.last ?? true)
                    completion(comments, hasMore)
                case .failure:
                    completion([], false)
                }
            }
        }
    }

    func expeditionPostComment(challengeId: Int, content: String, parentId: Int, replyToName: String?, completion: @escaping (Result<ChallengeComment, Error>) -> Void) {
        let request = CommentPostRequestDTO(content: content, parentId: parentId == 0 ? nil : parentId)
        networkManager.request(
            target: ChallengeAPI.postComment(challengeId: challengeId, request: request),
            decodingType: CommentPostDataDTO.self
        ) { result in
            Task { @MainActor in
                switch result {
                case .success(let data):
                    let author = (session.currentUserNickname.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty ? "나" : session.currentUserNickname
                    let comment = ChallengeComment(
                        commentId: data.commentId,
                        authorName: author,
                        content: content,
                        isReply: parentId != 0,
                        replyToName: parentId != 0 ? replyToName : nil,
                        isMine: true,
                        isLiked: false,
                        likeCount: 0
                    )
                    completion(.success(comment))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func expeditionDeleteComment(challengeId: Int, commentId: Int, completion: @escaping (Bool) -> Void) {
        networkManager.request(
            target: ChallengeAPI.deleteComment(challengeId: challengeId, commentId: commentId),
            decodingType: String.self
        ) { result in
            Task { @MainActor in
                completion((try? result.get()) != nil)
            }
        }
    }

    func expeditionLikeComment(commentId: Int, isLiked: Bool, completion: @escaping (Bool) -> Void) {
        let apiIsLiked = !isLiked
        let request = ChallengeLikeRequestDTO(isLiked: apiIsLiked)
        networkManager.request(
            target: ChallengeAPI.likeComment(commentId: commentId, request: request),
            decodingType: CommentLikeDataDTO.self
        ) { result in
            Task { @MainActor in
                switch result {
                case .success:
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }

    func handleTopActionTap() {
        if shouldShowJoinActions {
            handleJoinTap()
            return
        }

        if isAdminState {
            openSettingModal()
        } else {
            isShowingLeaveAlert = true
        }
    }

    func handleJoinTap() {
        guard !isSubmittingAction else { return }
        if isPrivate {
            joinPassword = ""
            isShowingJoinPrivateAlert = true
        } else {
            performJoinExpedition(password: nil)
        }
    }

    func performDeleteExpedition() {
        guard !isSubmittingAction else { return }
        isSubmittingAction = true
        expeditionNetworkManager.requestStatusCode(
            target: .deleteExpedition(expeditionId: expeditionId)
        ) { result in
            Task { @MainActor in
                isSubmittingAction = false
                switch result {
                case .success:
                    NotificationCenter.default.post(name: .expeditionListNeedsRefresh, object: nil)
                    router.pop()
                case .failure:
                    showResultAlert(
                        title: "탐험대 삭제 실패",
                        message: "잠시 후 다시 시도해 주세요."
                    )
                }
            }
        }
    }

    func performWithdrawExpedition() {
        guard !isSubmittingAction else { return }
        isSubmittingAction = true
        expeditionNetworkManager.requestStatusCode(
            target: .withdrawExpedition(expeditionId: expeditionId)
        ) { result in
            Task { @MainActor in
                isSubmittingAction = false
                switch result {
                case .success:
                    NotificationCenter.default.post(name: .expeditionListNeedsRefresh, object: nil)
                    router.pop()
                case .failure:
                    showResultAlert(
                        title: "탐험대 탈퇴 실패",
                        message: "잠시 후 다시 시도해 주세요."
                    )
                }
            }
        }
    }

    func performJoinExpedition(password: String?) {
        guard !isSubmittingAction else { return }
        isSubmittingAction = true
        isShowingJoinPrivateAlert = false

        let request = JoinExpeditionRequest(
            expeditionId: expeditionId,
            expeditionVisibility: isPrivate ? "PRIVATE" : "PUBLIC",
            password: isPrivate ? password : nil
        )

        expeditionNetworkManager.request(
            target: .joinExpedition(request: request),
            decodingType: JoinExpeditionResponseDTO.self
        ) { result in
            Task { @MainActor in
                isSubmittingAction = false
                joinPassword = ""
                switch result {
                case .success:
                    isJoinedState = true
                    NotificationCenter.default.post(name: .expeditionListNeedsRefresh, object: nil)
                    showResultAlert(
                        title: "가입 완료",
                        message: "'\(expeditionNameState)' 탐험대에 가입되었습니다."
                    )
                case .failure(let error):
                    let (title, message) = joinFailureAlert(error: error)
                    showResultAlert(title: title, message: message)
                }
            }
        }
    }

    func performExpelMember(userId: Int) {
        guard !isSubmittingAction else { return }
        isSubmittingAction = true
        print("✅ [Expedition] expelMember start: PATCH /api/expeditions/\(expeditionId)/expel, userId=\(userId)")

        expeditionNetworkManager.requestStatusCode(
            target: .expelMember(
                expeditionId: expeditionId,
                request: ExpeditionExpelRequest(userId: userId)
            )
        ) { result in
            Task { @MainActor in
                isSubmittingAction = false
                switch result {
                case .success:
                    print("✅ [Expedition] expelMember success: userId=\(userId)")
                    loadExpeditionMembers()
                    showResultAlert(
                        title: "퇴출 완료",
                        message: "탐험대원을 퇴출했습니다."
                    )
                case .failure(let error):
                    print("❌ [Expedition] expelMember failed: \(error)")
                    let message: String
                    if case let .serverError(_, rawMessage) = error {
                        let trimmed = rawMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        message = trimmed.isEmpty ? "잠시 후 다시 시도해 주세요." : trimmed
                    } else {
                        message = "잠시 후 다시 시도해 주세요."
                    }
                    showResultAlert(
                        title: "퇴출 실패",
                        message: message
                    )
                }
            }
        }
    }

    func performCancelExpelMember(userId: Int) {
        guard !isSubmittingAction else { return }
        isSubmittingAction = true
        print("✅ [Expedition] cancelExpelMember start: DELETE /api/expeditions/\(expeditionId)/expel, userId=\(userId)")

        expeditionNetworkManager.requestStatusCode(
            target: .cancelExpelMember(
                expeditionId: expeditionId,
                request: ExpeditionExpelRequest(userId: userId)
            )
        ) { result in
            Task { @MainActor in
                isSubmittingAction = false
                switch result {
                case .success:
                    print("✅ [Expedition] cancelExpelMember success: userId=\(userId)")
                    loadExpeditionMembers()
                    showResultAlert(
                        title: "퇴출 해제 완료",
                        message: "탐험대원의 퇴출 상태를 해제했습니다."
                    )
                case .failure(let error):
                    print("❌ [Expedition] cancelExpelMember failed: \(error)")
                    let message: String
                    if case let .serverError(_, rawMessage) = error {
                        let trimmed = rawMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        message = trimmed.isEmpty ? "잠시 후 다시 시도해 주세요." : trimmed
                    } else {
                        message = "잠시 후 다시 시도해 주세요."
                    }
                    showResultAlert(
                        title: "퇴출 해제 실패",
                        message: message
                    )
                }
            }
        }
    }

    func joinFailureAlert(error: NetworkError) -> (String, String) {
        if case let .serverError(_, rawMessage) = error {
            let message = rawMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            if message.contains("비밀번호") || message.contains("암호") {
                return ("잘못된 암호입니다.", "비공개 탐험대에 가입하기 위해 올바른 암호를 입력해주세요.")
            }
            if message.contains("정원") || message.contains("가득") {
                return ("탐험대에 가입할 수 없습니다.", "'\(expeditionNameState)' 탐험대의 정원이 가득 차 가입할 수 없습니다.")
            }
            if message.contains("최대") || message.contains("가입할 수 없습니다") {
                return ("탐험대에 가입할 수 없습니다.", message)
            }
            return ("탐험대 가입 실패", message.isEmpty ? "잠시 후 다시 시도해 주세요." : message)
        }
        return ("탐험대 가입 실패", "잠시 후 다시 시도해 주세요.")
    }

    func showResultAlert(title: String, message: String) {
        resultAlertTitle = title
        resultAlertMessage = message
        isShowingResultAlert = true
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

                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                        .padding(.top, 4)
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
                            networkManager.requestStatusCode(target: .deleteChallenge(challengeId: targetId)) { result in
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

private struct ChallengeExpeditionSettingModalView: View {
    @Binding var title: String
    @Binding var userLimit: Int
    let currentUsers: Int
    @Binding var isPublic: Bool
    @Binding var password: String
    let isLoading: Bool
    let isSaving: Bool
    let onClose: () -> Void
    let onDelete: () -> Void
    let onOpenMemberPicker: () -> Void
    let onSave: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 0) {
                header
                    .padding(.top, 36)
                    .padding(.bottom, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        nameSection
                        memberSection
                        visibilitySection
                        if !isPublic {
                            passwordSection
                        }
                        deleteSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
                .scrollIndicators(.hidden)
                .overlay {
                    if isLoading {
                        Color.white.opacity(0.55)
                        ProgressView()
                    }
                }

                Divider()

                footerButtons
                    .frame(height: 56)
            }
            .frame(width: 340, height: 560)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("탐험대 설정")
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                .foregroundStyle(Color("5-Text"))

            Text("탐험대 관련 설정을 수정한 후 저장해주세요")
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                .foregroundStyle(Color(.primaryColorVarient65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("탐험대 이름")
            TextField("탐험대 이름 (띄어쓰기 포함 최대 15글자)", text: $title)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .disabled(isLoading || isSaving)
                .onChange(of: title) { _, newValue in
                    if newValue.count > 15 {
                        title = String(newValue.prefix(15))
                    }
                }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
    }

    private var memberSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("탐험대 인원")
            Button(action: onOpenMemberPicker) {
                HStack {
                    Text("\(userLimit)명")
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color("5-Text"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.gray)
                }
            }
            .buttonStyle(.plain)
            .disabled(isLoading || isSaving)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
    }

    private var visibilitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("공개 설정")
            HStack(spacing: 8) {
                toggleButton(title: "공개", isSelected: isPublic) { isPublic = true }
                toggleButton(title: "비공개", isSelected: !isPublic) { isPublic = false }
            }
        }
    }

    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("암호 설정")
            SecureField("암호 입력 (숫자 4~8자리)", text: $password)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .disabled(isLoading || isSaving)
                .onChange(of: password) { _, newValue in
                    let digitsOnly = newValue.filter { $0.isNumber }
                    if digitsOnly.count > 8 {
                        password = String(digitsOnly.prefix(8))
                    } else if digitsOnly != newValue {
                        password = digitsOnly
                    }
                }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
    }

    private var deleteSection: some View {
        Button(action: onDelete) {
            Text("탐험대 삭제하기")
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.primaryColorVarient65))
                )
        }
        .buttonStyle(.plain)
        .disabled(isLoading || isSaving)
    }

    private var footerButtons: some View {
        HStack(spacing: 0) {
            Button("닫기") {
                onClose()
            }
            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
            .foregroundStyle(Color(.systemRed))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            Button("저장") {
                onSave()
            }
            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
            .foregroundStyle((isLoading || isSaving) ? Color.gray.opacity(0.5) : Color(.primaryColorVarient65))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .disabled(isLoading || isSaving)
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
            .foregroundStyle(Color("5-Text"))
    }

    private func toggleButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .foregroundStyle(isSelected ? Color.white : Color("5-Text"))
                .frame(maxWidth: .infinity, minHeight: 32)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color(.primaryColorVarient65) : Color.gray.opacity(0.2))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ChallengeExpeditionDetailView(
        expeditionId: 1,
        expeditionName: "갓생 루틴 공유방",
        isPrivate: true,
        isJoined: true,
        isAdmin: true,
        canJoin: false
    )
    .environment(NavigationRouter())
    .environment(SessionStore())
}
