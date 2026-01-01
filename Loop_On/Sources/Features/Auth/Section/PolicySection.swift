//
//  policySection.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI

struct PolicySection: View {
    var body: some View {
        Text("계속 진행하면 이용 약관에 동의하고 개인정보 처리방침을 확인했음을 인정하게 됩니다")
            .font(.system(size: 11))
            .foregroundStyle(Color(.secondaryLabel))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }
}
