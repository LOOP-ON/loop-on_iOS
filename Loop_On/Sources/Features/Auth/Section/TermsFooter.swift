//
//  TermsFooter.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI

struct TermsFooter: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(Color(.secondaryLabel))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity)
    }
}
