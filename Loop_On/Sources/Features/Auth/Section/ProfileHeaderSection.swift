//
//  ProfileHeaderSection.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import SwiftUI
import PhotosUI

struct ProfileHeaderSection: View {
    @ObservedObject var vm: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 28) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .padding(.top, 66)
            
            // 프로필 이미지와 카메라 아이콘
//            ZStack(alignment: .bottomTrailing) {
//                Circle()
//                    .frame(width: 120, height: 120)
//                    .foregroundStyle(Color("85"))
//                
//                // 카메라 아이콘 (검은색 원 배경 포함, 오른쪽 하단에 배치)
//                Button {
//                    // TODO: 이미지 선택 기능
//                } label: {
//                    ZStack {
//                        // 검은색 원 배경
//                        Circle()
//                            .fill(Color.black)
//                            .frame(width: 32, height: 32)
//                        
//                        // 카메라 아이콘
//                        Image("photo_camera")
//                            .resizable()
//                            .renderingMode(.template)
//                            .scaledToFit()
//                            .frame(width: 20, height: 20)
//                            .foregroundStyle(Color.white)
//                    }
//                }
//                .buttonStyle(.plain)
//                .offset(x: -4, y: -4)
//            }
            
            // 전체 영역을 PhotosPicker로 감싸 클릭 시 사진첩 호출
            PhotosPicker(selection: $vm.imageSelection, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    // 선택된 이미지가 있으면 보여주고, 없으면 기본 원형 배경 표시
                    if let data = vm.selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .frame(width: 120, height: 120)
                            .foregroundStyle(Color("85"))
                    }
                    
                    // 카메라 아이콘 오버레이
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 32, height: 32)
                        
                        Image("photo_camera")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.white)
                    }
                    .offset(x: -4, y: -4)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("ProfileHeaderSection") {
    ProfileHeaderSection(vm: ProfileViewModel())
        .padding()
        .background(Color("background"))
}
