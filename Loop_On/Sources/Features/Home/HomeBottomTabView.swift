//
//  HomeBottomTabView.swift
//  Loop_On
//
//  Created by 이경민 on 1/14/26.
//

import Foundation
import SwiftUI

struct HomeBottomTabView: View {
    @Binding var selectedTab: TabItem
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                tabButton(tab: .home, icon: "bookmark.fill", title: "오늘의 루틴")
                tabButton(tab: .history, icon: "calendar", title: "히스토리")
                tabButton(tab: .challenge, icon: "flag.fill", title: "챌린지")
                tabButton(tab: .profile, icon: "person", title: "개인")
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
                
            // 기기 하단 홈 바 영역(여백)을 명시적으로 추가
            Color.clear
                .frame(height: safeAreaBottomHeight)
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
        .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
    }

    // 현재 기기의 하단 안전 영역 높이를 가져오는 변수
    private var safeAreaBottomHeight: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.bottom ?? 0
    }

    private func tabButton(tab: TabItem, icon: String, title: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 12))
            }
            .foregroundStyle(selectedTab == tab ? Color(.primaryColor55) : Color.gray)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
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
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var selectedTab: TabItem = .home

    var body: some View {
        HomeBottomTabView(selectedTab: $selectedTab)
            .previewLayout(.sizeThatFits)
    }
}
