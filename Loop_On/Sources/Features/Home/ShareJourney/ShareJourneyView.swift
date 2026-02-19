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
    private let bottomContentInset: CGFloat
    private let onClose: (() -> Void)?
    @StateObject private var viewModel: ShareJourneyViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    @State private var isShowingExpeditionPopup = false
    @State private var buttonFrame: CGRect = .zero
    @State private var popupSize: CGSize = .zero

    init(
        journeyId: Int = 0,
        editChallengeId: Int? = nil,
        expeditionId: Int? = nil,
        bottomContentInset: CGFloat = 0,
        onClose: (() -> Void)? = nil
    ) {
        self.editChallengeId = editChallengeId
        self.bottomContentInset = bottomContentInset
        self.onClose = onClose
        let vm = ShareJourneyViewModel(journeyId: journeyId, editChallengeId: editChallengeId)
        vm.journeyId = journeyId
        vm.expeditionId = expeditionId
        _viewModel = StateObject(wrappedValue: vm)
    }

    private var isEditMode: Bool { editChallengeId != nil }
    private var screenBackgroundColor: Color {
        Color(red: 0.98, green: 0.98, blue: 0.98)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                screenBackgroundColor
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
                
                if isShowingExpeditionPopup {
                    expeditionPopup
                }
                if viewModel.isShowingDuplicateChallengeAlert {
                    CommonPopupView(
                        isPresented: $viewModel.isShowingDuplicateChallengeAlert,
                        title: "챌린지 업로드 실패",
                        message: "해당 여정은 이미 챌린지가 존재합니다.",
                        leftButtonText: "확인",
                        leftAction: {
                            viewModel.isShowingDuplicateChallengeAlert = false
                        }
                    )
                }
                
                if viewModel.isShowingInputValidationAlert {
                    CommonPopupView(
                        isPresented: $viewModel.isShowingInputValidationAlert,
                        title: "입력 확인",
                        message: "사진과 캡션을 입력해주세요.",
                        leftButtonText: "확인",
                        leftAction: {
                            viewModel.isShowingInputValidationAlert = false
                        }
                    )
                }
            }
            .coordinateSpace(name: "ShareJourneyZStack")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(
                screenBackgroundColor,
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                // journeyId가 0이라면 세션 확인 및 서버 동기화 시도
                if viewModel.journeyId == 0 {
                    if session.currentJourneyId != 0 {
                        viewModel.journeyId = session.currentJourneyId
                        print("DEBUG: ShareJourneyView - Default journeyId applied from session: \(session.currentJourneyId)")
                    } else {
                        // 세션에도 없으면 서버에서 동기화 시도
                        session.syncCurrentJourneyId { id in
                            if let id = id {
                                viewModel.journeyId = id
                                print("DEBUG: ShareJourneyView - Synced journeyId from server: \(id)")
                            }
                        }
                    }
                }
                viewModel.dismiss = { closeView() }
                viewModel.loadChallengeDetailIfNeeded()
                viewModel.fetchMyExpeditions()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: closeView) {
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
        .background(screenBackgroundColor.ignoresSafeArea())
        .alert(
            "챌린지 업로드 실패",
            isPresented: Binding(
                get: { viewModel.uploadErrorMessage != nil },
                set: { if !$0 { viewModel.uploadErrorMessage = nil } }
            )
        ) {
            Button("확인", role: .cancel) { viewModel.uploadErrorMessage = nil }
        } message: {
            Text(viewModel.uploadErrorMessage ?? "알 수 없는 오류가 발생했어요.")
        }
        .alert("해시태그 추가", isPresented: $viewModel.isShowingHashtagAlert) {
            TextField("추가할 태그를 입력하세요", text: $viewModel.newHashtagInput)
            Button("추가", action: viewModel.confirmAddHashtag)
            Button("취소", role: .cancel) { viewModel.newHashtagInput = "" }
        } message: {
            Text("루틴을 잘 나타내는 태그를 입력해주세요.")
        }
        if viewModel.isShowingHashtagLimitAlert {
            CommonPopupView(
                isPresented: $viewModel.isShowingHashtagLimitAlert,
                title: "해시태그 제한",
                message: "해시태그는 최대 5개까지만 등록할 수 있습니다.",
                leftButtonText: "확인",
                leftAction: {
                    viewModel.isShowingHashtagLimitAlert = false
                }
            )
        }
    }

    private func closeView() {
        if let onClose {
            onClose()
        } else {
            dismiss()
        }
    }

    // 하단 고정 버튼 섹션
    private var fixedBottomButton: some View {
        VStack {
            Button(action: viewModel.uploadChallenge) {
                HStack(spacing: 8) {
                    if viewModel.isUploading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("챌린지 업로드")
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewModel.isUploading ? Color("85") : Color(.primaryColorVarient65))
                )
                .foregroundStyle(Color.white)
                    
            }
            .disabled(viewModel.isUploading)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 10 + bottomContentInset)
        }
        .background(screenBackgroundColor)
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
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            // .disabled(viewModel.hashtags.count >= 5)
        }
        .padding(.horizontal, 20)
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
            
            Button {
                isShowingExpeditionPopup = true
            } label: {
                HStack {
                    Text("탐험대 설정")
                        .foregroundStyle(Color(red: 0.91, green: 0.54, blue: 0.43))
                    Spacer()
                    Text(viewModel.expeditionSetting)
                        .foregroundStyle(Color.gray)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            self.buttonFrame = geo.frame(in: .named("ShareJourneyZStack"))
                        }
                        .onChange(of: geo.frame(in: .named("ShareJourneyZStack"))) { _, newFrame in
                            self.buttonFrame = newFrame
                        }
                }
            )
        }
        .padding(.horizontal, 20)
    }

    private var expeditionPopup: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowingExpeditionPopup = false
                }
            
            VStack(spacing: 0) {
                // 없음
                Button {
                    viewModel.expeditionSetting = "없음"
                    viewModel.expeditionId = nil
                    isShowingExpeditionPopup = false
                } label: {
                    HStack {
                        Text("없음")
                            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                            .foregroundStyle(viewModel.expeditionSetting == "없음" ? Color(red: 0.91, green: 0.54, blue: 0.43) : Color.black)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                    .padding(.horizontal, 12)
                
                // 내 탐험대 리스트
                ForEach(viewModel.myExpeditions.indices, id: \.self) { index in
                    let expedition = viewModel.myExpeditions[index]
                    let isSelected = (viewModel.expeditionId == expedition.expeditionId)
                    
                    Button {
                        viewModel.expeditionSetting = expedition.title
                        viewModel.expeditionId = expedition.expeditionId
                        isShowingExpeditionPopup = false
                    } label: {
                        HStack(spacing: 4) {
                            Text(expedition.title)
                                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                .foregroundStyle(isSelected ? Color(red: 0.91, green: 0.54, blue: 0.43) : Color.black)
                            
                            if expedition.visibility == "PRIVATE" {
                                Image(systemName: "lock")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    
                    // 마지막 아이템이 아니면 구분선 추가
                    if index < viewModel.myExpeditions.count - 1 {
                        Divider()
                            .background(Color.gray.opacity(0.2))
                            .padding(.horizontal, 12)
                    }
                }
            }
            .frame(width: 180)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        self.popupSize = geo.size
                    }
                    .onChange(of: geo.size) { _, newSize in
                        self.popupSize = newSize
                    }
                }
            )
            // 팝업 위치: 버튼의 우측 상단 기준 (X: 버튼 우측 끝 - 팝업 너비/2, Y: 버튼 상단 - 팝업 높이/2 - 간격)
            // position은 뷰의 중심을 배치하므로, 팝업의 중심(width/2, height/2)을 고려해야 함.
            // 원하는 팝업 위치(TopTrailing): (buttonFrame.maxX, buttonFrame.minY - 10)
            // 팝업의 중심 X = 원하는 우측 좌표 - (popupSize.width / 2) = buttonFrame.maxX - (popupSize.width / 2)
            // 팝업의 중심 Y = 원하는 하단 좌표 - (popupSize.height / 2) = (buttonFrame.minY - 10) - (popupSize.height / 2)
            // buttonFrame이 .zero가 아닐 때만 위치 지정 (아니면 중앙)
            .position(
                x: buttonFrame == .zero ? UIScreen.main.bounds.width / 2 : buttonFrame.maxX - (popupSize.width / 2),
                y: buttonFrame == .zero ? UIScreen.main.bounds.height / 2 : buttonFrame.minY - (popupSize.height / 2) - 10
            )
        }
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
