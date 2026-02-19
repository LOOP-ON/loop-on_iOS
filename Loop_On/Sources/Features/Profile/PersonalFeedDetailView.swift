//
//  PersonalFeedDetailView.swift
//  Loop_On
//
//  개인 화면 그리드에서 썸네일 탭 시 열리는 피드 상세.
//  선택한 피드가 최상단에 오고, 위로 스크롤 = 더 최신, 아래로 스크롤 = 더 이전.
//
import Foundation
import SwiftUI

// MARK: - ViewModel

@MainActor
final class PersonalFeedDetailViewModel: ObservableObject {
    @Published var cards: [ChallengeCard] = []
    @Published var isLoading: Bool = false
    @Published var loadError: String?

    private let nickname: String
    private let isOwner: Bool
    private let networkManager = DefaultNetworkManager<ChallengeAPI>()

    private var page: Int = 0
    private let pageSize: Int = 10
    private var hasMore: Bool = true
    private var isLoadingPage: Bool = false

    init(nickname: String, isOwner: Bool = false) {
        self.nickname = nickname
        self.isOwner = isOwner
    }

    func loadInitial() {
        load(reset: true)
    }

    func loadMoreIfNeeded(currentCardId: Int) {
        guard let index = cards.firstIndex(where: { $0.challengeId == currentCardId }) else { return }
        let thresholdIndex = max(cards.count - 4, 0)
        if index >= thresholdIndex {
            load(reset: false)
        }
    }

    private func load(reset: Bool) {
        guard !isLoadingPage else { return }

        if reset {
            page = 0
            hasMore = true
        } else {
            guard hasMore else { return }
        }

        isLoadingPage = true
        if page == 0 {
            isLoading = true
            loadError = nil
        }

        let target = ChallengeAPI.getUserChallengeDetails(
            nickname: nickname,
            page: page,
            size: pageSize,
            sort: nil
        )

        networkManager.request(
            target: target,
            decodingType: ChallengeFeedPageDTO.self
        ) { [weak self] (result: Result<ChallengeFeedPageDTO, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingPage = false
                self.isLoading = false

                switch result {
                case .success(let pageDTO):
                    let newCards = pageDTO.content.map { Self.challengeCard(from: $0, isOwner: self.isOwner) }
                    if reset {
                        self.cards = newCards
                    } else {
                        self.cards.append(contentsOf: newCards)
                    }

                    let isLast = pageDTO.last ?? newCards.isEmpty
                    self.hasMore = !isLast
                    if !newCards.isEmpty {
                        self.page += 1
                    }

                case .failure(let error):
                    self.loadError = error.localizedDescription
                }
            }
        }
    }

    /// 게시물 삭제 API 호출 후 성공 시 로컬 카드에서 제거
    func deleteChallenge(challengeId: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let target = ChallengeAPI.deleteChallenge(challengeId: challengeId)
        networkManager.requestStatusCode(target: target) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.cards.removeAll { $0.challengeId == challengeId }
                    NotificationCenter.default.post(name: .challengeDeleted, object: nil)
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private static func challengeCard(from dto: ChallengeFeedItemDTO, isOwner: Bool) -> ChallengeCard {
        let dateText = formatFeedDate(dto.createdAt)
        let hashtags = dto.hashtags.map { $0.hasPrefix("#") ? $0 : "#\($0)" }
        return ChallengeCard(
            challengeId: dto.challengeId,
            title: "\(dto.journeySequence)번째 여정",
            subtitle: dto.content,
            dateText: dateText,
            hashtags: hashtags,
            authorName: dto.nickname,
            imageUrls: dto.imageUrls,
            profileImageUrl: dto.profileImageUrl,
            isLiked: dto.isLiked,
            likeCount: dto.likeCount,
            isMine: isOwner || (dto.isMine ?? false)
        )
    }

    private static func formatFeedDate(_ iso: String) -> String {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let withoutFraction = ISO8601DateFormatter()
        withoutFraction.formatOptions = [.withInternetDateTime]
        var date = withFraction.date(from: iso) ?? withoutFraction.date(from: iso)
        if date == nil {
            let fallback = DateFormatter()
            fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            fallback.locale = Locale(identifier: "en_US_POSIX")
            date = fallback.date(from: iso)
        }
        if date == nil {
            let fallback = DateFormatter()
            fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            fallback.locale = Locale(identifier: "en_US_POSIX")
            date = fallback.date(from: iso)
        }
        guard let date = date else {
            return iso.replacingOccurrences(of: "T", with: " ")
        }
        let out = DateFormatter()
        out.dateFormat = "yyyy.MM.dd HH:mm"
        out.locale = Locale(identifier: "ko_KR")
        return out.string(from: date)
    }
}

// MARK: - View

struct PersonalFeedDetailView: View {
    /// 피드를 불러올 사용자 닉네임
    let nickname: String
    /// 그리드에서 선택한 피드의 challengeId
    let selectedChallengeId: Int
    let onClose: () -> Void

    @StateObject private var viewModel: PersonalFeedDetailViewModel
    @State private var didScrollToSelected = false
    /// 게시물 삭제 확인 팝업용 타겟 ID
    @State private var deleteTargetId: Int? = nil

    init(nickname: String, selectedChallengeId: Int, isOwnFeed: Bool = false, onClose: @escaping () -> Void) {
        self.nickname = nickname
        self.selectedChallengeId = selectedChallengeId
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: PersonalFeedDetailViewModel(nickname: nickname, isOwner: isOwnFeed))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.cards) { card in
                                ChallengeCardView(
                                    card: .constant(card),
                                    onLikeTap: nil,
                                    onEdit: nil,
                                    onDelete: { id in
                                        deleteTargetId = id
                                    },
                                    onCommentTap: nil,
                                    onLoadMoreComments: nil,
                                    onCommentLike: nil,
                                    onPostComment: nil,
                                    onDeleteComment: nil,
                                    onOpenOtherProfile: nil
                                )
                                .id(card.challengeId)
                                .onAppear {
                                    if !didScrollToSelected && card.challengeId == selectedChallengeId {
                                        proxy.scrollTo(card.challengeId, anchor: .top)
                                        didScrollToSelected = true
                                    }
                                    viewModel.loadMoreIfNeeded(currentCardId: card.challengeId)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                    .scrollIndicators(.hidden)
                    .onAppear {
                        viewModel.loadInitial()
                    }
                }
            }
        }
        // 게시물 삭제 확인: CommonPopupView와 동일한 디자인으로 통일
        .fullScreenCover(isPresented: Binding(
            get: { deleteTargetId != nil },
            set: { if !$0 { deleteTargetId = nil } }
        )) {
            ZStack {
                CommonPopupView(
                    isPresented: Binding(
                        get: { deleteTargetId != nil },
                        set: { if !$0 { deleteTargetId = nil } }
                    ),
                    title: "정말로 게시물을 삭제하시겠습니까?",
                    message: "삭제 시 게시물이 영구적으로 삭제되며, 복구할 수 없습니다.",
                    leftButtonText: "취소",
                    rightButtonText: "삭제",
                    leftAction: { deleteTargetId = nil },
                    rightAction: {
                        if let id = deleteTargetId {
                            viewModel.deleteChallenge(challengeId: id) { result in
                                deleteTargetId = nil
                                if case .success = result {
                                    if viewModel.cards.isEmpty {
                                        onClose()
                                    }
                                }
                            }
                        }
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationBackground(.clear)
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            Button {
                onClose()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("5-Text"))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 164, height: 40)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
    }

}

#Preview {
    PersonalFeedDetailView(
        nickname: "서리",
        selectedChallengeId: 1,
        onClose: {}
    )
}
