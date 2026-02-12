//
//  HomeHeaderView.swift
//  Loop_On
//
//  Created by 이경민 on 1/14/26.
//

import Foundation
import SwiftUI

struct HomeHeaderView: View {
    var onSettingsTapped: (() -> Void)?

    var body: some View {
        HStack {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width:164, height:40)

            Spacer()

            HStack(spacing: 8) {
                Image("passport")
                    .resizable()
                    .scaledToFit()
                    .frame(width:34)
                Button(action: {
                    onSettingsTapped?()
                }) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .scaledToFit()
                        .frame(width:24)
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 20))
            .foregroundStyle(Color.black)
        }
    }
}


#Preview {
    HomeHeaderView()
        .padding()
        .previewLayout(.sizeThatFits)
}
