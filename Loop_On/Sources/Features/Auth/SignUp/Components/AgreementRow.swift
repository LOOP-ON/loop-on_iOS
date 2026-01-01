//
//  AgreementRow.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI
struct AgreementRow: View {
    let title: String
    @Binding var isOn: Bool
    let showsChevron: Bool
    let onTapChevron: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            CheckBox(isOn: $isOn)

            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(Color("25-Text"))

            Spacer()

            if showsChevron {
                Button(action: onTapChevron) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color("65"))
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { isOn.toggle() }
    }
}


#Preview("AgreementRow - Required") {
    AgreementRowPreviewWrapper(
        title: "LOOP:ON 이용약관 동의 (필수)",
        showsChevron: true
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("AgreementRow - Optional") {
    AgreementRowPreviewWrapper(
        title: "마케팅 정보 수신 동의 (선택)",
        showsChevron: true
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

private struct AgreementRowPreviewWrapper: View {
    let title: String
    let showsChevron: Bool

    @State private var isOn: Bool = false

    var body: some View {
        AgreementRow(
            title: title,
            isOn: $isOn,
            showsChevron: showsChevron,
            onTapChevron: { print("chevron tapped") }
        )
        .padding(14)
        .background(Color("100"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
