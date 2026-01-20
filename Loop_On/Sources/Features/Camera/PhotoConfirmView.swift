//
//  PhotoConfirmView.swift
//  Loop_On
//
//  Created by 이경민 on 1/19/26.
//

import Foundation
import SwiftUI

struct PhotoConfirmView: View {
    let image: UIImage
    let routineTitle: String

    var onRetake: () -> Void
    var onConfirm: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color(red: 51/255, green: 47/255, blue: 46/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 상단 텍스트 영역
                VStack(spacing: 12) {
                    HStack {
                        Button(action: onDismiss) {
                            Image("back_arrow")
                                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                                .foregroundStyle(Color.white)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)

                    Text("이 사진으로 인증할까요?")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .padding(.top, 20)

                    Text(routineTitle)
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                        .foregroundStyle(Color(.primaryColorVarient65))

                    Text("사진이 흔들렸다면 다시 촬영해주세요.")
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                        .foregroundStyle(Color.white.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)

                // 이미지 영역
                ZStack {
                    Color.white
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipped()
                }
                .frame(maxWidth: .infinity)
                .layoutPriority(1) // 이미지가 중앙 공간을 우선적으로 차지하도록 설정

                // 하단 버튼 영역
                HStack(spacing: 16) {
                    Button(action: onRetake) {
                        Text("다시 찍기")
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(.primaryColorVarient65).opacity(0.6))
                            .cornerRadius(12)
                    }

                    Button(action: onConfirm) {
                        Text("인증 완료하기")
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(.primaryColorVarient65))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    PhotoConfirmView(
        image: UIImage(systemName: "photo")!,
        routineTitle: "아침에 일어나 물 한 컵 마시기",
        onRetake: {
            print("다시 찍기")
        },
        onConfirm: {
            print("인증 완료하기")
        },
        onDismiss: {
            print("닫기")
        }
    )
}

