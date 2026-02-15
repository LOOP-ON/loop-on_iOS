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
    let journeyId: Int
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
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text("리포트를 불러오지 못했어요")
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                    Text(errorMessage)
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                        .foregroundStyle(.gray)
                    Button("닫기") { isPresented = false }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
                .padding(.horizontal, 40)
            }
        }
        .onAppear { viewModel.fetchReport(journeyId: journeyId) }
    }

    private func reportMainContainer(_ report: PopupJourneyReport) -> some View {
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
                                    Text(routine.routineName)
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
                        GrowthTrendGraph(data: [
                            GrowthDataPoint(index: 0, label: "Day1", rate: normalizeRate(report.day1Rate)),
                            GrowthDataPoint(index: 1, label: "Day2", rate: normalizeRate(report.day2Rate)),
                            GrowthDataPoint(index: 2, label: "Day3", rate: normalizeRate(report.day3Rate))
                        ])
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

    private func normalizeRate(_ value: Double) -> Double {
        if value <= 1.0 {
            return max(0, min(1.0, value))
        }
        return max(0, min(1.0, value / 100.0))
    }
}

// MARK: - Growth Graph
private struct GrowthDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let label: String
    let rate: Double
}

private struct GrowthTrendGraph: View {
    let data: [GrowthDataPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)

                GeometryReader { geometry in
                    let tickValues: [Double] = [1.0, 2.0 / 3.0, 1.0 / 3.0, 0.0]
                    let leftPadding: CGFloat = 36
                    let bottomPadding: CGFloat = 24
                    let topPadding: CGFloat = 12

                    let plotWidth = geometry.size.width - leftPadding - 12
                    let plotHeight = geometry.size.height - topPadding - bottomPadding
                    let clampedPlotHeight = max(plotHeight, 1)
                    let count = max(data.count, 1)
                    let stepX = count > 0 ? plotWidth / CGFloat(count) : 0

                    ZStack {
                        ForEach(0..<tickValues.count, id: \.self) { index in
                            let level = tickValues[index]
                            let ratio = CGFloat(1.0 - level)
                            let y = topPadding + ratio * clampedPlotHeight

                            HStack(spacing: 4) {
                                Text("\(Int(level * 100))%")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color("45-Text"))
                                    .frame(width: leftPadding - 8, alignment: .trailing)

                                Rectangle()
                                    .fill(Color("45-Text").opacity(level == 0.0 ? 0.3 : 0.15))
                                    .frame(height: 1)
                            }
                            .position(x: geometry.size.width / 2, y: y)
                        }

                        Path { path in
                            guard let first = data.first else { return }
                            let firstRatio = CGFloat(1.0 - min(max(first.rate, 0), 1))
                            let startX = leftPadding + 0.5 * stepX
                            let startY = topPadding + firstRatio * clampedPlotHeight
                            path.move(to: CGPoint(x: startX, y: startY))

                            for index in 0..<data.count {
                                let point = data[index]
                                let ratio = CGFloat(1.0 - min(max(point.rate, 0), 1))
                                let x = leftPadding + (CGFloat(index) + 0.5) * stepX
                                let y = topPadding + ratio * clampedPlotHeight
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        .stroke(Color("PrimaryColor55"), lineWidth: 1.5)

                        ForEach(Array(data.enumerated()), id: \.1.id) { index, point in
                            let ratio = CGFloat(1.0 - min(max(point.rate, 0), 1))
                            let x = leftPadding + (CGFloat(index) + 0.5) * stepX
                            let y = topPadding + ratio * clampedPlotHeight

                            Circle()
                                .fill(Color.white)
                                .overlay(
                                    Circle().stroke(Color("PrimaryColor55"), lineWidth: 2)
                                )
                                .frame(width: 6, height: 6)
                                .position(x: x, y: y)
                        }

                        ForEach(Array(data.enumerated()), id: \.1.id) { index, point in
                            let x = leftPadding + (CGFloat(index) + 0.5) * stepX
                            Text(point.label)
                                .font(.system(size: 10))
                                .foregroundStyle(Color("45-Text"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(width: stepX, alignment: .center)
                                .position(x: x, y: geometry.size.height - bottomPadding / 2)
                        }
                    }
                    .clipped()
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
            .frame(height: 150)
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
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
                        journeyId: 1,
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
