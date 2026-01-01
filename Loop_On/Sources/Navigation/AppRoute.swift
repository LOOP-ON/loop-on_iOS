//
//  AppRoute.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation

enum AppRoute: Hashable {
    case home
    case detail(title: String)
    case profile(userID: Int)
}
