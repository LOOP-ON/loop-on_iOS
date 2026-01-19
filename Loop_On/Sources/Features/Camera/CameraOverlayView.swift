//
//  CameraOverlayView.swift
//  Loop_On
//
//  Created by 이경민 on 1/19/26.
//

import Foundation
import SwiftUI

struct CameraOverlayView: View {
    let title: String
    var onCapture: () -> Void
    var onDismiss: () -> Void
    var onFlip: () -> Void

    var body: some View {
        VStack {
            // 상단 헤더
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()

            Spacer()

            // 중앙 안내 문구
            VStack(spacing: 12) {
                Text("사진을 촬영해 인증을 해주세요")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(Color(.primaryColorVarient65)) // 루틴 제목 강조색
            }

            Spacer()

            // 하단 컨트롤
            HStack {
                Spacer()
                
                // 촬영 버튼
                Button(action: onCapture) {
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .fill(Color.white)
                                .padding(6)
                        )
                }
                
                Spacer()
                
                // 카메라 전환 버튼
                Button(action: onFlip) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.white.opacity(0.2)))
                }
                .padding(.trailing, 30)
            }
            .padding(.bottom, 50)
        }
        .background(Color.black.opacity(0.3)) // 카메라 프리뷰 위 반투명 층
    }
}
