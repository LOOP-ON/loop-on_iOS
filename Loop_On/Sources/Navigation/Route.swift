//
//  Route.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation

enum Route: Hashable {
    case auth(AuthRoute)
    case app(AppRoute)
}
