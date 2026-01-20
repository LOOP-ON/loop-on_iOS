//
//  ShareJourneyView.swift
//  Loop_On
//
//  Created by 이경민 on 1/20/26.
//

import Foundation
import SwiftUI

struct ShareJourneyView: View {
    @StateObject private var viewModel = ShareJourneyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.98, blue: 0.98)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 컨텐츠 영역
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            photoSection
                                .padding(.top, 24)
                            hashtagSection
                            captionSection
                            visibilitySection
                        }
                    }
                    
                    // 챌린지 업로드 버튼
                    fixedBottomButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // 왼쪽 뒤로 가기 화살표 버튼
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.black)
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("여정 공유하기")
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
                    .font(.system(size: 18, weight: .bold))
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
                    ForEach(0..<viewModel.photos.count, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                            .frame(width: 110, height: 110)
                            .overlay(Image(systemName: "photo")
                            .foregroundStyle(Color.gray))
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Button(action: viewModel.addPhoto) {
                Text("사진 추가 \(viewModel.photos.count)/10")
                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.primaryColorVarient65)))
                    .foregroundStyle(Color.white)
            }
            .padding(.trailing, 20)
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
            .background(Color.white)
            
            Button(action: viewModel.addHashtag) {
                Text("해시태그 직접 추가")
                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.primaryColorVarient65)))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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
                    .scrollContentBackground(.hidden) // 배경색 커스텀을 위해 필수
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
                        .allowsHitTesting(false) // 텍스트 입력 방해 금지
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
    ShareJourneyView()
}
