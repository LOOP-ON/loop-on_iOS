//
//  AccountView.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import SwiftUI

struct AccountView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(SessionStore.self) private var session

    // TODO: Replace with real user/session data
    private let email = "seoly@soongsil.ac.kr"
    private let socialLoginStatus = "없음"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 로그인 정보 섹션
                VStack(alignment: .leading, spacing: 0) {
                    accountSectionTitle("로그인 정보")
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    AccountCardRow(title: "이메일 변경", trailing: email, isDestructive: false, showsChevron: true) {
                            // TODO: 이메일 변경 화면
                        }
                        AccountCardRow(title: "소셜로그인 연결", trailing: socialLoginStatus, isDestructive: false, showsChevron: true) {
                            // TODO: 소셜 로그인 연결 화면
                        }
                        AccountCardRow(title: "비밀번호 재설정", trailing: nil, isDestructive: false, showsChevron: true) {
                            router.push(.auth(.findPassword))
                        }
                }
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                )
                .padding(.horizontal, 16)
                .padding(.top, 24)

                // 계정 관리 섹션
                VStack(alignment: .leading, spacing: 0) {
                    accountSectionTitle("계정 관리")
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    AccountCardRow(title: "로그아웃", trailing: nil, isDestructive: false, showsChevron: false) {
                        session.logout { _ in
                            // 서버 로그아웃 성공/실패와 관계 없이 클라이언트 세션은 초기화되었으므로 루트로 이동
                            router.reset()
                        }
                    }
                    AccountCardRow(title: "계정 탈퇴", trailing: nil, isDestructive: true, showsChevron: false) {
                        // TODO: 계정 탈퇴
                    }
                }
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                )
                .padding(.horizontal, 16)
                
                Spacer(minLength: 0)
            }
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color("25-Text"))
    }
}

// MARK: - Account Card Row (iOS 설정 상세 화면 스타일)
private struct AccountCardRow: View {
    let title: String
    let trailing: String?
    let isDestructive: Bool
    let showsChevron: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(isDestructive ? Color("StatusRed") : Color("25-Text"))
                Spacer(minLength: 8)
                if let trailing = trailing {
                    Text(trailing)
                        .font(.system(size: 14))
                        .foregroundStyle(Color("45-Text"))
                        .lineLimit(1)
                }
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color("25-Text"))
                }
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
