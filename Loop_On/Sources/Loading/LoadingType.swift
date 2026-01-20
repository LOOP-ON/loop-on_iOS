//
//  LoadingType.swift
//  Loop_On
//
//  Created by 이경민 on 1/20/26.
//

import Foundation

enum LoadingType {
    case planning, payment, login
    
    var message: String {
        switch self {
        case .planning: return "두 번째 여정을 계획하는 중입니다"
        case .payment: return "결제를 처리하고 있어요"
        case .login: return "로그인 정보를 확인 중입니다"
        }
    }
}

