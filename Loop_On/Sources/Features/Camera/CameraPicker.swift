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

private extension UIImagePickerController.CameraDevice {
    var toCapturePosition: AVCaptureDevice.Position {
        self == .front ? .front : .back
    }
}

final class CameraCaptureViewController: UIViewController {
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "loopon.camera.session.queue")
    private var currentInput: AVCaptureDeviceInput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var currentPosition: AVCaptureDevice.Position = .back
    private var isConfigured = false

    var onCapture: ((UIImage?) -> Void)?
    var onCaptureError: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSessionIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    func setInitialPosition(_ position: AVCaptureDevice.Position) {
        currentPosition = position
    }

    func switchCamera(to position: AVCaptureDevice.Position) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard position != self.currentPosition else { return }
            self.currentPosition = position
            self.reconfigureInput(position: position)
        }
    }

    func capturePhoto() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.session.isRunning else {
                #if DEBUG
                print("CAMERA DEBUG: capturePhoto 무시 - session not running")
                #endif
                DispatchQueue.main.async { [weak self] in
                    self?.onCaptureError?("카메라 준비 중입니다. 잠시 후 다시 시도해주세요.")
                }
                return
            }
            guard let connection = self.photoOutput.connection(with: .video),
                  connection.isEnabled,
                  connection.isActive else {
                #if DEBUG
                print("CAMERA DEBUG: capturePhoto 무시 - video connection inactive")
                #endif
                DispatchQueue.main.async { [weak self] in
                    #if targetEnvironment(simulator)
                    self?.onCaptureError?("시뮬레이터에서는 카메라 촬영이 제한될 수 있어요. 실기기에서 테스트해주세요.")
                    #else
                    self?.onCaptureError?("카메라 연결이 활성화되지 않았어요. 잠시 후 다시 시도해주세요.")
                    #endif
                }
                return
            }

            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off

            #if DEBUG
            print("CAMERA DEBUG: AVCapturePhotoOutput.capturePhoto 호출")
            #endif
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    private func startSessionIfNeeded() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.isConfigured {
                self.configureSession()
            }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    private func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = bestDevice(position: currentPosition),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            DispatchQueue.main.async { [weak self] in
                self?.onCaptureError?("카메라를 초기화할 수 없어요. 권한 또는 기기 상태를 확인해주세요.")
            }
            return
        }

        session.addInput(input)
        currentInput = input

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        } else {
            session.commitConfiguration()
            DispatchQueue.main.async { [weak self] in
                self?.onCaptureError?("카메라 출력 구성을 완료하지 못했어요.")
            }
            return
        }

        session.commitConfiguration()
        isConfigured = true

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let layer = AVCaptureVideoPreviewLayer(session: self.session)
            layer.videoGravity = .resizeAspectFill
            layer.frame = self.view.bounds
            self.view.layer.insertSublayer(layer, at: 0)
            self.previewLayer = layer
        }
    }

    private func reconfigureInput(position: AVCaptureDevice.Position) {
        guard isConfigured else { return }
        guard let newDevice = bestDevice(position: position),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }

        session.beginConfiguration()
        if let currentInput {
            session.removeInput(currentInput)
        }
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            currentInput = newInput
        }
        session.commitConfiguration()
    }

    private func bestDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if let dualWide = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: position) {
            return dualWide
        }
        if let wide = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            return wide
        }
        return AVCaptureDevice.default(for: .video)
    }
}

extension CameraCaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            #if DEBUG
            print("CAMERA DEBUG: didFinishProcessingPhoto 실패 - \(error.localizedDescription)")
            #endif
            DispatchQueue.main.async { [weak self] in
                self?.onCapture?(nil)
            }
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            #if DEBUG
            print("CAMERA DEBUG: didFinishProcessingPhoto 데이터 변환 실패")
            #endif
            DispatchQueue.main.async { [weak self] in
                self?.onCapture?(nil)
            }
            return
        }

        #if DEBUG
        print("CAMERA DEBUG: didFinishProcessingPhoto 성공 - size=\(image.size)")
        #endif
        DispatchQueue.main.async { [weak self] in
            self?.onCapture?(image)
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var capturedImage: UIImage?
    @Binding var captureErrorMessage: String?
    @Binding var cameraDevice: UIImagePickerController.CameraDevice
    @Binding var takePhotoTrigger: Int

    func makeUIViewController(context: Context) -> CameraCaptureViewController {
        let controller = CameraCaptureViewController()
        controller.setInitialPosition(cameraDevice.toCapturePosition)
        controller.onCapture = { [weak coordinator = context.coordinator] image in
            coordinator?.handleCapture(image)
        }
        controller.onCaptureError = { [weak coordinator = context.coordinator] message in
            coordinator?.handleError(message)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraCaptureViewController, context: Context) {
        if context.coordinator.lastCameraDevice != cameraDevice {
            context.coordinator.lastCameraDevice = cameraDevice
            #if DEBUG
            print("CAMERA DEBUG: 카메라 전환 -> \(cameraDevice == .rear ? "rear" : "front")")
            #endif
            uiViewController.switchCamera(to: cameraDevice.toCapturePosition)
        }

        if context.coordinator.lastTakePhotoTrigger != takePhotoTrigger {
            context.coordinator.lastTakePhotoTrigger = takePhotoTrigger
            #if DEBUG
            print("CAMERA DEBUG: 셔터 트리거 감지 - trigger=\(takePhotoTrigger)")
            #endif
            uiViewController.capturePhoto()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            cameraDevice: cameraDevice,
            takePhotoTrigger: takePhotoTrigger,
            capturedImage: $capturedImage,
            captureErrorMessage: $captureErrorMessage
        )
    }

    final class Coordinator {
        var lastCameraDevice: UIImagePickerController.CameraDevice
        var lastTakePhotoTrigger: Int
        private var capturedImage: Binding<UIImage?>
        private var captureErrorMessage: Binding<String?>

        init(
            cameraDevice: UIImagePickerController.CameraDevice,
            takePhotoTrigger: Int,
            capturedImage: Binding<UIImage?>,
            captureErrorMessage: Binding<String?>
        ) {
            self.lastCameraDevice = cameraDevice
            self.lastTakePhotoTrigger = takePhotoTrigger
            self.capturedImage = capturedImage
            self.captureErrorMessage = captureErrorMessage
        }

        func handleCapture(_ image: UIImage?) {
            guard let image else { return }
            capturedImage.wrappedValue = image
        }

        func handleError(_ message: String) {
            captureErrorMessage.wrappedValue = message
        }
    }
}
