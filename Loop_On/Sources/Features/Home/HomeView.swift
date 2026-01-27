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
    // 팝업 제어를 위한 상태 변수 추가
    @State private var isShowingDelayPopup = false  // 미루기 팝업 상태 변수
    @State private var selectedRoutineTitle = ""    // 루틴 제목 저장 상태 변수
    @State private var selectedRoutineIndex = 1     // 선택된 루틴의 번호를 저장
    @State private var isReflectionCompleted = false    // 여정 기록 완료 상태 추가
    
    // 카메라 관련 상태 변수 추가
    @State private var isShowingPermissionAlert = false
    @State private var activeFullSheet: ActiveFullSheet?    // 활성화된 시트 관리 변수

    var body: some View {
            ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        HomeHeaderView(onSettingsTapped: {
                            router.push(.app(.settings))
                        })
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        
                        journeyTitleView
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        JourneyProgressCardView(
                            completed: viewModel.completedCount,
                            total: viewModel.totalCount
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                        // 루틴 섹션에서 팝업 호출 연결
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
                
                // 팝업 조건부 표시
                if isShowingDelayPopup {
                    DelayPopupView(
                        index: selectedRoutineIndex,    // 선택된 루틴 카드 인덱스
                        title: selectedRoutineTitle,    // 선택된 루틴 이름
                        isPresented: $isShowingDelayPopup
                    )
                    .transition(.opacity.combined(with: .scale(scale: 1.1))) // 나타날 때 효과
                    .zIndex(1) // 다른 뷰보다 항상 위에 있도록 보장
                }
            }
            .fullScreenCover(item: $activeFullSheet) { sheet in
                switch sheet {
                case .camera:
                    CameraView(
                        routineTitle: selectedRoutineTitle,
                        routineIndex: selectedRoutineIndex,
                        isPresented: Binding(
                            get: { activeFullSheet == .camera },
                            set: { if !$0 { activeFullSheet = nil } }
                        )
                    )
                    
                    // 여정 완료 팝업
                case .finishJourney:
                    CommonPopupView(
                        title: "3일 여정이 끝났어요!",
                        message: "이번 루프를 돌아보러 갈까요?",
                        leftButtonText: "다음 루프 시작하기",
                        rightButtonText: "리포트 보기",
                        leftAction: {
                            activeFullSheet = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                activeFullSheet = .continueJourney
                            }
                        },
                        rightAction: {
                            activeFullSheet = nil
                            // 리포트 이동 로직
                        }
                    )
                    .presentationBackground(.clear)
                    
                    // 여정 지속 여부 확인
                case .continueJourney:
                    CommonPopupView(
                        title: "여정을 이어갈까요?",
                        leftButtonText: "이어가기",
                        rightButtonText: "새롭게 시작하기",
                        leftAction: {
                            activeFullSheet = .loading
                            // 이어가기 로직
                            viewModel.createNewJourney()
                        },
                        rightAction: {
                            activeFullSheet = nil
                            // 새롭게 시작 로직
                        }
                    )
                    .presentationBackground(.clear)
                    
                // 새 여정 생성 로딩 화면 호출
                case .loading:
                    CommonLoadingView(
                        message: "2번째 여정을 생성중입니다",
                        lottieFileName: "Loading 51 _ Monoplane"
                    )
                    .onChange(of: viewModel.isJourneyCreated) { oldValue, newValue in
                        if newValue {
                            // 열려있는 풀 시트(로딩)를 닫음
                            activeFullSheet = nil
                            
                            // 시트가 내려가는 애니메이션 시간(0.4초) 뒤에 실제 페이지 이동
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                router.push(.app(.routineCoach))
                                viewModel.resetJourneyStatus()
                            }
                        }
                    }
                    
                // 여정 기록 팝업
                case .reflection:
                    ReflectionPopupView(
                        isPresented: Binding(
                            get: { activeFullSheet == .reflection },
                            set: { if !$0 { activeFullSheet = nil } }
                        ),
                        isCompleted: $isReflectionCompleted
                    )
                    .presentationBackground(.clear)
                }
            }
            .onReceive(viewModel.$isShowingFinishPopup) { isShowing in
                if isShowing {
                    activeFullSheet = .finishJourney
                    viewModel.isShowingFinishPopup = false // 중복 호출 방지를 위해 초기화
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isShowingDelayPopup) // 부드러운 등장
            //권한 알림 연결
            .alert("현재 카메라에 대한\n접근 권한이 없습니다.", isPresented: $isShowingPermissionAlert) {
                Button("확인") { }
            } message: {
                Text("휴대폰 설정 > LOOP:ON > 카메라에서 권한을 허용 해주세요 :)")
            }
        }
    }

// MARK: - Subviews
private extension HomeView {
    // 카메라 권한 체크 로직
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    activeFullSheet = .camera
                } else {
                    isShowingPermissionAlert = true
                }
            }
        }
    }

    var journeyTitleView: some View {
        HStack{
            VStack(alignment: .leading) {
                Text("첫 번째 여정")
                    .font(.system(size: 22, weight: .bold))
                
                Text("1일차 여정 진행 중")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.primaryColorVarient65))
            }
            Spacer()
        }
    }

    var routineSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("목표 건강한 생활 만들기")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(.primaryColorVarient65))

            VStack(spacing: 8) {
                ForEach(0..<viewModel.routines.count, id: \.self) { index in
                    let routine = viewModel.routines[index]
                    RoutineCardView(
                        title: routine.title,
                        time: routine.time,
                        isCompleted: routine.isCompleted,
                        onConfirm: {
                            // 인증 버튼 클릭 시 카메라 권한 확인 후 동작
                            selectedRoutineIndex = index + 1
                            selectedRoutineTitle = routine.title
                            
                            // 실제로는 카메라 촬영 완료 후 아래 함수를 호출해야 함
//                            requestCameraPermission() // 바로 완료하지 않고 권한 체크 및 카메라 호출
                            // 여기서는 즉시 완료되는 예시로 작성
                            viewModel.completeRoutine(at: index)
                        },
                        onDelay: {
                            selectedRoutineIndex = index + 1
                            selectedRoutineTitle = routine.title
                            isShowingDelayPopup = true
                        }
                    )
                }
            }
        }
    }

    var recordButton: some View {
        Button(action: {
            activeFullSheet = .reflection     // 버튼 클릭시 여정 기록 팝업
        }) {
            Text(isReflectionCompleted ? "기록 수정하기" : "여정 기록하기")
                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.primaryColorVarient65))
                )
        }
    }
}


#Preview {
    RootView()
        .environment(NavigationRouter())
        .environment(SessionStore())
}
