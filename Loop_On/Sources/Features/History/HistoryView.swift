//
//  HistoryView.swift
//  Loop_On
//
//  Created by 이경민 on 1/15/26.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<30, id: \.self) { _ in
                    Text("히스토리 화면")
                        .font(.title)
                }
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity) // width: .infinity에서 수정
        .safeAreaPadding(.top, 1) // 노치 영역 침범 방지
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    HistoryView()
}

