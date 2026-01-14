//
//  HomeBottomTabView.swift
//  Loop_On
//
//  Created by 이경민 on 1/14/26.
//

import Foundation
import SwiftUI

struct HomeBottomTabView: View {

    var body: some View {
        ZStack(alignment: .top) {
            // 기기 하단까지 꽉차게
            Color.white
                .ignoresSafeArea(edges: .bottom)

            // 실제 탭 콘텐츠 (위만 둥글게)
            HStack {
                tabItem(icon: "bookmark.fill", title: "오늘의 루틴", active: true)
                tabItem(icon: "calendar", title: "히스토리")
                tabItem(icon: "flag", title: "챌린지")
                tabItem(icon: "person", title: "개인")
            }
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
            )
        }
    }

    private func tabItem(
        icon: String,
        title: String,
        active: Bool = false
    ) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(title)
                .font(.system(size: 12))
        }
        .foregroundColor(
            active ? Color(.primaryColor55) : Color("75")
        )
        .frame(maxWidth: .infinity)
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


#Preview {
    HomeBottomTabView()
        .previewLayout(.sizeThatFits)
}
