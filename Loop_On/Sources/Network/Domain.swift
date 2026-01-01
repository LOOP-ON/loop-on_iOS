//
//  Domain.swift
//  Loop_On
//
//  Created by 이경민 on 12/31/25.
//
import Foundation

public struct API {
    
    /// 전체 서버의 공통 Base URL
    /// 각 Feature API의 path는 이 baseURL에 붙여서 구성
    public static let baseURL = "https://example.com"

    // MARK: - 주요 기능별 Endpoint 경로
    
    /// 로그인 관련 API
    static let loginURL = "\(baseURL)/auth/login"
    
    /// 유저 정보 관련 API
    static let userURL = "\(baseURL)/users"
    
    /// 게시글 관련 API
    static let postURL = "\(baseURL)/posts"
}

