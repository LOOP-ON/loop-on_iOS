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

class ShareJourneyViewModel: ObservableObject {
    // UI와 바인딩될 데이터들
    @Published var photos: [UIImage] = []
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
    var journeyId: Int = 0
    var expeditionId: Int = 0

    private let challengeNetworkManager = DefaultNetworkManager<ChallengeAPI>()

    private func handleSelectedItems() {
        let group = DispatchGroup()
            
        for item in selectedItems {
            guard photos.count < 10 else { break }
                
            group.enter()
            item.loadTransferable(type: Data.self) { result in
                defer { group.leave() }
                    
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.photos.append(image)
                        }
                    }
                case .failure(let error):
                    print("사진 로드 실패: \(error.localizedDescription)")
                }
            }
        }
        group.notify(queue: .main) {
            self.selectedItems = []
        }
    }
    
    func removePhoto(at index: Int) {
        photos.remove(at: index)
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
    
    // POST /api/challenges 연동
    func uploadChallenge() {
        let hashtagList = Array(selectedHashtags)
        let dto = CreateChallengeRequestDTO(
            hashtagList: hashtagList,
            content: caption,
            journeyId: journeyId,
            expeditionId: expeditionId
        )
        let imageDatas = photos.compactMap { $0.jpegData(compressionQuality: 0.8) }

        print("[챌린지 업로드] 요청 — journeyId: \(journeyId), expeditionId: \(expeditionId), content: \"\(caption)\", hashtags: \(hashtagList), 이미지 수: \(imageDatas.count)")

        challengeNetworkManager.request(
            target: .createChallenge(request: dto, imageDatas: imageDatas),
            decodingType: CreateChallengeDataDTO.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("[챌린지 업로드] 성공 — challengeId: \(data.challengeId)")
                    self?.dismiss?()
                case .failure(let error):
                    print("[챌린지 업로드] 실패: \(error)")
                }
            }
        }
    }

    /// 업로드 성공 시 화면 닫기용 (ShareJourneyView에서 설정)
    var dismiss: (() -> Void)?
}
