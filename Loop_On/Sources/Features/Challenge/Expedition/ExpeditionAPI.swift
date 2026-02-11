//
//  ExpeditionAPI.swift
//  Loop_On
//
//  Created by Codex on 2/11/26.
//

import Foundation
import Moya

enum ExpeditionAPI {
    // 내 탐험대 목록 조회 (GET /api/expeditions)
    case getMyExpeditions
    // 탐험대 검색 (GET /api/expeditions/search)
    case searchExpeditions(keyword: String, categories: [Bool], page: Int, size: Int)
    // 탐험대 생성 (POST /api/expeditions)
    case createExpedition(request: CreateExpeditionRequest)
}

extension ExpeditionAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("Invalid API.baseURL: \(API.baseURL)")
        }
        return url
    }

    var path: String {
        switch self {
        case .getMyExpeditions:
            return "/api/expeditions"
        case .searchExpeditions:
            return "/api/expeditions/search"
        case .createExpedition:
            return "/api/expeditions"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMyExpeditions:
            return .get
        case .searchExpeditions:
            return .get
        case .createExpedition:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .getMyExpeditions:
            return .requestPlain
        case let .searchExpeditions(keyword, categories, page, size):
            return .requestParameters(
                parameters: [
                    "keyword": keyword,
                    "categories": categories,
                    "page": page,
                    "size": size
                ],
                encoding: URLEncoding(
                    destination: .queryString,
                    arrayEncoding: .noBrackets,
                    boolEncoding: .literal
                )
            )
        case let .createExpedition(request):
            return .requestJSONEncodable(request)
        }
    }

    var headers: [String: String]? {
        var header: [String: String] = ["Content-Type": "application/json"]
        if let token = KeychainService.shared.loadToken(), !token.isEmpty {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }
}
