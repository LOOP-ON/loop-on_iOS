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
                                isEditing: viewModel.isEditing,
                                onTimeTap: {
                                    viewModel.openTimePicker(for: index)
                                },
                                onDelete: {
                                    viewModel.deleteRoutine(at: index)
                                },
                                onEditName: {
                                    print("\(index)번째 루틴 이름 수정 클릭")
                                    // 필요 시 루틴 이름 수정 팝업 로직 연결
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
                                        .fill(viewModel.isEditing ? Color("85") : pointColor)
                                )
                                .foregroundStyle(.white)
                        }
                        .disabled(viewModel.isEditing) // 수정 중엔 비활성화
                        
                        Spacer()
                        
                        Button(action: {
                            if viewModel.isEditing {
                                viewModel.finishEditing()
                            } else {
                                viewModel.editRoutinesDirectly()
                            }
                        }) {
                            Text(viewModel.isEditing ? "완료" : "루틴 직접 수정")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .frame(width: 106, height: 33)
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
                                    .fill(viewModel.isEditing ? Color("85") : pointColor)
                            )
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    }
                    .disabled(viewModel.isEditing) // 수정 중엔 비활성화
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

// MARK: - Preview
#Preview{
    RoutineCoachView()
}
