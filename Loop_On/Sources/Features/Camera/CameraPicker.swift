//
//  CameraPicker.swift
//  Loop_On
//
//  Created by 이경민 on 1/19/26.
//

import Foundation

import SwiftUI
import AVFoundation
import UIKit

final class ReadyImagePickerController: UIImagePickerController {
    var onDidAppear: (() -> Void)?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onDidAppear?()
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var capturedImage: UIImage?
    @Binding var cameraDevice: UIImagePickerController.CameraDevice     // 카메라 전환
    @Binding var takePhotoTrigger: Int
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        #if DEBUG
        print("CAMERA DEBUG: makeUIViewController - sourceType=camera")
        #endif
        let picker = ReadyImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        picker.showsCameraControls = false
        picker.cameraDevice = cameraDevice      // 카메라 전환
        picker.onDidAppear = { [weak picker] in
            guard let picker else { return }
            context.coordinator.handlePickerDidAppear(picker: picker)
        }
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        if uiViewController.cameraDevice != cameraDevice {
            #if DEBUG
            print("CAMERA DEBUG: 카메라 전환 -> \(cameraDevice == .rear ? "rear" : "front")")
            #endif
            uiViewController.cameraDevice = cameraDevice
            context.coordinator.markCameraDeviceSwitched()
        }

        if context.coordinator.lastTakePhotoTrigger != takePhotoTrigger {
            #if DEBUG
            print("CAMERA DEBUG: 셔터 트리거 감지 - trigger=\(takePhotoTrigger), inProgress=\(context.coordinator.isCaptureInProgress)")
            #endif
            context.coordinator.lastTakePhotoTrigger = takePhotoTrigger
            guard !context.coordinator.isCaptureInProgress else { return }
            context.coordinator.requestCapture(picker: uiViewController)
        }
    }

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        var lastTakePhotoTrigger: Int = 0
        var isCaptureInProgress: Bool = false
        private var captureTimeoutWorkItem: DispatchWorkItem?
        private var captureRetryWorkItem: DispatchWorkItem?
        private var captureRetryCount: Int = 0
        private var isPickerReady: Bool = false
        private var pickerReadyAt: Date?
        private var pendingCaptureRequest: Bool = false
        init(_ parent: CameraPicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            #if DEBUG
            print("CAMERA DEBUG: didFinishPickingMediaWithInfo 콜백 수신")
            #endif
            isCaptureInProgress = false
            captureTimeoutWorkItem?.cancel()
            captureTimeoutWorkItem = nil
            captureRetryWorkItem?.cancel()
            captureRetryWorkItem = nil
            captureRetryCount = 0
            if let image = info[.originalImage] as? UIImage {
                #if DEBUG
                print("CAMERA DEBUG: 이미지 추출 성공 - size=\(image.size)")
                #endif
                parent.capturedImage = image
            } else {
                #if DEBUG
                print("CAMERA DEBUG: originalImage 추출 실패")
                #endif
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            #if DEBUG
            print("CAMERA DEBUG: imagePickerControllerDidCancel")
            #endif
            isCaptureInProgress = false
            captureTimeoutWorkItem?.cancel()
            captureTimeoutWorkItem = nil
            captureRetryWorkItem?.cancel()
            captureRetryWorkItem = nil
            captureRetryCount = 0
            parent.isPresented = false
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [AnyHashable : Any]?) {
            #if DEBUG
            print("CAMERA DEBUG: didFinishPickingImage(deprecated) 콜백 수신")
            #endif
            resetCaptureState()
            parent.capturedImage = image
        }

        func resetCaptureState() {
            isCaptureInProgress = false
            captureTimeoutWorkItem?.cancel()
            captureTimeoutWorkItem = nil
            captureRetryWorkItem?.cancel()
            captureRetryWorkItem = nil
            captureRetryCount = 0
        }

        func beginCapture() {
            isCaptureInProgress = true
            captureRetryCount = 0
            scheduleCaptureTimeout()
        }

        func handlePickerDidAppear(picker: UIImagePickerController) {
            isPickerReady = true
            pickerReadyAt = Date()
            #if DEBUG
            print("CAMERA DEBUG: picker viewDidAppear - 캡처 준비 가능")
            #endif
            if pendingCaptureRequest {
                pendingCaptureRequest = false
                requestCapture(picker: picker)
            }
        }

        func markCameraDeviceSwitched() {
            pickerReadyAt = Date()
            #if DEBUG
            print("CAMERA DEBUG: 카메라 디바이스 전환 - 워밍업 타이머 리셋")
            #endif
        }

        func requestCapture(picker: UIImagePickerController) {
            guard isPickerReady else {
                pendingCaptureRequest = true
                #if DEBUG
                print("CAMERA DEBUG: picker 준비 전 캡처 요청 - 대기 처리")
                #endif
                return
            }

            let warmup: TimeInterval = 0.45
            let elapsed = Date().timeIntervalSince(pickerReadyAt ?? .distantPast)
            if elapsed < warmup {
                let delay = warmup - elapsed
                #if DEBUG
                print("CAMERA DEBUG: 카메라 워밍업 대기 \(String(format: "%.2f", delay))초")
                #endif
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak picker] in
                    guard let self, let picker else { return }
                    self.requestCapture(picker: picker)
                }
                return
            }

            beginCapture()
            #if DEBUG
            print("CAMERA DEBUG: takePicture() 호출")
            #endif
            picker.takePicture()
            scheduleCaptureRetry(picker: picker)
        }

        func scheduleCaptureTimeout() {
            captureTimeoutWorkItem?.cancel()
            let item = DispatchWorkItem { [weak self] in
                guard let self else { return }
                if self.isCaptureInProgress {
                    #if DEBUG
                    print("CAMERA DEBUG: 캡처 타임아웃 - inProgress 강제 해제")
                    #endif
                    self.resetCaptureState()
                }
            }
            captureTimeoutWorkItem = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: item)
        }

        func scheduleCaptureRetry(picker: UIImagePickerController) {
            captureRetryWorkItem?.cancel()
            let item = DispatchWorkItem { [weak self, weak picker] in
                guard let self, let picker else { return }
                guard self.isCaptureInProgress else { return }
                guard self.captureRetryCount < 2 else { return }

                self.captureRetryCount += 1
                #if DEBUG
                print("CAMERA DEBUG: capture 재시도 \(self.captureRetryCount)회차")
                #endif
                picker.takePicture()
                self.scheduleCaptureRetry(picker: picker)
            }
            captureRetryWorkItem = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: item)
        }
    }
}
