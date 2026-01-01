//
//  SignUpView.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI

import SwiftUI

struct SignUpView: View {
    @StateObject private var vm = SignUpViewModel()

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
        }
    }
}

