//
//  NetworkError.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case noData
    case decodingFailed
    case unauthorized
    case notFound
    case serverError(code: Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .requestFailed(let error):
            return "요청 실패: \(error.localizedDescription)"
        case .noData:
            return "데이터가 없습니다."
        case .decodingFailed:
            return "응답을 해석할 수 없습니다."
        case .unauthorized:
            return "로그인이 필요합니다."
        case .notFound:
            return "리소스를 찾을 수 없습니다."
        case .serverError(let code):
            return "서버 오류 발생 (코드: \(code))"
        case .unknown:
            return "알 수 없는 오류입니다."
        }
    }
}

enum ImageLoadError: Error, LocalizedError {
    case invalidData
    case decodingFailed
    case networkFailed(Error)
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "이미지 데이터가 유효하지 않습니다."
        case .decodingFailed:
            return "이미지를 불러오는 데 실패했습니다."
        case .networkFailed(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .fileNotFound:
            return "이미지 파일을 찾을 수 없습니다."
        }
    }
}

// MARK: - 네트워크 오류 타입 정의

/// 네트워크 요청 중 발생할 수 있는 다양한 오류를 정의.
/// 각 case는 실제 서비스에서 발생할 수 있는 일반적인 상황을 커버함.
public enum NetworkError: Error {
    
    /// 인터넷 연결이 없거나 서버에 연결할 수 없음.
    case networkError(message: String)
    /// JSON 디코딩에 실패했을 때.
    case decodingError(underlyingError: DecodingError)
    /// 서버가 에러 응답을 반환했을 때 (상태 코드 기반).
    case serverError(statusCode: Int, message: String)
    /// 인증이 만료되었거나 유효하지 않아 재로그인이 필요한 상태.
    case unauthorized
    /// 원인을 특정할 수 없는 기타 오류.
    case unknown
}

// MARK: - 사용자에게 보여줄 수 있는 에러 메시지 구현

/// Swift의 LocalizedError 프로토콜을 채택하여
/// 각 에러에 맞는 사용자 친화적인 메시지를 제공.
/// 이걸 통해 ViewModel에서 `error.localizedDescription` 으로 간단히 에러 메시지를 표시할 수 있음.
extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError(let msg):
            return "네트워크 오류: \(msg)"
            
        case .decodingError(let err):
            return "디코딩 오류: \(err.localizedDescription)"
            
        case .serverError(let code, let msg):
            return "서버 오류 \(code): \(msg)"
            
        case .unauthorized:
            return "로그인이 필요합니다."
            
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
