//
//  ShareJourneyViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/20/26.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI
import UniformTypeIdentifiers

class ShareJourneyViewModel: ObservableObject {
    // UI와 바인딩될 데이터들
    @Published var photos: [UIImage] = []
    /// 수정 모드에서 로드한 이미지의 원본 URL (photos와 1:1, 새로 추가한 사진은 빈 문자열)
    @Published var photoOriginURLs: [String] = []
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            if !selectedItems.isEmpty {
                handleSelectedItems()
            }
        }
    }
    @Published var hashtags: [String] = ["생활루틴", "건강한_생활_만들기", "첫번째_여정", "새해", "갓생루틴_탐험대"]
    @Published var selectedHashtags: Set<String> = [] // 현재 선택된 태그 저장
    // 해시 태그 추가 입력을 위한 상태 변수
    @Published var isShowingHashtagAlert = false
    @Published var newHashtagInput = ""
    
    @Published var caption: String = ""
    @Published var expeditionSetting: String = "없음"
    /// API 연동 시 사용. 화면 진입 시 주입 가능 (기본 0)
    @Published var journeyId: Int = 0
    @Published var expeditionId: Int = 0

    /// 수정 모드: 값이 있으면 기존 챌린지 로드 후 수정 API 호출
    var editChallengeId: Int?
    @Published var isLoadingDetail: Bool = false
    @Published var loadDetailError: String?
    @Published var isShowingDuplicateChallengeAlert = false
    @Published var isShowingInputValidationAlert = false
    
    @Published var myExpeditions: [ChallengeExpeditionListItemDTO] = [] // 내 탐험대 리스트

    private let challengeNetworkManager = DefaultNetworkManager<ChallengeAPI>()
    private let expeditionNetworkManager = DefaultNetworkManager<ExpeditionAPI>()

    init(journeyId: Int = 0, editChallengeId: Int? = nil) {
        self.journeyId = journeyId
        self.editChallengeId = editChallengeId
    }

    private func handleSelectedItems() {
        guard !selectedItems.isEmpty else { return }
        let items = selectedItems
        
        Task {
            for item in items {
                if await MainActor.run(body: { self.photos.count >= 10 }) { break }
                
                // Data로 로드 시도
                do {
                    if let data = try await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            self.photos.append(image)
                            self.photoOriginURLs.append("")
                        }
                    } else {
                         print("DEBUG: 사진 로드 실패 (Data 로드 불가 혹은 UIImage 변환 실패)")
                    }
                } catch {
                    print("DEBUG: 사진 로드 에러: \(error.localizedDescription)")
                }
            }
            await MainActor.run { self.selectedItems = [] }
        }
    }
    
    func removePhoto(at index: Int) {
        guard index < photos.count else { return }
        photos.remove(at: index)
        if index < photoOriginURLs.count {
            photoOriginURLs.remove(at: index)
        }
    }
    
    // 해시태그 선택
    func toggleSelection(_ tag: String) {
        if selectedHashtags.contains(tag) {
            selectedHashtags.remove(tag)
        } else {
            selectedHashtags.insert(tag)
        }
    }
    
    // 해시태그 삭제
    func removeHashtag(_ tag: String) {
        hashtags.removeAll { $0 == tag }
        selectedHashtags.remove(tag) // 선택 목록에서도 제거
    }
    
    // 해시태그 추가 (임시)
    func addHashtag() {
        hashtags.append("직접 입력")
    }
    
    // 해시태그 추가 버튼을 눌렀을 때 실행
    func prepareAddHashtag() {
        if hashtags.count < 5 {
            isShowingHashtagAlert = true
        } else {
            // 5개 이상일 경우 콘솔 출력 혹은 필요 시 알림 처리
            print("해시태그는 최대 5개까지만 등록할 수 있습니다.")
        }
    }
    
    // 알럿에서 '추가'를 눌렀을 때 실제 배열에 반영
    func confirmAddHashtag() {
        let trimmedTag = newHashtagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 빈 값이 아니고, 중복되지 않았으며, 전체 개수가 5개 미만일 때만 추가
        if !trimmedTag.isEmpty && !hashtags.contains(trimmedTag) && hashtags.count < 5 {
            hashtags.append(trimmedTag)
        }
        
        // 입력창 초기화
        newHashtagInput = ""
    }
    
    // POST /api/challenges 또는 PUT /api/challenges/{id} 연동
    func uploadChallenge() {
        // [Safety Check] journeyId가 0이면 업로드 불가
        guard journeyId > 0 else {
            print("❌ API Error: journeyId가 0입니다. 세션이나 홈 데이터가 로드되지 않았을 수 있습니다.")
            return
        }
        
        // [Validation Check] 사진과 캡션 필수 입력
        if photos.isEmpty || caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            isShowingInputValidationAlert = true
            return
        }
        
        let hashtagList = Array(selectedHashtags)
        let dto = CreateChallengeRequestDTO(
            hashtagList: hashtagList,
            content: caption,
            journeyId: journeyId,
            expeditionId: expeditionId
        )
        let imageDatas = photos.compactMap { $0.jpegData(compressionQuality: 0.8) }

        if let id = editChallengeId {
            let (updateDto, newImageDatas) = buildUpdateRequest()
            print("[챌린지 수정] 요청 — challengeId: \(id), content: \"\(caption)\", hashtags: \(updateDto.hashtagList), remain: \(updateDto.remainImages.count), new: \(newImageDatas.count)")
            challengeNetworkManager.request(
                target: .updateChallenge(challengeId: id, request: updateDto, imageDatas: newImageDatas),
                decodingType: CreateChallengeDataDTO.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleUpdateResult(result)
                }
            }
        } else {
            print("[챌린지 업로드] 요청 — journeyId: \(journeyId), expeditionId: \(expeditionId), content: \"\(caption)\", hashtags: \(hashtagList), 이미지 수: \(imageDatas.count)")
            challengeNetworkManager.request(
                target: .createChallenge(request: dto, imageDatas: imageDatas),
                decodingType: CreateChallengeDataDTO.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleUploadResult(result)
                }
            }
        }
    }

    /// 업로드 성공 시 화면 닫기용 (ShareJourneyView에서 설정)
    var dismiss: (() -> Void)?

    /// 수정 모드일 때 기존 챌린지 상세 로드
    func loadChallengeDetailIfNeeded() {
        guard let id = editChallengeId else { return }
        isLoadingDetail = true
        loadDetailError = nil
        challengeNetworkManager.request(
            target: .getChallengeDetail(challengeId: id),
            decodingType: ChallengeDetailDataDTO.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingDetail = false
                switch result {
                case .success(let dto):
                    self?.applyDetail(dto)
                case .failure(let error):
                    self?.loadDetailError = error.localizedDescription
                }
            }
        }
    }

    private func applyDetail(_ dto: ChallengeDetailDataDTO) {
        caption = dto.content
        let tags = dto.hashtagList.map { $0.hasPrefix("#") ? String($0.dropFirst()) : $0 }
        hashtags = tags
        selectedHashtags = Set(tags)
        expeditionId = dto.expeditionId
        expeditionSetting = dto.expeditionId == 0 ? "없음" : "탐험대 \(dto.expeditionId)"
        loadImages(from: dto.imageList)
    }

    private func loadImages(from urls: [String]) {
        photos = []
        photoOriginURLs = []
        guard !urls.isEmpty else { return }
        let group = DispatchGroup()
        var results: [Int: UIImage] = [:]
        let lock = NSLock()
        for (index, urlString) in urls.enumerated() {
            guard let url = URL(string: urlString) else { continue }
            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    lock.lock()
                    results[index] = image
                    lock.unlock()
                }
                group.leave()
            }.resume()
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            let ordered = (0..<urls.count).compactMap { results[$0] }
            self.photos = ordered
            self.photoOriginURLs = (0..<urls.count).compactMap { i in results[i].map { _ in urls[i] } }
        }
    }

    /// 수정 시 PATCH 요청용 DTO와 새 이미지 데이터 생성
    private func buildUpdateRequest() -> (UpdateChallengeRequestDTO, [Data]) {
        var remainImages: [String] = []
        var remainImagesSequence: [Int] = []
        var newImagesSequence: [Int] = []
        var newImageDatas: [Data] = []
        for (i, url) in photoOriginURLs.enumerated() {
            if !url.isEmpty {
                remainImages.append(url)
                remainImagesSequence.append(i)
            } else {
                newImagesSequence.append(i)
                if let data = photos[safe: i]?.jpegData(compressionQuality: 0.8) {
                    newImageDatas.append(data)
                }
            }
        }
        let hashtagList = Array(selectedHashtags)
        let dto = UpdateChallengeRequestDTO(
            newImagesSequence: newImagesSequence,
            remainImages: remainImages,
            remainImagesSequence: remainImagesSequence,
            hashtagList: hashtagList,
            content: caption,
            journeyId: journeyId,
            expeditionId: expeditionId
        )
        return (dto, newImageDatas)
    }
    
    // 내 탐험대 목록 가져오기
    func fetchMyExpeditions() {
        expeditionNetworkManager.request(
            target: .getMyExpeditions,
            decodingType: ChallengeMyExpeditionListDTO.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.myExpeditions = response.expeditionGetResponses
                    print("내 탐험대 목록 로드 성공: \(response.expeditionGetResponses.count)개")
                case .failure(let error):
                    print("내 탐험대 목록 로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    private func handleUpdateResult(_ result: Result<CreateChallengeDataDTO, NetworkError>) {
        switch result {
        case .success:
            print("[챌린지 수정] 성공")
            self.dismiss?()
        case .failure(let error):
            print("[챌린지 수정] 실패: \(error)")
        }
    }

    private func handleUploadResult(_ result: Result<CreateChallengeDataDTO, NetworkError>) {
        switch result {
        case .success(let data):
            print("[챌린지 업로드] 성공 — challengeId: \(data.challengeId)")
            self.dismiss?()
        case .failure(let error):
            print("[챌린지 업로드] 실패: \(error)")
            
            // 400 Bad Request & 특정 메시지 확인
            if case .serverError(let statusCode, let message) = error,
               statusCode == 400,
               message == "해당 여정은 이미 챌린지가 존재합니다." {
                self.isShowingDuplicateChallengeAlert = true
            }
        }
    }

}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


