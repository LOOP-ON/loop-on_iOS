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
    private let networkManager = DefaultNetworkManager<ChallengeAPI>()

    private var page: Int = 0
    private let pageSize: Int = 10
    private var hasMore: Bool = true
    private var isLoadingPage: Bool = false

    init(nickname: String) {
        self.nickname = nickname
    }

    func loadInitial() {
        #if DEBUG
        // 디버그 빌드에서는 네트워크 대신 더미 피드 사용 (UI 확인용)
        if cards.isEmpty {
            cards = ChallengeCard.samplePlaza
        }
        return
        #endif
        load(reset: true)
    }

    func loadMoreIfNeeded(currentCardId: Int) {
        #if DEBUG
        // 디버그 빌드에서는 더미 데이터만 사용하므로 추가 로딩 없음
        return
        #endif
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
                    let newCards = pageDTO.content.map { Self.challengeCard(from: $0) }
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
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    /// DTO → 카드 변환 (ChallengePlazaViewModel과 동일한 스타일)
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
            likeCount: dto.likeCount,
            isMine: dto.isMine ?? false
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

    init(nickname: String, selectedChallengeId: Int, onClose: @escaping () -> Void) {
        self.nickname = nickname
        self.selectedChallengeId = selectedChallengeId
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: PersonalFeedDetailViewModel(nickname: nickname))
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
        // 게시물 삭제 확인: 전체 화면(세이프에어리어·탭바 포함) 덮고, 팝업은 화면 정중앙
        .fullScreenCover(isPresented: Binding(
            get: { deleteTargetId != nil },
            set: { if !$0 { deleteTargetId = nil } }
        )) {
            deleteConfirmFullScreen
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

// MARK: - Delete Confirm Popup (전체 화면 + 정중앙)

extension PersonalFeedDetailView {
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

                    // 텍스트와 버튼 영역을 시각적으로 구분하는 상단 구분선 (카드 양끝까지)
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                        .padding(.top, 4)
                        // VStack 전체에 걸린 .padding(.horizontal, 24)를 상쇄해서 팝업 안쪽 양끝까지 라인 확장
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
                            viewModel.deleteChallenge(challengeId: targetId) { _ in
                                deleteTargetId = nil
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

#Preview {
    PersonalFeedDetailView(
        nickname: "서리",
        selectedChallengeId: 1,
        onClose: {}
    )
}
