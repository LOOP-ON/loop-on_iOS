//
//  Route.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import SwiftUI

enum Route: Hashable {
    case home
    case detail(title: String)
    case profile(userID: Int)
}
