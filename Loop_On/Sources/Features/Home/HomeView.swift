//
//  HomeView.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import SwiftUI
import AVFoundation

struct HomeView: View {
    @Environment(NavigationRouter.self) var router
    @StateObject private var viewModel = HomeViewModel()
    
    // 카메라 권한 Alert은 View에서 관리하는 것이 SwiftUI 관례에 적합
    @State private var isShowingPermissionAlert = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    HomeHeaderView()
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    
                    if let info = viewModel.journeyInfo {
                        journeyTitleView(info: info)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        JourneyProgressCardView(
                            completed: info.completedCount,
                            total: info.totalCount
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    
                    routineSectionView
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    recordButton
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                }
                .safeAreaPadding(.top, 1)
                .background(Color(.systemGroupedBackground))
            }
        }
        // 풀스크린 커버 제어를 ViewModel에서 위임받음
        .fullScreenCover(item: $viewModel.activeFullSheet) { sheet in
            fullSheetContent(for: sheet)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isShowingDelayPopup)
        .alert("현재 카메라에 대한 접근 권한이 없습니다.", isPresented: $isShowingPermissionAlert) {
            Button("확인") { }
        } message: {
            Text("휴대폰 설정 > LOOP:ON > 카메라에서 권한을 허용 해주세요 :)")
        }
    }
}

// MARK: - Subviews & Layout Logic
private extension HomeView {
    
    func journeyTitleView(info: JourneyInfo) -> some View {
        HStack {
            VStack(alignment: .leading) {
                // loopId를 사용하여 "n번째 여정" 출력
                Text("\(info.loopId)번째 여정")
                    .font(.system(size: 22, weight: .bold))
                
                Text("\(info.currentDay)일차 여정 진행 중")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.primaryColorVarient65))
            }
            Spacer()
        }
    }

    var routineSectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("목표 건강한 생활 만들기")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(.primaryColorVarient65))

            VStack(spacing: 8) {
                ForEach(0..<viewModel.routines.count, id: \.self) { index in
                    // 객체 전체를 전달
                    RoutineCardView(
                        routine: viewModel.routines[index],
                        onConfirm: {
                            viewModel.selectRoutine(at: index)
                            viewModel.completeRoutine(at: index)
                        },
                        onDelay: {
                            viewModel.selectRoutine(at: index)
                            viewModel.activeFullSheet = .delay
                        }
                    )
                }
            }
        }
    }

    var recordButton: some View {
        Button(action: {
            viewModel.activeFullSheet = .reflection
        }) {
            Text("여정 기록하기") // 필요 시 Reflection 상태 바인딩 추가
                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.primaryColorVarient65)))
        }
    }

    // FullScreenCover 라우팅 로직 분리
    @ViewBuilder
    func fullSheetContent(for sheet: ActiveFullSheet) -> some View {
        switch sheet {
        case .camera:
            CameraView(
                routineTitle: viewModel.selectedRoutine?.title ?? "",
                routineIndex: viewModel.selectedRoutineIndex,
                isPresented: Binding(
                    get: { viewModel.activeFullSheet == .camera },
                    set: { if !$0 { viewModel.activeFullSheet = nil } }
                )
            )
        case .finishJourney:
            CommonPopupView(
                isPresented: .constant(true),
                title: "3일 여정이 끝났어요!",
                message: "이번 루프를 돌아보러 갈까요?",
                leftButtonText: "다음 루프 시작하기",
                rightButtonText: "리포트 보기",
                leftAction: {
                    viewModel.activeFullSheet = .continueJourney
                },
                rightAction: {
                    viewModel.activeFullSheet = .journeyReport
                },
                onClose: { viewModel.activeFullSheet = nil }
            )
            .presentationBackground(.clear)
        case .continueJourney:
            CommonPopupView(
                isPresented: .constant(true),
                title: "여정을 이어갈까요?",
                leftButtonText: "이어가기",
                rightButtonText: "새롭게 시작하기",
                leftAction: {
                    viewModel.activeFullSheet = .loading
                    viewModel.createNewJourney()
                },
                rightAction: { viewModel.activeFullSheet = nil },
                onClose: { viewModel.activeFullSheet = nil }
            )
            .presentationBackground(.clear)
        case .loading:
            CommonLoadingView(message: "2번째 여정을 생성중입니다", lottieFileName: "Loading 51 _ Monoplane")
                .onChange(of: viewModel.isJourneyCreated) { _, newValue in
                    if newValue {
                        viewModel.activeFullSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            router.push(.app(.routineCoach))
                            viewModel.resetJourneyStatus()
                        }
                    }
                }
        case .reflection:
            if let info = viewModel.journeyInfo {
                ReflectionPopupView(
                    viewModel: ReflectionViewModel(loopId: info.loopId, currentDay: info.currentDay),
                    isPresented: Binding(
                        get: { viewModel.activeFullSheet == .reflection },
                        set: { if !$0 { viewModel.activeFullSheet = nil } }
                    )
                )
                .presentationBackground(.clear)
            } else {
                EmptyView()
            }
        case .delay: 
            DelayPopupView(
                index: viewModel.selectedRoutineIndex,
                title: viewModel.selectedRoutine?.title ?? "",
                isPresented: Binding(
                    get: { viewModel.activeFullSheet == .delay },
                    set: { if !$0 { viewModel.activeFullSheet = nil } }
                )
            )
            .presentationBackground(.clear)
//        case .journeyReport:
//            JourneyReportView(
//                isPresented: Binding(
//                    get: { viewModel.activeFullSheet == .journeyReport },
//                    set: { if !$0 { viewModel.activeFullSheet = nil } }
//                ),
//                loopId: viewModel.journeyInfo?.loopId ?? 1
//            )
//            .presentationBackground(.clear)
        case .journeyReport:
            JourneyReportView(
                isPresented: Binding(
                    get: { viewModel.activeFullSheet == .journeyReport },
                    set: { if !$0 { viewModel.activeFullSheet = nil } }
                ),
                loopId: viewModel.journeyInfo?.loopId ?? 1,
                onShare: {
                    // 리포트 팝업이 닫히는 애니메이션과 겹치지 않도록 약간의 지연 후 공유 화면을 띄움
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.activeFullSheet = .shareJourney
                    }
                }
            )
            .presentationBackground(.clear)
        case .shareJourney:
            ShareJourneyView()
        }
    }
}

#Preview {
    RootView()
        .environment(NavigationRouter())
        .environment(SessionStore())
}
