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
    let progressId: Int
    @Binding var isPresented: Bool
    var onCertificationSuccess: (() -> Void)? = nil

    // MARK: - State
    @State private var isShutterPressed = false
    @State private var cameraPosition: UIImagePickerController.CameraDevice = .rear
    @State private var rotationAngle: Double = 0
    @State private var showPreview = false
    @State private var capturedImage: UIImage? = nil
    @State private var takePhotoTrigger = 0
    @State private var isSubmitting = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var captureErrorMessage: String?
    private let networkManager = DefaultNetworkManager<HomeAPI>()

    var body: some View {
        ZStack {
            // 촬영 결과 확인 화면
            if showPreview, let image = capturedImage {
                PhotoConfirmView(
                    image: image,
                    routineTitle: routineTitle,
                    isSubmitting: isSubmitting,
                    onRetake: {
                        guard !isSubmitting else { return }
                        capturedImage = nil
                        showPreview = false
                    },
                    onConfirm: {
                        certifyRoutine(image: image)
                    },
                    onDismiss: {
                        guard !isSubmitting else { return }
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
        .onChange(of: capturedImage) { _, _ in
            updatePreviewIfNeeded()
        }
        .onChange(of: captureErrorMessage) { _, newValue in
            guard let message = newValue, !message.isEmpty else { return }
            errorMessage = message
            showErrorAlert = true
            captureErrorMessage = nil
        }
        .alert("인증 실패", isPresented: $showErrorAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Live Camera View
    private var cameraLiveView: some View {
        ZStack {
            CameraPicker(
                isPresented: $isPresented,
                capturedImage: $capturedImage,
                captureErrorMessage: $captureErrorMessage,
                cameraDevice: $cameraPosition,
                takePhotoTrigger: $takePhotoTrigger
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
                        guard !isSubmitting else { return }
                        #if DEBUG
                        print("CAMERA DEBUG: 셔터 버튼 탭 - takePhotoTrigger=\(takePhotoTrigger + 1)")
                        #endif
                        takePhotoTrigger += 1
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
                        guard !isSubmitting else { return }
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

    private func updatePreviewIfNeeded() {
        if capturedImage != nil {
            #if DEBUG
            print("CAMERA DEBUG: capturedImage 변경 감지 -> 미리보기 전환")
            #endif
            showPreview = true
        }
    }

    private func certifyRoutine(image: UIImage) {
        guard !isSubmitting else { return }
        guard progressId > 0 else {
            errorMessage = "인증할 루틴 정보를 찾지 못했어요."
            showErrorAlert = true
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            errorMessage = "이미지 처리에 실패했어요."
            showErrorAlert = true
            return
        }

        isSubmitting = true
        let fileName = "routine_\(progressId)_\(Int(Date().timeIntervalSince1970)).jpg"
        networkManager.request(
            target: .certifyRoutine(
                progressId: progressId,
                imageData: imageData,
                fileName: fileName,
                mimeType: "image/jpeg"
            ),
            decodingType: RoutineCertifyData.self
        ) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success(let certifyData):
                    #if DEBUG
                    print("CAMERA DEBUG: 인증 API 성공 - progressId=\(certifyData.progressId), status=\(certifyData.status)")
                    #endif
                    onCertificationSuccess?()
                    isPresented = false
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    CameraView(
        routineTitle: "아침에 일어나 물 한 컵 마시기",
        routineIndex: 1,
        progressId: 1,
        isPresented: .constant(true)
    )
}
