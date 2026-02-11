//
//  ShareJourneyView.swift
//  Loop_On
//
//  Created by 이경민 on 1/20/26.
//

import Foundation
import SwiftUI
import PhotosUI

struct ShareJourneyView: View {
    /// 수정 모드일 때 기존 챌린지 ID (nil이면 새로 올리기)
    private let editChallengeId: Int?
    @StateObject private var viewModel: ShareJourneyViewModel
    @Environment(\.dismiss) private var dismiss

    init(editChallengeId: Int? = nil) {
        self.editChallengeId = editChallengeId
        _viewModel = StateObject(wrappedValue: ShareJourneyViewModel(editChallengeId: editChallengeId))
    }

    private var isEditMode: Bool { editChallengeId != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.98, blue: 0.98)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            photoSection
                                .padding(.top, 24)
                            hashtagSection
                            captionSection
                            visibilitySection
                        }
                    }

                    fixedBottomButton
                }
                if viewModel.isLoadingDetail {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    ProgressView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.dismiss = { dismiss() }
                viewModel.loadChallengeDetailIfNeeded()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.black)
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(isEditMode ? "챌린지 수정" : "여정 공유하기")
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                        .foregroundStyle(Color.black)
                }
            }
        }
    }

    // 하단 고정 버튼 섹션
    private var fixedBottomButton: some View {
        VStack {
            Button(action: viewModel.uploadChallenge) {
                Text("챌린지 업로드")
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.primaryColorVarient65))
                    )
                    .foregroundStyle(Color.white)
                    
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 10)
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
    }

    private var photoSection: some View {
        VStack(alignment: .trailing, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.photos.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: viewModel.photos[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 110, height: 110)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Button(action: { viewModel.removePhoto(at: index) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 30))
                                    .foregroundStyle(.white, .black.opacity(0.4))
                                    .padding(4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            PhotosPicker(
                selection: $viewModel.selectedItems,
                maxSelectionCount: 10 - viewModel.photos.count,
                matching: .images
            ) {
                Text("사진 추가 \(viewModel.photos.count)/10")
                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.primaryColorVarient65)))
                    .foregroundStyle(Color.white)
            }
            .padding(.trailing, 20)
            .disabled(viewModel.photos.count >= 10)
        }
    }

    private var hashtagSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("해시태그 설정")
                .font(.system(size: 18))
            
            FlowLayout(items: viewModel.hashtags) { tag in
                let isSelected = viewModel.selectedHashtags.contains(tag)
                
                HStack(spacing: 4) {
                    Text("#\(tag)")
                    Button(action: { viewModel.removeHashtag(tag) }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color(.primaryColor55) : Color(.primaryColorVarient95))
                .foregroundStyle(isSelected ? Color.white : Color(.primaryColor55))
                .clipShape(Capsule())
                .onTapGesture {
                    viewModel.toggleSelection(tag)
                }
            }
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            
            Button(action: viewModel.prepareAddHashtag) {
                Text("해시태그 직접 추가")
                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewModel.hashtags.count >= 5 ? Color.gray.opacity(0.4) : Color(.primaryColorVarient65))
                    )
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .disabled(viewModel.hashtags.count >= 5)
        }
        .padding(.horizontal, 20)
        .alert("해시태그 추가", isPresented: $viewModel.isShowingHashtagAlert) {
            TextField("추가할 태그를 입력하세요", text: $viewModel.newHashtagInput)
            Button("추가", action: viewModel.confirmAddHashtag)
            Button("취소", role: .cancel) { viewModel.newHashtagInput = "" }
        } message: {
            Text("루틴을 잘 나타내는 태그를 입력해주세요.")
        }
    }

    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("캡션 추가")
                .font(.system(size: 18))
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.caption)
                    .frame(minHeight: 100)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                
                if viewModel.caption.isEmpty {
                    Text("예시 : ~~~")
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .padding(.top, 18)
                        .padding(.leading, 16)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var visibilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("공개 범위")
                .font(.system(size: 18))
            
            HStack {
                Text("탐험대 설정")
                    .foregroundStyle(Color(red: 0.91, green: 0.54, blue: 0.43))
                Spacer()
                Text(viewModel.expeditionSetting)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal, 20)
    }
}

// Preview
#Preview {
    let viewModel = ShareJourneyViewModel()
    if let dummyImage = UIImage(systemName: "photo.on.rectangle.angled") {
        viewModel.photos = [dummyImage, dummyImage]
    }
    
    return ShareJourneyView()
}
