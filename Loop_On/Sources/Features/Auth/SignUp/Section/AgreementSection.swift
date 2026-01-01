//
//  AgreementSection.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI

struct AgreementSection: View {
    let title: String
    @Binding var items: [SignUpViewModel.AgreementItem]
    let onTapDetail: (SignUpViewModel.AgreementItem) -> Void

    var body: some View {
        VStack(spacing: 12) {
            OrDividerView(text: title)

            VStack(spacing: 12) {
                ForEach(items.indices, id: \.self) { idx in
                    AgreementRow(
                        title: itemTitle(items[idx]),
                        isOn: $items[idx].isOn,
                        showsChevron: items[idx].hasDetail,
                        onTapChevron: { onTapDetail(items[idx]) }
                    )
                }
            }
            .padding(14)
            .background(Color("100"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func itemTitle(_ item: SignUpViewModel.AgreementItem) -> String {
        "\(item.title) (\(item.isRequired ? "필수" : "선택"))"
    }
}

#Preview("AgreementSection - Default") {
    AgreementSectionPreviewWrapper()
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("AgreementSection - All Required Checked") {
    AgreementSectionPreviewWrapper(allRequiredOn: true)
        .padding()
        .background(Color(.systemGroupedBackground))
}

private struct AgreementSectionPreviewWrapper: View {
    @State private var items: [SignUpViewModel.AgreementItem]
    private let allRequiredOn: Bool

    init(allRequiredOn: Bool = false) {
        self.allRequiredOn = allRequiredOn

        let base: [SignUpViewModel.AgreementItem] = [
            .init(title: "LOOP:ON 이용약관 동의", isRequired: true, hasDetail: true, isOn: false),
            .init(title: "개인정보 수집·이용 동의", isRequired: true, hasDetail: true, isOn: false),
            .init(title: "서비스 성격 고지 체크", isRequired: true, hasDetail: true, isOn: false),
            .init(title: "개인정보 수집·이용 동의", isRequired: false, hasDetail: true, isOn: false),
            .init(title: "개인정보 제 3자 제공 동의", isRequired: false, hasDetail: true, isOn: false),
            .init(title: "마케팅 정보 수신 동의", isRequired: false, hasDetail: true, isOn: false),
        ]

        _items = State(initialValue: base)
    }

    var body: some View {
        AgreementSection(
            title: "약관 동의",
            items: $items,
            onTapDetail: { item in
                print("약관 상세 탭: \(item.title)")
            }
        )
        .onAppear {
            guard allRequiredOn else { return }
            for i in items.indices where items[i].isRequired {
                items[i].isOn = true
            }
        }
    }
}
