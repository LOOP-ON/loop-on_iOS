//
//  TrailingStatusIcon.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI

struct TrailingStatusIcon: View {
    let state: SignUpViewModel.EmailCheckState

    var body: some View {
        switch state {
        case .available:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.green)
        case .duplicated, .invalidFormat:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(Color.red)
        case .checking:
            ProgressView()
                .scaleEffect(0.8)
        case .idle:
            EmptyView()
        }
    }
}

#Preview("TrailingStatusIcon - States") {
    VStack(spacing: 16) {
        HStack {
            Text("idle"); Spacer()
            TrailingStatusIcon(state: .idle)
        }
        HStack {
            Text("checking"); Spacer()
            TrailingStatusIcon(state: .checking)
        }
        HStack {
            Text("available"); Spacer()
            TrailingStatusIcon(state: .available)
        }
        HStack {
            Text("duplicated"); Spacer()
            TrailingStatusIcon(state: .duplicated)
        }
        HStack {
            Text("invalidFormat"); Spacer()
            TrailingStatusIcon(state: .invalidFormat)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
