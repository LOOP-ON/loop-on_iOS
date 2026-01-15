//
//  ProfileHeaderSection.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import SwiftUI

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
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(Color("85"))
                
                // 카메라 아이콘 (검은색 원 배경 포함, 오른쪽 하단에 배치)
                Button {
                    // TODO: 이미지 선택 기능
                } label: {
                    ZStack {
                        // 검은색 원 배경
                        Circle()
                            .fill(Color.black)
                            .frame(width: 32, height: 32)
                        
                        // 카메라 아이콘
                        Image("photo_camera")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.white)
                    }
                }
                .buttonStyle(.plain)
                .offset(x: -4, y: -4)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("ProfileHeaderSection") {
    ProfileHeaderSection(vm: ProfileViewModel())
        .padding()
        .background(Color("background"))
}
