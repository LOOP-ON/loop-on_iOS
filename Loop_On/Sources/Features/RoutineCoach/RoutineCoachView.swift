//
//  RoutineCoachView.swift
//  Loop_On
//
//  Created by 이경민 on 1/21/26.
//

import Foundation
import SwiftUI

struct RoutineCoachView: View {
    @StateObject private var viewModel: RoutineCoachViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State private var showContinuationPopup: Bool = false
    private let shouldShowContinuationPopupOnAppear: Bool
    
    // 브랜드 컬러 정의
    let pointColor = Color(.primaryColorVarient65)
    let backgroundColor = Color(red: 0.98, green: 0.98, blue: 0.98)
    
    // 루틴 리스트 영역 높이 (스크롤바 및 계산에 사용)
    private let routineListHeight: CGFloat = 270
    
    // 스크롤 상태
    @State private var scrollOffset: CGFloat = 0        // 현재 스크롤 위치(y, 아래로 갈수록 +)
    @State private var contentHeight: CGFloat = 0       // 전체 콘텐츠 높이
    
    init(
        routines: [RoutineCoach],
        goal: String,
        category: String,
        selectedInsights: [String],
        showContinuationPopup: Bool = false
    ) {
        let vm = RoutineCoachViewModel(initialRoutines: routines)
        vm.goal_text = goal
        vm.category = category
        vm.selected_insights = selectedInsights
        self.shouldShowContinuationPopupOnAppear = showContinuationPopup
        _viewModel = StateObject(wrappedValue: vm)
    }
    
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
                    
//                    Text("\(viewModel.journeyOrder)번째 여정의 루틴을 생성했어요")
//                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
//                        .padding(.top, 30)
                    if viewModel.journeyOrder > 0 {
                            Text("\(viewModel.journeyOrder)번째 여정의 루틴을 생성했어요")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                                .padding(.top, 30)
                        } else {
                            // 데이터 로딩 중일 때 표시할 텍스트나 ProgressView
                            Text("여정 정보를 불러오고 있어요...")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                                .padding(.top, 30)
                        }
                }
                .padding(.bottom, 20)
                HStack(alignment: .top, spacing: -10) {
                    // 루틴 리스트
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.routines.enumerated()), id: \.element.id) { index, routine in
                                RoutineRow(
                                    routine: routine,
                                    pointColor: pointColor,
                                    isEditing: viewModel.isEditing,
                                    totalCount: viewModel.routines.count,
                                    isRegenerating: viewModel.isRegenerating,
                                    onTimeTap: {
                                        viewModel.openTimePicker(for: index)
                                    },
                                    onDelete: {
                                        viewModel.deleteRoutine(at: index)
                                    },
                                    onEditName: {
                                        viewModel.prepareEditName(for: index)
                                    },
                                    onRegenerate: {
                                        viewModel.regenerateSingleRoutine(at: index)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .scrollIndicators(.hidden)
                    .frame(height: 340)
                    // iOS 최신 SwiftUI API: 실제 UIScrollView의 contentOffset/contentSize를 그대로 받음
                    .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                        geo.contentOffset.y
                    }, action: { _, newValue in
                        scrollOffset = newValue
                    })
                    .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                        geo.contentSize.height
                    }, action: { _, newValue in
                        contentHeight = newValue
                    })
                    
                    if viewModel.routines.count >= 4 {
                        // 스크롤 위치에 반응하는 커스텀 스크롤바
                        scrollBarView()
                            .padding(.trailing, 10)
                            .padding(.top, 10)
                    }
                }

                // 하단 버튼 섹션
                VStack(spacing: 6) {
                    HStack(spacing: 12) {
                        Button(action: {
                            if viewModel.isRegenerating {
                                viewModel.confirmRegeneration()
                            } else {
                                viewModel.regenerateRoutines()
                            }
                        }) {
                            Text(viewModel.isRegenerating ? "확인" : "루틴 다시 생성")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .padding(.horizontal, 15)
                                .frame(height: 33)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.isEditing ? Color("85") : pointColor)
                                )
                                .foregroundStyle(.white)
                        }
                        .disabled(viewModel.isEditing)
                        
                        Spacer()
                        
                        Button(action: {
                            print("DEBUG: View에서 버튼 클릭 감지됨. 현재 isEditing: \(viewModel.isEditing)")
                            if viewModel.isEditing {
                                viewModel.finishEditing()
                            } else {
                                viewModel.editRoutinesDirectly()
                            }
                        }) {
                            Text(viewModel.isEditing ? "완료" : "루틴 직접 수정")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .padding(.horizontal, 15)
                                .frame(height: 33)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.isRegenerating ? Color("85") : pointColor)
                                )
                                .foregroundStyle(.white)
                        }
                        .disabled(viewModel.isRegenerating)
                    }
                    
                    Spacer()
                    
                    Button(action: viewModel.startJourney) {
                        Text("여정 떠나기")
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.isEditing || viewModel.isRegenerating ? Color("85") : pointColor)
                            )
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    }
                    .disabled(viewModel.isEditing || viewModel.isRegenerating) // 수정 중엔 비활성화
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
            // MARK: - 공통 로딩 뷰 배치
            // viewModel의 isLoading 상태에 따라 화면에 나타남.
            if viewModel.isLoading {
                CommonLoadingView(
                    message: "2박 3일 여정으로 떠나고 있습니다",
                    lottieFileName: "Loading 51 _ Monoplane"
                )
                .transition(.opacity)
                .zIndex(1)
            }

            if showContinuationPopup {
                CommonPopupView(
                    isPresented: $showContinuationPopup,
                    title: "이전 여정을 100% 완수해서 루틴이 하나 추가되었어요!",
                    message: "필요 없다면 변경할 수 있습니다.",
                    leftButtonText: "확인",
                    leftAction: {
                        showContinuationPopup = false
                    },
                    onClose: {
                        showContinuationPopup = false
                    }
                )
                .zIndex(2)
            }
        }
        // 여정 시작 성공 시 HomeView로 이동
        .fullScreenCover(isPresented: $viewModel.isJourneyStarted) {
            HomeView() // 이동할 메인 화면
        }
        
        .alert("루틴 이름 수정", isPresented: $viewModel.isShowingNameEditor) {
            TextField("새로운 루틴 이름을 입력하세요", text: $viewModel.newRoutineName)
            Button("취소", role: .cancel) { }
            Button("확인") {
                viewModel.updateRoutineName()
            }
        } message: {
            Text("변경할 루틴의 이름을 입력해 주세요.")
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
        .onAppear {
            // 화면 진입 시 API 호출
            viewModel.fetchJourneyOrder()
            if shouldShowContinuationPopupOnAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showContinuationPopup = true
                }
            }
        }
    }
}

// MARK: - 커스텀 스크롤바 뷰 & 계산 메서드 수정
extension RoutineCoachView {
    // 조절하고 싶은 전체 트랙 길이
    private var customTrackHeight: CGFloat { 280 }

    @ViewBuilder
    fileprivate func scrollBarView() -> some View {
        if contentHeight > routineListHeight {
            let thumbHeight: CGFloat = 90 // 가변이 아닌 고정 길이를 원하시면 여기서 직접 지정 가능
            
            ZStack(alignment: .top) {
                // 스크롤바 트랙 (배경 선)
                Capsule()
                    .fill(Color("95"))
                    .frame(width: 4, height: customTrackHeight)
                
                // 실제 움직이는 thumb (진한 회색 바)
                Capsule()
                    .fill(Color("85"))
                    .frame(width: 4, height: thumbHeight)
                    .offset(y: scrollBarThumbOffset(trackHeight: customTrackHeight, thumbHeight: thumbHeight))
                    .animation(.easeInOut(duration: 0.15), value: scrollOffset)
            }
            .padding(.trailing, 8)
            .padding(.top, (routineListHeight - customTrackHeight) / 2)
        }
    }
    
    /// 현재 스크롤 offset 에 따른 thumb 의 Y 위치 계산
    fileprivate func scrollBarThumbOffset(trackHeight: CGFloat, thumbHeight: CGFloat) -> CGFloat {
        let maxScrollable = max(contentHeight - routineListHeight, 0)
        guard maxScrollable > 0 else { return 0 }
        
        let progress = min(max(scrollOffset / maxScrollable, 0), 1)
        
        // 조절된 트랙 높이(trackHeight) 내에서 thumb 가 이동할 거리를 계산
        let availableTravel = max(trackHeight - thumbHeight, 0)
        
        return progress * availableTravel
    }
}

// MARK: - Preview
#Preview{
    RoutineCoachView(
        routines: [],
        goal: "건강한 생활 만들기",
        category: "ROUTINE",
        selectedInsights: []
    )
            .environmentObject(HomeViewModel())
}
