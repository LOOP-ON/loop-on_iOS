//
//  CheckBox.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI

struct CheckBox: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Image(systemName: isOn ? "checkmark.square.fill" : "square")
                .foregroundStyle(isOn ? Color("PrimaryColor55") : Color("65"))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn ? "선택됨" : "선택 안 됨")
    }
}

#Preview("CheckBox") {
    CheckBoxPreviewWrapper()
        .padding()
        .background(Color(.systemGroupedBackground))
}

private struct CheckBoxPreviewWrapper: View {
    @State private var isOn: Bool = false

    var body: some View {
        VStack(spacing: 14) {
            CheckBox(isOn: $isOn)
            Text(isOn ? "ON" : "OFF")
        }
    }
}

