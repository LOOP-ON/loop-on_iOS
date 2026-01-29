//
//  SettingsView.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 0) {
                    SettingsInlineRow(title: "계정") {
                        router.push(.app(.account))
                    }
                    
                    Divider()
                    
                    SettingsInlineRow(title: "알림") {
                        router.push(.app(.notifications))
                    }
                    
                    Divider()
                    
                    SettingsInlineRow(title: "시스템") {
                        router.push(.app(.system))
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                )
                // 계정 뷰의 "로그인 정보" 텍스트 시작 위치(16pt)와 카드 좌측 가장자리 정렬
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.primary)
                }
            }
        }
    }
}

// MARK: - Settings Inline Row (한 카드 안에 들어가는 행)
private struct SettingsInlineRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color("25-Text"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("45-Text"))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(NavigationRouter())
            .environment(SessionStore())
    }
}
