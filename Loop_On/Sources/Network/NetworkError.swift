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
