//
//  HistoryJourneyReportView.swift
//  Loop_On
//
//  Created by Auto on 1/27/26.
//

import SwiftUI

// 스크롤 오프셋을 추적하기 위한 PreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct HistoryJourneyReportView: View {
    let report: HistoryJourneyReport
    @Binding var isWeekMode: Bool
    let calendarHeight: CGFloat
    
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var dragStartLocation: CGPoint = .zero
    @State private var isDragging: Bool = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter
    }()
    
    // 온보딩에서 설정한 목표가 비어 있으면 placeholder 사용
    private var goalText: String {
        report.goal.isEmpty ? "건강한 생활 만들기" : report.goal
    }
    
    /// API에서 journeyDay가 있으면 "2월 12일 · 3일차 여정 리포트", 없으면 "2월 12일 여정 리포트"
    private var reportTitleText: String {
        let dateStr = dateFormatter.string(from: report.date)
        if let day = report.journeyDay {
            return "\(dateStr) · \(day)일차 여정 리포트"
        }
        return "\(dateStr) 여정 리포트"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 상단 타이틀 + 여정의 목표 블록 (간격 8)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(reportTitleText)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color("25-Text"))
                            .padding(.top, 16) // 달력과의 간격을 16pt로 설정 (기존보다 총 8pt 감소)
                        
                        // 여정의 목표: 텍스트 아래에만 2pt 여유를 둔 하이라이트
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text("여정의 목표")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color("PrimaryColor55"))
                                
                                Text(goalText)
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color("5-Text"))
                            }
                            .padding(.horizontal, 2) // 텍스트 폭 + 4pt
                            .background(
                                // 텍스트 뒤, 아래쪽에만 보이는 분홍 띠 (#EE4B2B33)
                                Rectangle()
                                    .fill(Color(red: 0xEE/255, green: 0x4B/255, blue: 0x2B/255, opacity: 0x33/255))
                                    .frame(height: 8),
                                alignment: .bottomLeading
                            )
                        }
                    }
                    .padding(.bottom, -8) // 전체 VStack spacing(24)에서 16으로 조정하기 위해 -8 추가
                    
                    // 루틴 요약 (Figma 스타일 카드)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("루틴 요약")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("25-Text"))
                            .padding(.leading, 4)
                        
                        VStack(spacing: 12) {
                            ForEach(report.routines) { routine in
                                HistoryRoutineReportRow(routine: routine)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    }
                    
                    // 성장 추이 그래프
                    VStack(alignment: .leading, spacing: 12) {
                        Text("성장 추이 그래프")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("25-Text"))
                            .padding(.leading, 4) // 루틴 요약 텍스트와 동일한 x 위치
                        
                        GrowthTrendGraph(data: growthData)
                    }
                }
                .padding(.horizontal, 24) // 여정 리포트 영역 전체 양옆 패딩 4씩 증가
                .padding(.bottom, isWeekMode ? 0 : 32) // 달력이 접혔을 때는 하단 패딩 제거
                .safeAreaPadding(.bottom) // 네비게이션 바 공간 확보
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: scrollGeometry.frame(in: .named("scroll")).minY
                            )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .scrollIndicators(.hidden) // 스크롤 인디케이터 숨기기
            .scrollContentBackground(.hidden) // 배경 숨기기
            .scrollDisabled(isWeekMode) // 달력이 접혔을 때는 스크롤 비활성화
            .simultaneousGesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        let dy = value.translation.height
                        
                        // 위로 스와이프 (dy < 0) → 달력 접기
                        // 아래로 스와이프 (dy > 0) → 달력 펴기
                        if abs(dy) > 50 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                if dy < -50 {
                                    // 위로 충분히 스와이프 → 달력 접기 (첫 번째 사진처럼)
                                    isWeekMode = true
                                } else if dy > 50 {
                                    // 아래로 충분히 스와이프 → 달력 펴기 (두 번째 사진처럼)
                                    isWeekMode = false
                                }
                            }
                        }
                    }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                // 초기 상태에서는 lastScrollOffset이 설정되지 않았을 수 있으므로 처리
                if abs(lastScrollOffset) < 0.1 && abs(offset) > 0.1 {
                    lastScrollOffset = offset
                    scrollOffset = offset
                    return
                }
                
                let delta = offset - lastScrollOffset
                
                // 스크롤 변화가 충분히 클 때만 반응 (DragGesture가 작동하지 않을 때를 대비)
                if abs(delta) > 40 {
                    lastScrollOffset = offset
                    scrollOffset = offset
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        if delta < -40 {
                            // 위로 충분히 스크롤 (내용이 아래로 내려감) → 달력 접기
                            isWeekMode = true
                        } else if delta > 40 {
                            // 아래로 충분히 스크롤 (내용이 위로 올라감) → 달력 펴기
                            isWeekMode = false
                        }
                    }
                } else {
                    lastScrollOffset = offset
                    scrollOffset = offset
                }
            }
        }
    }
    
    // MARK: - 성장 추이 그래프
    /// API에서 day1Rate, day2Rate, day3Rate가 있으면 사용하고, 없으면 임시 로직(연중 일자 기반)으로 6포인트 생성
    private var growthData: [GrowthDataPoint] {
        let rates = [report.day1Rate, report.day2Rate, report.day3Rate].compactMap { $0 }
        if rates.count >= 2 {
            // API 데이터: Day1~DayN 실행률을 그대로 사용 (마지막이 현재 보고 있는 날짜)
            return rates.enumerated().map { offset, rate in
                GrowthDataPoint(
                    index: offset,
                    label: "Day\(offset + 1)",
                    rate: min(1.0, max(0, rate))
                )
            }
        }
        // API 미제공 시: 연중 일자 기반 임시 로직
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: report.date) ?? 1
        let selectedDayIndex = (dayOfYear - 1) % 3
        let completedPattern = [0, 1, 2, 3]
        let totalRoutinesPerDay = 3.0
        return (0..<6).map { offset in
            let stepsFromSelected = 5 - offset
            let dayLabelIndex = (selectedDayIndex - stepsFromSelected % 3 + 300) % 3
            let patternIndex = (dayOfYear + offset) % completedPattern.count
            let completed = completedPattern[patternIndex]
            let rate = Double(completed) / totalRoutinesPerDay
            return GrowthDataPoint(
                index: offset,
                label: "Day\(dayLabelIndex + 1)",
                rate: rate
            )
        }
    }
    
    struct GrowthDataPoint: Identifiable {
        let id = UUID()
        let index: Int
        let label: String
        let rate: Double // 0.0 ~ 1.0
    }
    
    // MARK: - 성장 추이 그래프 View
    struct GrowthTrendGraph: View {
        let data: [GrowthDataPoint]
        
        var body: some View {
            // 섹션 타이틀(상위 뷰의 "성장 추이 그래프")와 카드 사이 간격은
            // 루틴 요약 섹션과 동일하게 상위 VStack(spacing: 12)에서 관리.
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                    
                    GeometryReader { geometry in
                        let maxRate: Double = 1.0
                        let tickValues: [Double] = [1.0, 2.0/3.0, 1.0/3.0, 0.0] // 100, 66, 33, 0
                        let leftPadding: CGFloat = 36   // Y축 라벨 영역
                        let bottomPadding: CGFloat = 24 // X축 라벨 영역
                        let topPadding: CGFloat = 12
                        
                        let plotWidth = geometry.size.width - leftPadding - 12
                        let plotHeight = geometry.size.height - topPadding - bottomPadding
                        let clampedPlotHeight = max(plotHeight, 1)
                        
                        let count = max(data.count, 1)
                        // X축 각 포인트 간 간격을 약간 좁히기 위해 양 끝에 여유를 두고,
                        // 첫 포인트가 Y축에서 조금 더 떨어져 시작되도록 0.5 간격 오프셋을 사용
                        let stepX = count > 0 ? plotWidth / CGFloat(count) : 0
                        
                        ZStack {
                            // Y축 눈금 + 라인
                            ForEach(0..<tickValues.count, id: \.self) { index in
                                let level = tickValues[index]
                                let ratio = CGFloat(1.0 - level) // 1.0(0%) ~ 0.0(100%)
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
                            
                            // 선 + 포인트
                            Path { path in
                                guard let first = data.first else { return }
                                let firstRatio = CGFloat(1.0 - min(max(first.rate / maxRate, 0), 1))
                                let startX = leftPadding + 0.5 * stepX
                                let startY = topPadding + firstRatio * clampedPlotHeight
                                path.move(to: CGPoint(x: startX, y: startY))
                                
                                for index in 0..<data.count {
                                    let point = data[index]
                                    let ratio = CGFloat(1.0 - min(max(point.rate / maxRate, 0), 1))
                                    let x = leftPadding + (CGFloat(index) + 0.5) * stepX
                                    let y = topPadding + ratio * clampedPlotHeight
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                            .stroke(Color("PrimaryColor55"), lineWidth: 1.5)
                            
                            // 포인트 원
                            ForEach(Array(data.enumerated()), id: \.1.id) { index, point in
                                let ratio = CGFloat(1.0 - min(max(point.rate / maxRate, 0), 1))
                                let x = leftPadding + (CGFloat(index) + 0.5) * stepX
                                let y = topPadding + ratio * clampedPlotHeight
                                
                                Circle()
                                    .fill(Color.white)
                                    .overlay(
                                        Circle()
                                            .stroke(Color("PrimaryColor55"), lineWidth: 2)
                                    )
                                    .frame(width: 6, height: 6)
                                    .position(x: x, y: y)
                            }
                            
                            // X축 라벨 (각 포인트 아래에 개별 배치)
                            ForEach(Array(data.enumerated()), id: \.1.id) { index, point in
                                let x = leftPadding + (CGFloat(index) + 0.5) * stepX
                                
                                Text(point.label)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color("45-Text"))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .frame(width: stepX, alignment: .center)
                                    .position(
                                        x: x,
                                        y: geometry.size.height - bottomPadding / 2
                                    )
                            }
                        }
                        .clipped() // GeometryReader 영역 안에서만 그리도록 제한
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                }
                .frame(height: 150)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            }
        }
    }
    
    
    // MARK: - History Routine Report Row (Figma 매칭)
    struct HistoryRoutineReportRow: View {
        let routine: HistoryRoutineReport
        
        var body: some View {
            HStack(spacing: 8) {
                // 루틴 번호 태그 (루틴 1, 루틴 2, ...)
                Text("루틴 \(routine.id)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("PrimaryColor55"))
                    .padding(.horizontal, 10) // 좌우 10
                    .padding(.vertical, 6)    // 상하 6
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("PrimaryColor-Varient95"))
                    )
                
                // 루틴 이름
                Text(routine.name)
                    .font(.system(size: 14))
                    .foregroundStyle(Color("25-Text"))
                
                Spacer()
                
                // 상태 (완료/미룸)
                Text(routine.status.displayText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("PrimaryColor55"))
            }
        }
    }
    
    #Preview {
        PreviewContainer()
    }
    
    private struct PreviewContainer: View {
        @State private var isWeekMode = false
        
        var body: some View {
            HistoryJourneyReportView(
                report: HistoryJourneyReport(
                    date: Date(),
                    goal: "건강한 생활 만들기",
                    journeyDay: nil,
                    day1Rate: nil,
                    day2Rate: nil,
                    day3Rate: nil,
                    totalRate: nil,
                    routines: [
                        HistoryRoutineReport(id: 1, name: "루틴 이름", status: .completed),
                        HistoryRoutineReport(id: 2, name: "루틴 이름", status: .postponed),
                        HistoryRoutineReport(id: 3, name: "루틴 이름", status: .completed)
                    ]
                ),
                isWeekMode: $isWeekMode,
                calendarHeight: 200
            )
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        }
    }
}
