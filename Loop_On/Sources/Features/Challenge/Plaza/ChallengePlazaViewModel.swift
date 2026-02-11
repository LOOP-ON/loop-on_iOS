//
//  ChallengePlazaViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation

final class ChallengePlazaViewModel: ObservableObject {
    @Published var cards: [ChallengeCard] = []
    @Published var isLoading = false
    @Published var loadError: String?
    let emptyMessage: String = "여정 광장에 표시할 여정이 없어요."
    @Published private var commentsByCard: [Int: [ChallengeComment]] = [:]

    private let networkManager = DefaultNetworkManager<ChallengeAPI>()
    private var trendingPage = 0
    private var friendsPage = 0
    private let trendingSize = 1
    private let friendsSize = 3

    init() {}

    /// 피드 조회 (트렌딩 1 : 친구 3 비율로 머지)
    func loadFeed() {
        guard !isLoading else { return }
        isLoading = true
        loadError = nil
        let target = ChallengeAPI.getChallengeFeed(
            trendingPage: trendingPage,
            trendingSize: trendingSize,
            friendsPage: friendsPage,
            friendsSize: friendsSize
        )
        networkManager.request(
            target: target,
            decodingType: ChallengeFeedDataDTO.self,
            completion: { [weak self] (result: Result<ChallengeFeedDataDTO, NetworkError>) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                case .success(let data):
                    let merged = Self.mergeInRatio(
                        trending: data.trendingChallenges.content,
                        friends: data.friendChallenges.content,
                        ratio: (1, 3)
                    )
                    let newCards = merged.map { Self.challengeCard(from: $0) }
                    if self?.trendingPage == 0, self?.friendsPage == 0 {
                        // 첫 로드에서 API 응답이 비어 있으면 더미 피드 표시 (UI 확인용)
                        self?.cards = newCards.isEmpty ? ChallengeCard.samplePlaza : newCards
                    } else {
                        self?.cards.append(contentsOf: newCards)
                    }
                    if !data.trendingChallenges.content.isEmpty {
                        self?.trendingPage += 1
                    }
                    if !data.friendChallenges.content.isEmpty {
                        self?.friendsPage += 1
                    }
                case .failure(let error):
                    self?.loadError = error.localizedDescription
                    if self?.cards.isEmpty == true {
                        self?.cards = ChallengeCard.samplePlaza
                    }
                }
                }
            }
        )
    }

    /// DTO → 카드 변환 (ChallengeCard가 ChallengeFeedItemDTO를 참조하지 않도록 ViewModel에서 처리)
    private static func challengeCard(from dto: ChallengeFeedItemDTO) -> ChallengeCard {
        let dateText = formatFeedDate(dto.createdAt)
        let hashtags = dto.hashtags.map { $0.hasPrefix("#") ? $0 : "#\($0)" }
        return ChallengeCard(
            challengeId: dto.challengeId,
            title: "여정 \(dto.journeySequence)",
            subtitle: dto.content,
            dateText: dateText,
            hashtags: hashtags,
            authorName: dto.nickname,
            imageUrls: dto.imageUrls,
            profileImageUrl: dto.profileImageUrl,
            isLiked: dto.isLiked,
            likeCount: dto.likeCount
        )
    }

    private static func formatFeedDate(_ iso: String) -> String {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let withoutFraction = ISO8601DateFormatter()
        withoutFraction.formatOptions = [.withInternetDateTime]
        let date = withFraction.date(from: iso) ?? withoutFraction.date(from: iso)
        guard let date = date else { return iso }
        let out = DateFormatter()
        out.dateFormat = "yyyy.MM.dd"
        out.locale = Locale(identifier: "ko_KR")
        return out.string(from: date)
    }

    /// 트렌딩 1개 : 친구 3개 비율로 번갈아 배치
    private static func mergeInRatio(
        trending: [ChallengeFeedItemDTO],
        friends: [ChallengeFeedItemDTO],
        ratio: (Int, Int)
    ) -> [ChallengeFeedItemDTO] {
        let (tStep, fStep) = ratio
        var result: [ChallengeFeedItemDTO] = []
        var tIdx = 0
        var fIdx = 0
        while tIdx < trending.count || fIdx < friends.count {
            for _ in 0..<tStep where tIdx < trending.count {
                result.append(trending[tIdx])
                tIdx += 1
            }
            for _ in 0..<fStep where fIdx < friends.count {
                result.append(friends[fIdx])
                fIdx += 1
            }
        }
        return result
    }

    func didToggleLike(id: Int, isLiked: Bool) {
        guard let idx = cards.firstIndex(where: { $0.challengeId == id }) else { return }
        cards[idx].isLiked = isLiked
        let request = ChallengeLikeRequestDTO(isLiked: isLiked)
        let target = ChallengeAPI.likeChallenge(challengeId: id, request: request)
        networkManager.request(
            target: target,
            decodingType: ChallengeLikeDataDTO.self,
            completion: { [weak self] (result: Result<ChallengeLikeDataDTO, NetworkError>) in
                DispatchQueue.main.async {
                    guard let self = self,
                          let idx = self.cards.firstIndex(where: { $0.challengeId == id }) else { return }
                    switch result {
                    case .success:
                        if isLiked {
                            self.cards[idx].likeCount += 1
                        } else {
                            self.cards[idx].likeCount = max(0, self.cards[idx].likeCount - 1)
                        }
                    case .failure:
                        self.cards[idx].isLiked.toggle()
                    }
                }
            }
        )
    }

    func didTapEdit(id: Int) {
        // TODO: API 연결 시 게시물 수정 화면 이동 처리 (id)
    }

    func didTapDelete(id: Int) {
        let target = ChallengeAPI.deleteChallenge(challengeId: id)
        networkManager.requestStatusCode(target: target) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.cards.removeAll { $0.challengeId == id }
                case .failure:
                    break // 실패 시 UI는 유지 (필요 시 loadError 등으로 피드백 가능)
                }
            }
        }
    }

    /// 댓글 목록 조회 (비동기). 캐시 있으면 즉시 completion, 없으면 API 호출 후 completion.
    func loadComments(for cardId: Int, completion: @escaping ([ChallengeComment]) -> Void) {
        if let cached = commentsByCard[cardId] {
            completion(cached)
            return
        }
        let target = ChallengeAPI.getChallengeComments(challengeId: cardId, page: 0, size: 50, sort: nil)
        networkManager.request(
            target: target,
            decodingType: ChallengeCommentsPageDTO.self,
            completion: { [weak self] (result: Result<ChallengeCommentsPageDTO, NetworkError>) in
                DispatchQueue.main.async {
                    let comments: [ChallengeComment]
                    switch result {
                    case .success(let page):
                        comments = page.content.map { Self.challengeComment(from: $0) }
                        self?.commentsByCard[cardId] = comments
                    case .failure:
                        comments = ChallengeComment.sample
                    }
                    completion(comments)
                }
            }
        )
    }

    /// 다음 페이지 댓글 조회 (무한 스크롤). page는 1부터 (0은 최초 로드).
    func loadMoreComments(challengeId: Int, page: Int, completion: @escaping ([ChallengeComment], Bool) -> Void) {
        let target = ChallengeAPI.getChallengeComments(challengeId: challengeId, page: page, size: 20, sort: nil)
        networkManager.request(
            target: target,
            decodingType: ChallengeCommentsPageDTO.self,
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let pageDto):
                        let comments = pageDto.content.map { Self.challengeComment(from: $0) }
                        let hasMore = !(pageDto.last ?? true)
                        completion(comments, hasMore)
                    case .failure:
                        completion([], false)
                    }
                }
            }
        )
    }

    /// 댓글 등록 (성공 시 맨 위에 보여줄 ChallengeComment 반환)
    func postComment(challengeId: Int, content: String, parentId: Int, replyToName: String?, completion: @escaping (Result<ChallengeComment, NetworkError>) -> Void) {
        let request = CommentPostRequestDTO(content: content, parentId: parentId)
        let target = ChallengeAPI.postComment(challengeId: challengeId, request: request)
        networkManager.request(
            target: target,
            decodingType: CommentPostDataDTO.self,
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        let comment = ChallengeComment(
                            commentId: data.commentId,
                            authorName: "나",
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
        )
    }

    /// 댓글 삭제
    func deleteComment(challengeId: Int, commentId: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let target = ChallengeAPI.deleteComment(challengeId: challengeId, commentId: commentId)
        networkManager.request(
            target: target,
            decodingType: String.self,
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        )
    }

    /// 댓글 좋아요/취소
    func likeComment(commentId: Int, isLiked: Bool, completion: @escaping (Bool) -> Void) {
        let request = ChallengeLikeRequestDTO(isLiked: isLiked)
        let target = ChallengeAPI.likeComment(commentId: commentId, request: request)
        networkManager.request(
            target: target,
            decodingType: CommentLikeDataDTO.self,
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            }
        )
    }

    private static func challengeComment(from dto: ChallengeCommentItemDTO) -> ChallengeComment {
        ChallengeComment(
            commentId: dto.commentId,
            authorName: dto.nickName,
            content: dto.content,
            isReply: !(dto.children?.isEmpty ?? true),
            replyToName: nil,
            isMine: false,
            isLiked: false,
            likeCount: dto.likeCount
        )
    }
}
