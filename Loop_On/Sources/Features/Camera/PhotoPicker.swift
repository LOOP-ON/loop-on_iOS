//
//  PhotoPicker.swift
//  Loop_On
//
//  Created by 이경민 on 1/19/26.
//

import Foundation
import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    var selectionLimit: Int // 선택 가능한 개수 전달

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = selectionLimit // 최대 선택 개수 설정 (3개)
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            for result in results {
                let provider = result.itemProvider
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(uiImage)
                            }
                        }
                    }
                }
            }
        }
    }
}
