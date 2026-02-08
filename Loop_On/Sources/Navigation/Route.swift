//
//  Route.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation

/// NavigationPath가 push된 경로를 복원할 때 올바르게 디코딩되도록 Codable 준수
enum Route: Hashable, Codable {
    case auth(AuthRoute)
    case app(AppRoute)
}
