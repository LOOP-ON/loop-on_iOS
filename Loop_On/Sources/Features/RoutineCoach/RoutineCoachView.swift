//
//  RoutineCoachView.swift
//  Loop_On
//
//  Created by 이경민 on 1/21/26.
//

import Foundation
import SwiftUI

struct RoutineCoachView: View{
    var body: some View {
        VStack {
            Text("두 번째 여정의 루틴을 생성했어요")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    RoutineCoachView()
}
