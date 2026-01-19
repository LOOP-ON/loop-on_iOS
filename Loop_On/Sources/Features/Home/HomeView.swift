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
    // 팝업 제어를 위한 상태 변수 추가
    @State private var isShowingDelayPopup = false  // 미루기 팝업 상태 변수
    @State private var selectedRoutineTitle = ""    // 루틴 제목 저장 상태 변수
    @State private var selectedRoutineIndex = 1     // 선택된 루틴의 번호를 저장
    
    // 카메라 관련 상태 변수 추가
    @State private var isShowingCamera = false
    @State private var isShowingPermissionAlert = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    HomeHeaderView()
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    journeyTitleView
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    JourneyProgressCardView(completed: 0, total: 3)
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
        .animation(.easeInOut(duration: 0.2), value: isShowingDelayPopup) // 부드러운 등장
        .fullScreenCover(isPresented: $isShowingCamera) {   // 카메라 기능
            CameraView(
                routineTitle: selectedRoutineTitle,
                routineIndex: selectedRoutineIndex,
                isPresented: $isShowingCamera
            )
        }
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
                    isShowingCamera = true
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
                RoutineCardView(
                    title: "아침에 일어나 물 한 컵 마시기",
                    time: "08:00 알림 예정",
                    onConfirm: {
                        selectedRoutineIndex = 1
                        selectedRoutineTitle = "아침에 일어나 물 한 컵 마시기"
                        requestCameraPermission()
                    },
                    onDelay: {
                        selectedRoutineIndex = 1
                        selectedRoutineTitle = "아침에 일어나 물 한 컵 마시기"
                        isShowingDelayPopup = true
                    }
                )

                RoutineCardView(
                    title: "낮 시간에 몸 움직이기",
                    time: "13:00 알림 예정",
                    onConfirm: {
                        selectedRoutineIndex = 1
                        selectedRoutineTitle = "낮 시간에 몸 움직이기"
                        requestCameraPermission()
                    },
                    onDelay: {
                        selectedRoutineIndex = 2
                        selectedRoutineTitle = "낮 시간에 몸 움직이기"
                        isShowingDelayPopup = true
                    }
                )

                RoutineCardView(
                    title: "정해진 시간에 침대에 눕기",
                    time: "23:00 알림 예정",
                    onConfirm: {
                        selectedRoutineIndex = 1
                        selectedRoutineTitle = "정해진 시간에 침대에 눕기"
                        requestCameraPermission()
                    },
                    onDelay: {
                        selectedRoutineIndex = 3
                        selectedRoutineTitle = "정해진 시간에 침대에 눕기"
                        isShowingDelayPopup = true
                    }
                )
            }
        }
    }

    var recordButton: some View {
        Button(action: {}) {
            Text("여정 기록하기")
                .font(.system(size: 18, weight: .bold))
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
    RootTabView()
}
