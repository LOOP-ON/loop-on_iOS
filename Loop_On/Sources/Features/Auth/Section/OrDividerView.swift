//
//  OrDividerView.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI

struct OrDividerView: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            line
            Text(text)
                .font(.footnote)
                .foregroundStyle(Color(.secondaryLabel))
            line
        }
    }
    
    private var line: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 1)
    }
}

#Preview {
    OrDividerView(text: "또는")
}
