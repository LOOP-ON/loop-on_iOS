//
//  CameraPicker.swift
//  Loop_On
//
//  Created by 이경민 on 1/19/26.
//

import Foundation

import SwiftUI
import AVFoundation

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var capturedImage: UIImage?
    @Binding var cameraDevice: UIImagePickerController.CameraDevice     // 카메라 전환
    @Binding var takePhotoTrigger: Int
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        picker.showsCameraControls = false
        picker.cameraDevice = cameraDevice      // 카메라 전환
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        if uiViewController.cameraDevice != cameraDevice {
            uiViewController.cameraDevice = cameraDevice
        }

        if context.coordinator.lastTakePhotoTrigger != takePhotoTrigger {
            context.coordinator.lastTakePhotoTrigger = takePhotoTrigger
            uiViewController.takePicture()
        }
    }

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        var lastTakePhotoTrigger: Int = 0
        init(_ parent: CameraPicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}
