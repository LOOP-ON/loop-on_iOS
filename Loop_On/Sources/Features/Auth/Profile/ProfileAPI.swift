//
//  ProfileAPI.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import Moya
import Foundation

enum ProfileAPI {
    case createProfile(profile: ProfileDTO)
    case updateProfile(profile: ProfileDTO)
    case getProfile
    case getMe(page: Int, size: Int, sort: [String]?)
    case getUser(nickname: String, page: Int, size: Int, sort: [String]?)
    case updateUserProfile(request: ProfileUpdateRequestDTO)
    /// PATCH /api/users/profile/image — multipart
    case updateProfileImage(imageData: Data)
}

extension ProfileAPI: TargetType {
    var baseURL: URL { URL(string: API.baseURL)! }
    
    var path: String {
        switch self {
        case .createProfile, .updateProfile, .getProfile:
            return "/profile"
        case .getMe:
            return "/api/users/me"
        case .getUser(let nickname, _, _, _):
            return "/api/users/\(nickname)"
        case .updateUserProfile:
            return "/api/users/profile"
        case .updateProfileImage:
            return "/api/users/upload-profile-image"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createProfile:
            return .post
        case .updateProfile:
            return .put
        case .updateUserProfile:
            return .patch
        case .updateProfileImage:
            return .post
        case .getProfile:
            return .get
        case .getMe:
            return .get
        case .getUser:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .createProfile(profile), let .updateProfile(profile):
            return .requestJSONEncodable(profile)
        case let .updateUserProfile(request):
            return .requestJSONEncodable(request)
        case .getProfile:
            return .requestPlain
        case let .getMe(page, size, sort):
            var params: [String: Any] = [
                "page": page,
                "size": size
            ]
            if let sort = sort, !sort.isEmpty {
                params["sort"] = sort.joined(separator: ",")
            }
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
        case let .getUser(_, page, size, sort):
            var params: [String: Any] = [
                "page": page,
                "size": size
            ]
            if let sort = sort, !sort.isEmpty {
                params["sort"] = sort.joined(separator: ",")
            }
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
        case let .updateProfileImage(imageData):
            let part = MultipartFormData(
                provider: .data(imageData),
                name: "file",
                fileName: "profile.jpg",
                mimeType: "image/jpeg"
            )
            return .uploadMultipart([part])
        }
    }
    
    var headers: [String: String]? {
        let token = KeychainService.shared.loadToken()
        let auth = token.map { "Bearer \($0)" }

        switch self {
        case .updateProfileImage:
            // multipart 업로드 시 Content-Type은 Moya가 boundary와 함께 자동 설정
            var header: [String: String] = [:]
            if let auth { header["Authorization"] = auth }
            return header
        default:
            var header = ["Content-Type": "application/json"]
            if let auth { header["Authorization"] = auth }
            return header
        }
    }
}
