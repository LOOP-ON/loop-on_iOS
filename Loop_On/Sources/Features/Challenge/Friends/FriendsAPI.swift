//
//  FriendsAPI.swift
//  Loop_On
//
//  Created by 김세은 on 2/7/26.
//

import Foundation
import Moya

enum FriendsAPI {
    // 친구 목록 조회 (GET /api/friend)
    case getFriends
    // 친구 검색 (GET /api/friend-request/search)
    case searchFriends(query: String, page: Int, size: Int)
    // 친구 요청 전송 (POST /api/friend-request/send)
    case sendFriendRequest(request: FriendRequestSendRequest)
    // 받은 친구 요청 목록 조회 (GET /api/friend-request)
    case getFriendRequests(page: Int, size: Int)
    // 친구 요청 개수 조회 (GET /api/friend-request/pending-count)
    case getPendingRequestCount
}

extension FriendsAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("Invalid API.baseURL: \(API.baseURL)")
        }
        return url
    }

    var path: String {
        switch self {
        case .getFriends:
            return "/api/friend"
        case .searchFriends:
            return "/api/friend-request/search"
        case .sendFriendRequest:
            return "/api/friend-request/send"
        case .getFriendRequests:
            return "/api/friend-request"
        case .getPendingRequestCount:
            return "/api/friend-request/pending-count"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getFriends:
            return .get
        case .searchFriends:
            return .get
        case .sendFriendRequest:
            return .post
        case .getFriendRequests:
            return .get
        case .getPendingRequestCount:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getFriends:
            return .requestPlain
        case let .searchFriends(query, page, size):
            return .requestParameters(
                parameters: [
                    "query": query,
                    "page": page,
                    "size": size
                ],
                encoding: URLEncoding.queryString
            )
        case let .sendFriendRequest(request):
            return .requestJSONEncodable(request)
        case let .getFriendRequests(page, size):
            return .requestParameters(
                parameters: [
                    "page": page,
                    "size": size
                ],
                encoding: URLEncoding.queryString
            )
        case .getPendingRequestCount:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
