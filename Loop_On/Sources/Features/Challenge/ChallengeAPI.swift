//
//  ChallengeAPI.swift
//  Loop_On
//

import Moya
import Foundation

// MARK: - Request DTOs

/// POST /api/challenges/{challengeId}/like 요청 바디
struct ChallengeLikeRequestDTO: Encodable {
    let isLiked: Bool
}

/// POST /api/challenges/{challengeId}/comments 요청 바디
struct CommentPostRequestDTO: Encodable {
    let content: String
    let parentId: Int
}

/// POST /api/challenges 요청 바디 (multipart의 requestDto)
struct CreateChallengeRequestDTO: Encodable {
    let hashtagList: [String]
    let content: String
    let journeyId: Int
    let expeditionId: Int
}

/// PATCH /api/challenges/{challengeId} 요청 바디 (multipart의 requestDto)
struct UpdateChallengeRequestDTO: Encodable {
    let newImagesSequence: [Int]
    let remainImages: [String]
    let remainImagesSequence: [Int]
    let hashtagList: [String]
    let content: String
    let journeyId: Int
    let expeditionId: Int
}

// MARK: - Response DTOs

/// 개인 챌린지 목록 응답의 한 항목
struct MyChallengeItemDTO: Decodable {
    let challengeId: Int
    let imageUrl: String
}

/// POST /api/challenges 성공 시 응답 data
struct CreateChallengeDataDTO: Decodable {
    let challengeId: Int
}

/// GET /api/challenges/{challengeId} 응답 data (챌린지 업로드 상세조회)
struct ChallengeDetailDataDTO: Decodable {
    let challengeId: Int
    let imageList: [String]
    let hashtagList: [String]
    let content: String
    let expeditionId: Int
}

/// GET /api/challenges/users/me 응답 data (페이지 형태)
struct MyChallengesPageDTO: Decodable {
    let content: [MyChallengeItemDTO]
    let size: Int?
    let number: Int?
    let first: Bool?
    let last: Bool?
    let empty: Bool?
}

/// POST /api/challenges/{challengeId}/like 응답 data
struct ChallengeLikeDataDTO: Decodable {
    let challengeId: Int
    let challengeLikeId: Int
}

/// GET /api/challenges/{challengeId}/comments 응답의 한 댓글
struct ChallengeCommentItemDTO: Decodable {
    let commentId: Int
    let nickName: String
    let profileImageUrl: String?
    let content: String
    let likeCount: Int
    let children: [String]?
}

/// GET /api/challenges/{challengeId}/comments 응답 data (페이지)
struct ChallengeCommentsPageDTO: Decodable {
    let content: [ChallengeCommentItemDTO]
    let size: Int?
    let number: Int?
    let first: Bool?
    let last: Bool?
    let empty: Bool?
}

/// POST /api/challenges/comment/{commentId}/like 응답 data
struct CommentLikeDataDTO: Decodable {
    let commentLikeId: Int
}

/// POST /api/challenges/{challengeId}/comments 응답 data
struct CommentPostDataDTO: Decodable {
    let commentId: Int
}

// MARK: - API

/// 최신순 정렬 값 (createdAt 내림차순)
private let feedSortLatest = ["createdAt,desc"]

enum ChallengeAPI {
    /// 내가 올린 챌린지 목록 (페이지)
    case getMyChallenges(page: Int, size: Int, sort: [String]?)
    /// 특정 닉네임 사용자의 챌린지 피드 상세 (페이지)
    case getUserChallengeDetails(nickname: String, page: Int, size: Int, sort: [String]?)
    /// 챌린지 업로드 (여정 공유하기) - multipart: requestDto + imageFiles
    case createChallenge(request: CreateChallengeRequestDTO, imageDatas: [Data])
    /// 챌린지 수정 - PATCH /api/challenges/{challengeId}, multipart: requestDto + imageFiles
    case updateChallenge(challengeId: Int, request: UpdateChallengeRequestDTO, imageDatas: [Data])
    /// 챌린지 업로드 상세조회
    case getChallengeDetail(challengeId: Int)
    /// 챌린지 피드 조회 (트렌딩 + 친구, 1:3 비율용) - GET /api/challenges
    case getChallengeFeed(trendingPage: Int, trendingSize: Int, friendsPage: Int, friendsSize: Int)
    /// 피드 좋아요 (토글) - POST /api/challenges/{challengeId}/like, body: { isLiked }
    case likeChallenge(challengeId: Int, request: ChallengeLikeRequestDTO)
    /// 댓글 목록 조회 - GET /api/challenges/{challengeId}/comments
    case getChallengeComments(challengeId: Int, page: Int, size: Int, sort: [String]?)
    /// 댓글 등록 - POST /api/challenges/{challengeId}/comments, body: { content, parentId }
    case postComment(challengeId: Int, request: CommentPostRequestDTO)
    /// 댓글 삭제 - DELETE /api/challenges/{challengeId}/comments/{commentId}
    case deleteComment(challengeId: Int, commentId: Int)
    /// 게시물(챌린지) 삭제 - DELETE /api/challenges/{challengeId}
    case deleteChallenge(challengeId: Int)
    /// 댓글 좋아요/취소 - POST /api/challenges/comment/{commentId}/like, body: { isLiked }
    case likeComment(commentId: Int, request: ChallengeLikeRequestDTO)
}

extension ChallengeAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("Invalid API.baseURL: \(API.baseURL)")
        }
        return url
    }

    var path: String {
        switch self {
        case .getMyChallenges:
            return "/api/challenges/users/me"
        case let .getUserChallengeDetails(nickname, _, _, _):
            return "/api/challenges/users/\(nickname)/details"
        case .createChallenge, .getChallengeFeed:
            return "/api/challenges"
        case let .updateChallenge(challengeId, _, _), let .getChallengeDetail(challengeId):
            return "/api/challenges/\(challengeId)"
        case let .likeChallenge(challengeId, _):
            return "/api/challenges/\(challengeId)/like"
        case let .getChallengeComments(challengeId, _, _, _), let .postComment(challengeId, _):
            return "/api/challenges/\(challengeId)/comments"
        case let .deleteComment(challengeId, commentId):
            return "/api/challenges/\(challengeId)/comments/\(commentId)"
        case let .deleteChallenge(challengeId):
            return "/api/challenges/\(challengeId)"
        case let .likeComment(commentId, _):
            return "/api/challenges/comment/\(commentId)/like"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMyChallenges, .getUserChallengeDetails, .getChallengeDetail, .getChallengeFeed, .getChallengeComments:
            return .get
        case .createChallenge, .likeChallenge, .likeComment, .postComment:
            return .post
        case .updateChallenge:
            return .patch
        case .deleteComment, .deleteChallenge:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .getChallengeDetail, .deleteComment, .deleteChallenge:
            return .requestPlain
        case let .getChallengeComments(_, page, size, sort):
            var params: [String: Any] = [
                "pageable.page": page,
                "pageable.size": size
            ]
            if let sort = sort, !sort.isEmpty {
                params["pageable.sort"] = sort.joined(separator: ",")
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .likeChallenge(_, request), let .likeComment(_, request):
            return .requestJSONEncodable(request)
        case let .postComment(_, request):
            return .requestJSONEncodable(request)
        case let .getChallengeFeed(trendingPage, trendingSize, friendsPage, friendsSize):
            let sortValue = feedSortLatest.joined(separator: ",")
            let params: [String: Any] = [
                "trendingPageable.page": trendingPage,
                "trendingPageable.size": trendingSize,
                "trendingPageable.sort": sortValue,
                "friendsPageable.page": friendsPage,
                "friendsPageable.size": friendsSize,
                "friendsPageable.sort": sortValue
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
        case let .getMyChallenges(page, size, sort):
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
        case let .getUserChallengeDetails(_, page, size, sort):
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
        case let .createChallenge(request, imageDatas):
            var parts: [MultipartFormData] = []
            
            // 1) requestDto (JSON data)
            if let jsonData = try? JSONEncoder().encode(request) {
                // Moya/Alamofire가 boundary를 자동으로 처리하므로,
                // 여기서는 part의 name, fileName 등을 정확히 지정
                // 서버가 요구하는 part name이 `requestDto`이고 Content-Type이 application/json이라고 가정
                let part = MultipartFormData(
                    provider: .data(jsonData),
                    name: "requestDto",
                    fileName: nil, 
                    mimeType: "application/json"
                )
                parts.append(part)
            }
            
            // 2) imageFiles (Multiple images)
            for (index, data) in imageDatas.enumerated() {
                let part = MultipartFormData(
                    provider: .data(data),
                    name: "imageFiles",
                    fileName: "image_\(index).jpg",
                    mimeType: "image/jpeg"
                )
                parts.append(part)
            }
            
            return .uploadMultipart(parts)
        case let .updateChallenge(_, request, imageDatas):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .useDefaultKeys
            var parts: [MultipartFormData] = []
            if let requestData = try? encoder.encode(request) {
                parts.append(MultipartFormData(
                    provider: .data(requestData),
                    name: "requestDto",
                    mimeType: "application/json"
                ))
            }
            for (index, data) in imageDatas.enumerated() {
                parts.append(MultipartFormData(
                    provider: .data(data),
                    name: "imageFiles",
                    fileName: "image_\(index).jpg",
                    mimeType: "image/jpeg"
                ))
            }
            return .uploadMultipart(parts)
        }
    }

    var headers: [String: String]? {
        var header: [String: String] = [:]

        switch self {
        case .createChallenge, .updateChallenge:
            // Multipart boundary는 Moya가 자동 설정
            break
        default:
            header["Content-Type"] = "application/json"
        }

        if let token = KeychainService.shared.loadToken(), !token.isEmpty {
            header["Authorization"] = "Bearer \(token)"
        }

        return header
    }
}
