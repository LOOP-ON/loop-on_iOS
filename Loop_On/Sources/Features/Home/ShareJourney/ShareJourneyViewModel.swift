//
//  ShareJourneyViewModel.swift
//  Loop_On
//
//  Created by 이경민 on 1/20/26.
//

import Foundation
import SwiftUI
import Combine

class ShareJourneyViewModel: ObservableObject {
    // UI와 바인딩될 데이터들
    @Published var photos: [String] = ["photo1", "photo2", "photo3"] // 테스트용 데이터
    @Published var hashtags: [String] = ["생활루틴", "건강한_생활_만들기", "첫번째_여정", "새해", "갓생루틴_탐험대"]
    @Published var selectedHashtags: Set<String> = [] // 현재 선택된 태그 저장
    @Published var caption: String = ""
    @Published var expeditionSetting: String = "없음"
    
    // 사진 추가 (최대 10장)
    func addPhoto() {
        if photos.count < 10 {
            photos.append("new_photo")
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
    }
    
    // 해시태그 추가 (임시)
    func addHashtag() {
        hashtags.append("직접 입력")
    }
    
    // API 업로드 시뮬레이션
    func uploadChallenge() {
        print("업로드 시작: \(caption), 태그: \(hashtags)")
        // URLSession 또는 Alamofire 로직이 여기에 들어갑니다.
    }
}
