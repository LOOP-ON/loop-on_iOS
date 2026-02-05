import Foundation
import Observation

/// 회원가입 플로우(이메일/비번/약관 → 프로필)에서 화면 간 데이터를 전달하기 위한 공유 스토어
/// - 백엔드 명세(`/api/users`)가 닉네임/프로필이미지URL/약관ID까지 한 번에 받기 때문에
///   1단계에서 입력한 값을 저장해두고, 프로필 단계에서 최종 회원가입 요청을 보냄.
@Observable
final class SignUpFlowStore {
    // 1단계(이메일/비밀번호)
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var agreedTermIds: [Int] = []
    
    // 2단계(프로필)
    var nickname: String = ""
    var profileImageUrl: String? = nil
    
    /// 화면 간 이동 시점에 공백/개행을 제거해 저장
    func setCredentials(email: String, password: String, confirmPassword: String) {
        self.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        self.password = password
        self.confirmPassword = confirmPassword
    }
    
    func setAgreedTermIds(_ ids: [Int]) {
        // 서버로 보낼 때는 중복 제거/정렬해서 안정적으로 보냄
        self.agreedTermIds = Array(Set(ids)).sorted()
    }
    
    func setProfile(nickname: String, profileImageUrl: String?) {
        self.nickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        self.profileImageUrl = profileImageUrl
    }
    
    /// 회원가입 완료 후 다음 가입 시도를 위해 초기화
    func reset() {
        email = ""
        password = ""
        confirmPassword = ""
        agreedTermIds = []
        nickname = ""
        profileImageUrl = nil
    }
}

