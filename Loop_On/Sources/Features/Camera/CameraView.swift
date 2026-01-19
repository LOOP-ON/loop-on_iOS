//
//  CameraView.swift
//  Loop_On
//
//  Created by 이경민 on 1/19/26.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI
import UIKit

struct CameraView: View {
    let routineTitle: String
    let routineIndex: Int
    @Binding var isPresented: Bool

    // MARK: - State
    @State private var isShutterPressed = false
    @State private var cameraPosition: UIImagePickerController.CameraDevice = .rear
    @State private var rotationAngle: Double = 0
    @State private var showPreview = false
    @State private var capturedImage: UIImage? = nil

    var body: some View {
        ZStack {
            // 촬영 결과 확인 화면
            if showPreview, let image = capturedImage {
                PhotoConfirmView(
                    image: image,
                    routineTitle: routineTitle,
                    onRetake: {
                        capturedImage = nil
                        showPreview = false
                    },
                    onConfirm: {
                        // TODO: 인증 처리 (업로드 등)
                        isPresented = false
                    },
                    onDismiss: {
                        capturedImage = nil
                        showPreview = false
                    }
                )
            }
            // 실시간 카메라 화면
            else {
                cameraLiveView
            }
        }
        .animation(.easeOut(duration: 0.25), value: showPreview)
    }

    // MARK: - Live Camera View
    private var cameraLiveView: some View {
        ZStack {
            CameraPicker(
                isPresented: $isPresented,
                capturedImage: $capturedImage,
                cameraDevice: $cameraPosition
            )
            .ignoresSafeArea()

            VStack {
                // 상단 헤더
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // 중앙 안내 문구
                VStack(spacing: 8) {
                    Text("사진을 촬영해 인증을 해주세요")
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 28))
                        .foregroundStyle(Color.white)

                    Text(routineTitle)
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                        .foregroundStyle(Color(.primaryColorVarient65))
                }
                .padding(.top, 40)
                .padding(.bottom, 40)

                Spacer()

                // 하단 컨트롤 영역
                ZStack {
                    // 셔터 버튼
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if capturedImage != nil {
                                showPreview = true
                            }
                        }
                    }) {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .padding(6)
                            )
                            .scaleEffect(isShutterPressed ? 0.9 : 1.0)
                            .animation(.easeOut(duration: 0.12), value: isShutterPressed)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isShutterPressed = true
                            }
                            .onEnded { _ in
                                isShutterPressed = false
                            }
                    )

                    // 카메라 전환 버튼
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()

                        withAnimation(.easeInOut(duration: 0.35)) {
                            rotationAngle += 180
                        }

                        cameraPosition = (cameraPosition == .rear) ? .front : .rear
                    }) {
                        Image("camera_switch")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    .padding(.leading, 293)
                }
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    CameraView(
        routineTitle: "아침에 일어나 물 한 컵 마시기",
        routineIndex: 1,
        isPresented: .constant(true)
    )
}
