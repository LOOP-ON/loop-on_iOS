//
//  RoutineRow.swift
//  Loop_On
//
//  Created by 이경민 on 1/22/26.
//

import Foundation
import SwiftUI

struct RoutineRow: View {
    let routine: RoutineCoach
    let pointColor: Color
    let isEditing: Bool // 편집 모드 상태 주입
    let totalCount: Int // 추가: 전체 루틴 개수 파악용
    
    var onTimeTap: () -> Void
    var onDelete: () -> Void // 삭제 액션
    var onEditName: () -> Void // 이름 수정 액션
    
    var body: some View {
        HStack(spacing: 15) {
            // 좌측 루틴 인덱스 뱃지
            Text("루틴 \(routine.index)")
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.primaryColorVarient95))
                )
                .foregroundStyle(pointColor)
            
            // 우측 콘텐츠 영역 (이름 행 + 시간 행)
            VStack(alignment: .leading, spacing: 8) {
                
                // [첫 번째 행] 루틴 이름과 편집 아이콘들
                HStack(alignment: .center) {
                    Text(routine.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                    
                    // 편집 모드일 때만 아이콘 표시
                    if isEditing {
                        HStack(spacing: 16) {
                            // 이름 수정(연필) 버튼
                            Button(action: onEditName) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.black)
                            }
                            
                            // 삭제(X) 버튼
                            if totalCount >= 4 {
                                Button(action: onDelete) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.black)
                                    }
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                            }
                        }
                    }
                }
                
                Divider()
                
                // [두 번째 행] 알림 시간 설정 버튼
                Button(action: {
                    if !isEditing { // 편집 모드가 아닐 때만 시간 변경 가능하게 설정 가능
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        onTimeTap()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell")
                            .font(.system(size: 14))
                        
                        Text("알림 시간")
                            .font(.system(size: 14))
                        
                        Text(formatDate(routine.alarmTime))
                            .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .foregroundStyle(Color("25-Text"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .foregroundStyle(.gray)
                }
                .opacity(isEditing ? 0.5 : 1.0)
                .disabled(isEditing)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .animation(.spring(), value: isEditing) // 모드 전환 시 부드러운 애니메이션
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a hh:mm"
        return formatter.string(from: date)
    }
}


struct RoutineRow_Previews: PreviewProvider {
    static var previews: some View {
        RoutineRow(
            routine: RoutineCoach(index: 1, name: "루틴 이름", alarmTime: Date()),
            pointColor: Color(.primaryColorVarient65),
            isEditing: false,
            totalCount: 4,
            onTimeTap: { print("시간 선택 클릭됨") },
            onDelete: { print("삭제 클릭됨") },
            onEditName: { print("이름 수정 클릭됨") }
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Color.gray.opacity(0.1))
    }
}
