//
//  SignUpView.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    @StateObject private var vm = SignUpViewModel()
    @Environment(NavigationRouter.self) private var router
    @Environment(SessionStore.self) private var session

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SignUpHeaderSection()

                SignUpFormSection(vm: vm)

                AgreementSection(
                    title: "약관 동의",
                    items: $vm.agreements,
                    onTapDetail: { item in
                        // TODO: 약관 상세 화면 push/모달
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 28)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemBackground))
        .fullScreenCover(item: $vm.activeSheet) { sheet in
            fullSheetContent(for: sheet)
        }
        // 회원가입 API가 성공하면 프로필 설정 화면으로 이동
        .onChange(of: vm.isSignUpSuccess) { _, success in
            guard success else { return }
            router.push(.auth(.setProfile))
        }
    }
    @ViewBuilder
        func fullSheetContent(for sheet: SignUpSheet) -> some View {
            switch sheet {
            case .agreement:
                CommonPopupView(
                    isPresented: Binding(
                        get: { vm.activeSheet == .agreement },
                        set: { if !$0 { vm.activeSheet = nil } }
                    ),
                    title: "약관에 동의해주세요.",
                    message: "회원가입을 위해 약관 동의가 필요합니다.",
                    leftButtonText: "닫기",
                    rightButtonText: "확인",
                    leftAction: { vm.activeSheet = nil },
                    rightAction: { vm.activeSheet = nil }
                )
                .presentationBackground(.clear)
            }
        }
}


#Preview("SignUpView - Wrapped") {
    SignUpPreviewContainer()
}

private struct SignUpPreviewContainer: View {
    @State private var router = NavigationRouter()
    @State private var session = SessionStore()

    var body: some View {
        NavigationStack(path: $router.path) {
            SignUpView()
                .environment(router)
                .environment(session)
                .navigationDestination(for: Route.self) { route in
                    if case .auth(.setProfile) = route {
                        ProfileView()
                            .environment(router)
                            .environment(session)
                    }
                }
        }
    }
}

