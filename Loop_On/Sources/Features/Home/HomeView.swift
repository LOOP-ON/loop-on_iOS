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
                    HomeHeaderView(onSettingsTapped: {
                        router.push(.app(.settings))
                    })
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    
                    if let info = viewModel.journeyInfo {
                        journeyTitleView(info: info)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        JourneyProgressCardView(
                            completed: info.completedJourney,
                            total: info.totalJourney
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
            HStack(spacing: 8) {
                Text("목표")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("PrimaryColor55"))
                
                Text(viewModel.goalTitle.isEmpty ? "목표를 불러오는 중..." : viewModel.goalTitle)
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                    .foregroundStyle(Color.black)
            }
            .padding(.horizontal, 2)
            .background(
                Rectangle()
                    .fill(Color(red: 0xEE/255, green: 0x4B/255, blue: 0x2B/255, opacity: 0x33/255))
                    .frame(height: 8),
                alignment: .bottomLeading
            )

            VStack(spacing: 8) {
                ForEach(0..<viewModel.routines.count, id: \.self) { index in
                    // 객체 전체를 전달
                    RoutineCardView(
                        routine: viewModel.routines[index],
                        // 미완료 루틴 처리 모드라면 '인증' 버튼 비활성화
                        isConfirmDisabled: viewModel.hasUncompletedRoutines,
                        
                        onConfirm: {
                            viewModel.selectRoutine(at: index)
                            viewModel.completeRoutine(at: index)
                        },
                        onDelay: {
                            viewModel.selectRoutine(at: index)
                            viewModel.activeFullSheet = .delay
                        },
                        onViewDelay: {
                            viewModel.selectRoutine(at: index)
                            viewModel.activeFullSheet = .viewDelay
                        }
                    )
                }
            }
        }
    }

    var recordButton: some View {
        Button(action: {
            // 전날 미완료 루틴 처리 모드일 때 (hasUncompletedRoutines == true)
            if viewModel.hasUncompletedRoutines {
                // 아직 완료/미루기가 안 된 첫 번째 카드를 찾아 미루기 팝업 노출
                if let firstIdx = viewModel.routines.firstIndex(where: { !$0.isCompleted && !$0.isDelayed }) {
                    viewModel.selectRoutine(at: firstIdx)
                    viewModel.activeFullSheet = .delay
                }
            }
            // 평상시 모드일 때 (전날 완료했거나 오늘 루틴 진행 중)
            else {
                viewModel.activeFullSheet = .reflection
            }
        }) {
            // 텍스트 판단 기준을 플래그로 변경
            Text(viewModel.hasUncompletedRoutines ? "미완료 루틴 미루기" : "여정 기록하기")
                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, minHeight: 56)
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
                            router.push(.app(.routineCoach(routines: viewModel.routinesForCoaching, journeyId: viewModel.journeyInfo?.loopId ?? 0)))
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
                ),
                onDelaySuccess: { reason in
                    viewModel.delayRoutine(at: viewModel.selectedRoutineIndex, reason: reason)
                },
                isReadOnly: viewModel.selectedRoutine?.isDelayed ?? false,
                initialReason: viewModel.selectedRoutine?.delayReason
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
            
        case .viewDelay:
            DelayPopupView(
                index: viewModel.selectedRoutineIndex,
                title: viewModel.selectedRoutine?.title ?? "",
                isPresented: Binding(
                    get: { viewModel.activeFullSheet == .viewDelay },
                    set: { if !$0 { viewModel.activeFullSheet = nil } }
                ),
                onDelaySuccess: { reason in
                    viewModel.delayRoutine(at: viewModel.selectedRoutineIndex, reason: reason)
                },
                isReadOnly: true, // 확인 모드로 실행
                initialReason: viewModel.selectedRoutine?.delayReason // 저장된 사유 전달
            )
            .presentationBackground(.clear)
        
        // 전날 미완료 루틴이 있을 때 로직
        case .uncompletedRoutineAlert:
                CommonPopupView(
                    isPresented: .constant(true),
                    title: "어제 완료되지 않은 루틴있어요!",
                    message: "모든 루틴의 ‘미루기’를 완료해야 오늘 루틴을 확\n인할 수 있습니다.\n어제 루틴을 완료하지 못한 이유를 기록해주세요 :)",
                    leftButtonText: "취소",
                    rightButtonText: "미완료 루틴 기록하기",
                    leftAction: { viewModel.activeFullSheet = nil },
                    rightAction: {
                        // 기록하기 버튼 클릭 시 미루기(사유 입력) 팝업으로 연결
                        viewModel.activeFullSheet = .delay
                    },
                    onClose: { viewModel.activeFullSheet = nil }
                )
                .presentationBackground(.clear)
        }
    }
}

#Preview {
    RootView()
        .environment(NavigationRouter())
        .environment(SessionStore())
        .environment(SignUpFlowStore())
}
