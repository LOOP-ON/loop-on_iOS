//
//  RoutineCoachView.swift
//  Loop_On
//
//  Created by 이경민 on 1/21/26.
//

import Foundation
import SwiftUI

struct RoutineCoachView: View {
    @StateObject private var viewModel = RoutineCoachViewModel()
    
    // 브랜드 컬러 정의
    let pointColor = Color(.primaryColorVarient65)
    let backgroundColor = Color(red: 0.98, green: 0.98, blue: 0.98)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 아이콘 및 텍스트
                VStack(spacing: 12) {
                    Image(systemName: "suitcase.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(pointColor)
                        .padding(.top, 96)
                    
                    Text("여정을 떠날 계획을 세워볼까요?")
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                    
                    Text("두 번째 여정의 루틴을 생성했어요")
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                        .padding(.top, 30)
                }
                .padding(.bottom, 20)
                
                // 루틴 리스트
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.routines.enumerated()), id: \.element.id) { index, routine in
                            RoutineRow(
                                routine: routine,
                                pointColor: pointColor,
                                onTimeTap: {
                                    viewModel.openTimePicker(for: index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 286)
                
                // 하단 버튼 섹션
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Button(action: viewModel.regenerateRoutines) {
                            Text("루틴 다시 생성")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .frame(width: 106, height: 33)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(pointColor)
                                )
                                .foregroundStyle(.white)
                                
                        }
                        
                        Spacer()
                        
                        Button(action: viewModel.editRoutinesDirectly) {
                            Text("루틴 직접 수정")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .frame(width: 106, height: 33)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(pointColor)
                                )
                                .foregroundStyle(.white)
                                
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: viewModel.startJourney) {
                        Text("여정 떠나기")
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(pointColor)
                            )
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        // 시간 선택 팝업
        .sheet(isPresented: $viewModel.isShowingTimePicker) {
            TimePickerSheet(
                selectedDate: $viewModel.tempSelectionDate,
                onSave: {
                    // 시트가 닫힐 때 자동으로 호출되어 루틴 시간이 업데이트
                    viewModel.saveSelectedTime()
                },
                onClose: {
                    viewModel.isShowingTimePicker = false
                }
            )
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.hidden)
        }
    }
}

// 각 루틴 카드 컴포넌트
struct RoutineRow: View {
    let routine: RoutineCoach
    let pointColor: Color
    // 시간 선택 영역을 눌렀을 때 실행할 액션
    var onTimeTap: () -> Void
    
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
                
            
            VStack(alignment: .leading, spacing: 8) {
                // 루틴 이름
                Text(routine.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.black)
                
                // 시간 선택 버튼 영역
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    onTimeTap() // ViewModel의 팝업 열기 함수 호출
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
                    .foregroundStyle(.gray) // "알림 시간" 텍스트와 아이콘 색상
                }
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        // 카드 그림자 효과
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 데이트 포맷터 함수
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        // 오전/오후 hh:mm 형식
        formatter.dateFormat = "a hh:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct RoutineRow_Previews: PreviewProvider {
    static var previews: some View {
        RoutineRow(
            routine: RoutineCoach(index: 1, name: "루틴 이름", alarmTime: Date()),
            pointColor: Color(.primaryColorVarient65),
            onTimeTap: { print("시간 선택 클릭됨") }
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Color.gray.opacity(0.1))
    }
}

#Preview{
    RoutineCoachView()
}
