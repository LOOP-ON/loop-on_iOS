//
//  NavigationRouter.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI
import Observation

@Observable
class NavigationRouter {
    var path = NavigationPath()  // 네비게이션 경로를 저장하는 변수

    /// 특정 화면을 추가 (Push 기능)
    func push(_ route: Route) {
        path.append(route)
    }

    /// 마지막 화면 제거 (Pop 기능)
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    /// 네비게이션 초기화 (전체 Pop)
    func reset() {
        path = NavigationPath()
    }
}
