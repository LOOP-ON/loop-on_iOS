//
//  JourneyReportView.swift
//  Loop_On
//
//  Created by 이경민 on 1/26/26.
//

import Foundation
import SwiftUI

struct JourneyReportView: View {
    @StateObject private var viewModel = JourneyReportViewModel()
    @Binding var isPresented: Bool
    let loopId: Int
    var onShare: () -> Void

    var body: some View {
        ZStack {
            // 배경 터치 시 닫기 기능
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { isPresented = false }

            if viewModel.isLoading {
                ProgressView().tint(.white)
            } else if let report = viewModel.reportData {
                reportMainContainer(report)
            }
        }
        .onAppear { viewModel.fetchReport(loopId: loopId) }
    }

    private func reportMainContainer(_ report: JourneyReport) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 타이틀 영역
                    VStack(alignment: .leading, spacing: 8) {
                        Text(report.title)
                            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                        
                        HStack(spacing: 6) {
                            Text("여정의 목표")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .foregroundStyle(Color(.primaryColorVarient65))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.1))
                            
                            Text(report.goal)
                                .font(.system(size: 15))
                        }
                    }

                    // 루틴 요약 영역
                    reportSection(title: "루틴 요약") {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(report.routines.enumerated()), id: \.offset) { index, routine in
                                HStack {
                                    Text("루틴 \(index + 1)")
                                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                        .foregroundStyle(Color(.primaryColorVarient65))
                                    Text(routine)
                                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius:12)
                                .fill(Color(.systemGray6).opacity(0.5))
                        )
                    }

                    // 성장 추이 그래프 영역
                    reportSection(title: "성장 추이 그래프") {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6).opacity(0.5))
                            .frame(height: 120)
                            .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                    }

                    // 피드백 영역
                    reportSection(title: "LOOP:ON의 피드백") {
                        VStack(spacing: 12) {
                            Text(report.feedback)
                                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius:12)
                                .fill(Color(.systemGray6).opacity(0.5))
                        )
                    }
                }
                .padding(24)
            }

            Divider()

            // 하단 액션 버튼
            HStack(spacing: 0) {
                Button("닫기") { isPresented = false }
                    .foregroundStyle(Color(.primaryColorVarient65))
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .frame(maxWidth: .infinity, minHeight: 56)

                Divider().frame(height: 56)

                Button("챌린지에 공유하기") {
//                    viewModel.shareToChallenge()
                    isPresented = false // 현재 리포트 팝업 닫기
                    onShare()
                }
                    .foregroundStyle(Color(.primaryColorVarient65))
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
        }
        .background(
            RoundedRectangle(cornerRadius:20)
                .fill(Color.white)
        )
        .padding(.horizontal, 30)
        .padding(.vertical, 80)
    }

    private func reportSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
            content()
        }
    }
}

// MARK: - Preview
#Preview {
    struct JourneyReportPreviewContainer: View {
        @State private var activeSheet: ActiveFullSheet? = .journeyReport
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                Text("배경 화면")
            }
            .fullScreenCover(item: $activeSheet) { sheet in
                if sheet == .journeyReport {
                    JourneyReportView(
                        isPresented: Binding(
                            get: { activeSheet == .journeyReport },
                            set: { if !$0 { activeSheet = nil } }
                        ),
                        loopId: 1,
                        onShare: {
                            print("공유하기 화면으로 전환")
                        }
                    )
                    .presentationBackground(.clear)
                }
            }
        }
    }
    return JourneyReportPreviewContainer()
}
