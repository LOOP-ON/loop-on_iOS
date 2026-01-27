//
//  AccountView.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import SwiftUI

struct AccountView: View {
    @Environment(NavigationRouter.self) private var router

    // TODO: Replace with real user/session data
    private let email = "seoly@soongsil.ac.kr"
    private let socialLoginStatus = "없음"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 로그인 정보
                accountSectionTitle("로그인 정보")
                    .padding(.top, 24)
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    AccountRow(title: "이메일 변경", trailing: email) {
                        // TODO: 이메일 변경 화면
                    }
                    AccountRow(title: "소셜로그인 연결", trailing: socialLoginStatus) {
                        // TODO: 소셜 로그인 연결 화면
                    }
                    AccountRow(title: "비밀번호 재설정", trailing: nil) {
                        router.push(.auth(.findPassword))
                    }
                }

                // 계정 관리
                accountSectionTitle("계정 관리")
                    .padding(.top, 32)
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    AccountActionRow(title: "로그아웃", isDestructive: false) {
                        // TODO: 로그아웃
                    }
                    AccountActionRow(title: "계정 탈퇴", isDestructive: true) {
                        // TODO: 계정 탈퇴
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
        .navigationTitle("계정")
        .navigationBarTitleDisplayMode(.inline)
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

    private func accountSectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color("25-Text"))
    }
}

// MARK: - Account Row (title + trailing text + chevron)
private struct AccountRow: View {
    let title: String
    let trailing: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color("25-Text"))
                Spacer(minLength: 8)
                if let trailing = trailing {
                    Text(trailing)
                        .font(.system(size: 14))
                        .foregroundStyle(Color("45-Text"))
                        .lineLimit(1)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("25-Text"))
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Account Action Row (로그아웃 / 계정 탈퇴)
private struct AccountActionRow: View {
    let title: String
    let isDestructive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(isDestructive ? Color("StatusRed") : Color("25-Text"))
                Spacer()
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AccountView()
            .environment(NavigationRouter())
            .environment(SessionStore())
    }
}
