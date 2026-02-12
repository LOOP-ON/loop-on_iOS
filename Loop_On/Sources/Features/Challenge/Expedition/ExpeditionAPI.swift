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
    // 탐험대 가입 (POST /api/expeditions/join)
    case joinExpedition(request: JoinExpeditionRequest)
    // 탐험대 삭제 (DELETE /api/expeditions/{expeditionId})
    case deleteExpedition(expeditionId: Int)
    // 탐험대 탈퇴 (DELETE /api/expeditions/{expeditionId}/withdraw)
    case withdrawExpedition(expeditionId: Int)
    // 탐험대원 명단 조회 (GET /api/expeditions/{expeditionId}/users)
    case getExpeditionMembers(expeditionId: Int)
    // 탐험대원 퇴출 (PATCH /api/expeditions/{expeditionId}/expel)
    case expelMember(expeditionId: Int, request: ExpeditionExpelRequest)
    // 탐험대원 퇴출 해제 (DELETE /api/expeditions/{expeditionId}/expel)
    case cancelExpelMember(expeditionId: Int, request: ExpeditionExpelRequest)
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
        case .joinExpedition:
            return "/api/expeditions/join"
        case let .deleteExpedition(expeditionId):
            return "/api/expeditions/\(expeditionId)"
        case let .withdrawExpedition(expeditionId):
            return "/api/expeditions/\(expeditionId)/withdraw"
        case let .getExpeditionMembers(expeditionId):
            return "/api/expeditions/\(expeditionId)/users"
        case let .expelMember(expeditionId, _):
            return "/api/expeditions/\(expeditionId)/expel"
        case let .cancelExpelMember(expeditionId, _):
            return "/api/expeditions/\(expeditionId)/expel"
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
        case .joinExpedition:
            return .post
        case .deleteExpedition:
            return .delete
        case .withdrawExpedition:
            return .delete
        case .getExpeditionMembers:
            return .get
        case .expelMember:
            return .patch
        case .cancelExpelMember:
            return .delete
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
        case let .joinExpedition(request):
            return .requestJSONEncodable(request)
        case .deleteExpedition:
            return .requestPlain
        case .withdrawExpedition:
            return .requestPlain
        case .getExpeditionMembers:
            return .requestPlain
        case let .expelMember(_, request):
            return .requestJSONEncodable(request)
        case let .cancelExpelMember(_, request):
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
