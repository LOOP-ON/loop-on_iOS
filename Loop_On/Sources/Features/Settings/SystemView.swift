//
//  SystemView.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import SwiftUI

struct SystemView: View {
    @Environment(NavigationRouter.self) private var router
    @StateObject private var viewModel = SystemViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                permissionSection
                dataAndEtcSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("시스템")
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

    private func systemSectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color("25-Text"))
    }

    private func systemToggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color("25-Text"))
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color("PrimaryColor55"))
        }
        .padding(.vertical, 14)
    }

    // MARK: - Section Containers (iOS 설정 앱 스타일 카드)

    private var permissionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            systemSectionTitle("권한 관리")
                .padding(.top, 20)
                .padding(.bottom, 10)
            systemToggleRow("알림 권한", isOn: $viewModel.isNotificationPermissionOn)
            systemToggleRow("카메라 접근 권한", isOn: $viewModel.isCameraPermissionOn)
            systemToggleRow("사진 접근 권한", isOn: $viewModel.isPhotoPermissionOn)
        }
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }

    private var dataAndEtcSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            systemSectionTitle("데이터 & 기타")
                .padding(.top, 20)
                .padding(.bottom, 10)
            SystemActionRow(title: "캐시 정리") {
                viewModel.clearCache()
            }
            SystemLinkRow(title: "이용 약관") {
                // TODO: 이용 약관 화면
            }
            SystemLinkRow(title: "개인정보 처리 방침") {
                // TODO: 개인정보 처리방침 화면
            }
            SystemInfoRow(title: "앱 버전 정보", value: viewModel.appVersion)
        }
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }
}

// MARK: - 캐시 정리 (탭 액션만)
private struct SystemActionRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color("25-Text"))
                Spacer()
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 이용 약관 / 개인정보 처리방침 (chevron)
private struct SystemLinkRow: View {
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
                    .foregroundStyle(Color("25-Text"))
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 앱 버전 정보 (정적 표시)
private struct SystemInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color("25-Text"))
            Spacer()
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(Color("45-Text"))
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        SystemView()
            .environment(NavigationRouter())
            .environment(SessionStore())
    }
}
