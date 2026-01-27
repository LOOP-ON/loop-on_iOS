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
        VStack(spacing: 0) {
            List {
                SettingsRow(title: "계정") {
                    router.push(.app(.account))
                }
                SettingsRow(title: "알림") {
                    router.push(.app(.notifications))
                }
                SettingsRow(title: "시스템") {
                    router.push(.app(.system))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
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

// MARK: - Settings Row
private struct SettingsRow: View {
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
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
        .listRowBackground(Color.clear)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(NavigationRouter())
            .environment(SessionStore())
    }
}
