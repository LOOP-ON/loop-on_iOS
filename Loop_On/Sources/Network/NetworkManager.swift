import Foundation
import Moya

// 응답 데이터가 없는 경우를 위한 빈 구조체
struct EmptyData: Decodable {}

protocol NetworkManager {
    associatedtype Endpoint: TargetType
    var provider: MoyaProvider<Endpoint> { get }
    func request<T: Decodable>(target: Endpoint, decodingType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void)
    func requestStatusCode(target: Endpoint, completion: @escaping (Result<Void, NetworkError>) -> Void)
}

final class DefaultNetworkManager<API: TargetType>: NetworkManager {
    typealias Endpoint = API
    let provider: MoyaProvider<API>

    init(stub: Bool = false, plugins: [PluginType] = []) {
        if stub {
            provider = MoyaProvider<API>(stubClosure: MoyaProvider.immediatelyStub, plugins: plugins)
        } else {
            provider = MoyaProvider<API>(plugins: plugins)
        }
    }

    // 일반 데이터 요청
    func request<T: Decodable>(target: Endpoint, decodingType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        provider.request(target) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                completion(self.handleResponse(response, decodingType: decodingType))
            case .failure(let error):
                completion(.failure(self.handleNetworkError(error)))
            }
        }
    }

    // ✅ ProfileViewModel에서 사용하는 상태 코드 요청 함수 복구
    func requestStatusCode(target: Endpoint, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        provider.request(target) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if (200...299).contains(response.statusCode) {
                    completion(.success(()))
                } else {
                    if response.statusCode == 401 {
                        self.notifyAuthenticationRequired()
                        completion(.failure(.unauthorized))
                        return
                    }
                    let base = try? JSONDecoder().decode(BaseResponse<EmptyData>.self, from: response.data)
                    let message = base?.message ?? "서버 오류"
                    if self.isAuthenticationRequired(message: message) {
                        self.notifyAuthenticationRequired()
                        completion(.failure(.unauthorized))
                        return
                    }
                    completion(.failure(.serverError(statusCode: response.statusCode, message: message)))
                }
            case .failure(let error):
                completion(.failure(self.handleNetworkError(error)))
            }
        }
    }

    private func handleResponse<T: Decodable>(_ response: Response, decodingType: T.Type) -> Result<T, NetworkError> {
        if response.statusCode == 401 {
            notifyAuthenticationRequired()
            return .failure(.unauthorized)
        }

        do {
            // AuthViewModel에 정의된 BaseResponse 구조로 먼저 읽음
            let baseResponse = try JSONDecoder().decode(BaseResponse<T>.self, from: response.data)
            
            if baseResponse.result == "SUCCESS" {
                if let resultData = baseResponse.data {
                    return .success(resultData)
                }
                return .failure(.serverError(statusCode: response.statusCode, message: "데이터가 없습니다."))
            } else {
                let message = baseResponse.message ?? "서버 오류"
                if response.statusCode == 401 || isAuthenticationRequired(message: message) {
                    notifyAuthenticationRequired()
                    return .failure(.unauthorized)
                }
                return .failure(.serverError(statusCode: response.statusCode, message: message))
            }
        } catch let error as DecodingError {
            return .failure(.decodingError(underlyingError: error))
        } catch {
            return .failure(.unknown)
        }
    }

    private func handleNetworkError(_ error: Error) -> NetworkError {
        let nsError = error as NSError
        #if DEBUG
        print("🔴 NetworkError: domain=\(nsError.domain), code=\(nsError.code), \(nsError.localizedDescription)")
        #endif
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet: return .networkError(message: "인터넷 연결 없음")
        case NSURLErrorTimedOut: return .networkError(message: "요청 시간 초과")
        default: return .networkError(message: "네트워크 오류 발생")
        }
    }

    private func isAuthenticationRequired(message: String) -> Bool {
        let normalized = message.replacingOccurrences(of: " ", with: "")
        return normalized.contains("로그인이필요") ||
            normalized.localizedCaseInsensitiveContains("unauthorized") ||
            normalized.localizedCaseInsensitiveContains("forbidden")
    }

    private func notifyAuthenticationRequired() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .authenticationRequired, object: nil)
        }
    }
}
