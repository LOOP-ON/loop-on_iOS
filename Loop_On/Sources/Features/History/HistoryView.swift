//
//  HistoryView.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import SwiftUI

// 달력 섹션 높이를 전달하기 위한 PreferenceKey
struct CalendarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// 달력 하단 ~ 네비 상단 구간의 세로 중앙에 콘텐츠 배치
private struct MessageMidpointContainer<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        GeometryReader { geo in
            let areaHeight = geo.size.height - geo.safeAreaInsets.bottom
            let midY = areaHeight / 2
            let contentHalfHeight: CGFloat = 28
            let topPadding = max(0, midY - contentHalfHeight)
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                    .frame(height: topPadding)
                content
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HistoryView: View {
    @Environment(NavigationRouter.self) private var router
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var isWeekMode: Bool = false
    @State private var calendarHeight: CGFloat = 0
    @State private var calendarProgress: CGFloat = 0.0 // 0.0 = 접힘, 1.0 = 펼쳐짐
    
    private let calendar = Calendar.current
    
    // 선택한 날짜가 오늘 이후인지 (미래 날짜)
    private var isSelectedDateInFuture: Bool {
        calendar.startOfDay(for: selectedDate) > calendar.startOfDay(for: Date())
    }

    // 현재 달에 루틴 수행 기록이 있는지 확인
    private var hasRoutineRecordsInCurrentMonth: Bool {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return false
        }
        
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        // 현재 달의 모든 날짜를 확인
        for day in 0..<numberOfDaysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDayOfMonth) {
                let completionCount = viewModel.getCompletionCount(for: date)
                if completionCount > 0 {
                    return true
                }
            }
        }
        
        return false
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // 세이프에리어 배경 (홈뷰와 동일한 색상)
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 헤더 (홈뷰와 동일한 위치)
                    HistoryHeaderView(onSettingsTapped: {
                        router.push(.app(.settings))
                    })
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // 헤더와 달력 사이 간격 (배경 밖)
                    Spacer()
                        .frame(height: 16)
                    
                    // 달력 섹션 (흰색 배경) — 화면 양끝에서 살짝 띄우고 네 모서리 둥글게
                    VStack(spacing: 0) {
                        CustomCalendarView(
                            selectedDate: $selectedDate,
                            currentMonth: $currentMonth,
                            viewModel: viewModel,
                            isWeekMode: isWeekMode
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                        
                        // 주간/월간 전환 토글 (Figma의 아래 화살표 역할)
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                isWeekMode.toggle()
                                calendarProgress = isWeekMode ? 0.0 : 1.0
                            }
                        } label: {
                            Image(systemName: isWeekMode ? "chevron.up" : "chevron.down")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color("45-Text"))
                                .padding(.vertical, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8) // 12 -> 8로 줄임
                    }
                    .background(Color.white)
                    .background(
                        GeometryReader { calendarGeometry in
                            Color.clear
                                .preference(
                                    key: CalendarHeightPreferenceKey.self,
                                    value: calendarGeometry.size.height
                                )
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .background(
                        // 상단과 하단에 그림자가 있는 레이어 (clipShape 밖에 배치)
                        VStack(spacing: 0) {
                            // 상단 그림자
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.white)
                                .frame(height: 60)
                                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: -3) // 상단 그림자
                            
                            Spacer()
                            
                            // 하단 그림자
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.white)
                                .frame(height: 60)
                                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3) // 하단 그림자
                        }
                        .allowsHitTesting(false)
                    )
                    .padding(.horizontal, 20) // 화면 양끝에서 살짝 띄움
                    .zIndex(1) // 달력이 항상 리포트 위에 오도록

                    // 하단 영역 (연한 회색 배경, 전체 공간 차지)
                    Group {
                        if isSelectedDateInFuture {
                            // 오늘 이후 날짜 선택 시: 기록 없음과 동일한 안내
                            MessageMidpointContainer {
                                VStack(spacing: 8) {
                                    Text("아직 루틴을 수행한 기록이 없어요.")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color("25-Text"))

                                    Text("루틴을 수행하면 통계를 확인할 수 있어요 :)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color("25-Text"))
                                }
                            }
                        } else if let report = viewModel.getReport(for: selectedDate) {
                            // 선택된 날짜에 리포트가 있으면 리포트 표시
                            HistoryJourneyReportView(
                                report: report,
                                isWeekMode: $isWeekMode,
                                calendarHeight: calendarHeight
                            )
                            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                        } else if hasRoutineRecordsInCurrentMonth {
                            // 현재 달에 기록이 있지만 선택된 날짜에는 없으면 안내 메시지
                            MessageMidpointContainer {
                                Text("날짜를 선택하면 리포트 확인이 가능합니다 :)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color("25-Text"))
                            }
                        } else {
                            // 현재 달에 기록이 없으면 안내 메시지
                            MessageMidpointContainer {
                                VStack(spacing: 8) {
                                    Text("아직 루틴을 수행한 기록이 없어요.")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color("25-Text"))

                                    Text("루틴을 수행하면 통계를 확인할 수 있어요 :)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color("25-Text"))
                                }
                            }
                        }
                    }
                    .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                    .zIndex(0) // 리포트는 달력 아래 레이어
                }
            }
            .safeAreaPadding(.top, 1) // 홈뷰와 동일하게 전체 VStack에 적용
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                viewModel.loadMonth(currentMonth)
                viewModel.loadDailyReport(for: selectedDate)
                // #region agent log
                let payload: [String: Any] = [
                    "sessionId": "debug-session",
                    "runId": "pre-fix-2",
                    "hypothesisId": "H2",
                    "location": "HistoryView.swift:body:onAppear",
                    "message": "HistoryView appeared",
                    "data": [
                        "selectedDate": selectedDate.timeIntervalSince1970,
                        "currentMonth": currentMonth.timeIntervalSince1970
                    ],
                    "timestamp": Date().timeIntervalSince1970
                ]
                
                if let url = URL(string: "http://127.0.0.1:7242/ingest/f0d53358-e857-43b6-9baf-1b348ed6f40f"),
                   let body = try? JSONSerialization.data(withJSONObject: payload) {
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = body
                    
                    URLSession.shared.dataTask(with: request) { _, _, _ in
                        // fire-and-forget
                    }.resume()
                }
                // #endregion
            }
            .onChange(of: currentMonth) { _, newMonth in
                viewModel.loadMonth(newMonth)
            }
            .onChange(of: selectedDate) { _, newDate in
                viewModel.loadDailyReport(for: newDate)
            }
            .onPreferenceChange(CalendarHeightPreferenceKey.self) { height in
                // 달력 섹션 높이 업데이트 (애니메이션과 함께)
                withAnimation {
                    calendarHeight = height
                }
            }
        }
    }
}

// MARK: - History Header View
struct HistoryHeaderView: View {
    var onSettingsTapped: (() -> Void)?
    
    var body: some View {
        HStack {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 164, height: 40)
            
            Spacer()
            
            HStack(spacing: 8) {
                Image("passport")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34)
                Button(action: {
                    onSettingsTapped?()
                }) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 20))
            .foregroundStyle(.black)
        }
    }
}

// MARK: - Custom Calendar View
struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    @ObservedObject var viewModel: HistoryViewModel
    let isWeekMode: Bool
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            // 월 표시 및 네비게이션
            HStack {
                Spacer()
                
                // 이전 달 버튼
                Button(action: {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color("25-Text"))
                }
                
                // 월 표시
                Text(monthYearString)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color("25-Text"))
                    .frame(width: 100)
                
                // 다음 달 버튼
                Button(action: {
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color("25-Text"))
                }
                
                Spacer()
            }
            
            // 요일 헤더 (홈뷰의 "1번째 여정" 텍스트와 같은 왼쪽 정렬)
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color("45-Text"))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 날짜 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                ForEach(Array(daysToDisplay.enumerated()), id: \.offset) { index, day in
                    if let day = day {
                        CalendarDayView(
                            day: day,
                            isSelected: calendar.isDate(day, inSameDayAs: selectedDate),
                            isCurrentMonth: calendar.isDate(day, equalTo: currentMonth, toGranularity: .month),
                            completionCount: viewModel.getCompletionCount(for: day)
                        ) {
                            withAnimation {
                                selectedDate = day
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 48)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var monthYearString: String {
        dateFormatter.dateFormat = "M월"
        return dateFormatter.string(from: currentMonth)
    }
    
    private var weekdaySymbols: [String] {
        // 한국어 요일 (일요일부터)
        return ["일", "월", "화", "수", "목", "금", "토"]
    }
    
    // 전체 월 뷰 혹은 선택 주만 보여줄 날짜 배열
    private var daysToDisplay: [Date?] {
        if isWeekMode {
            return daysInSelectedWeek
        } else {
            return daysInMonth
        }
    }
    
    // 현재 월의 전체 날짜
    private var daysInMonth: [Date?] {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var days: [Date?] = []
        
        // 첫 주의 빈 칸들 (일요일 = 1, 월요일 = 2, ...)
        // 일요일이 첫 요일이므로 1을 빼서 0부터 시작
        let startOffset = firstDayWeekday - 1
        for _ in 0..<startOffset {
            days.append(nil)
        }
        
        // 실제 날짜들
        for day in 1...numberOfDaysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    // 선택된 날짜가 속한 주(일~토)만 계산
    private var daysInSelectedWeek: [Date?] {
        // 선택된 날짜가 현재 month와 다르면 month를 맞춰줌
        let targetDate = selectedDate
        
        // 해당 주의 시작(일요일) 계산
        let weekday = calendar.component(.weekday, from: targetDate) // 1 = 일요일
        guard let weekStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: targetDate) else {
            return []
        }
        
        // 7일치 생성
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekStart)
        }
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let day: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let completionCount: Int
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: action) {
                Text("\(calendar.component(.day, from: day))")
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color("100") : (isCurrentMonth ? Color("25-Text") : Color("45-Text")))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? Color("PrimaryColor55") : Color.clear)
                            .frame(width: 36, height: 36)
                    )
            }
            .buttonStyle(.plain)
            
            // 루틴 달성 개수에 따른 점 표시 (항상 공간 확보)
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
        }
        .frame(height: 48)
    }
    
    // 달성 개수에 따른 점 색상
    private var dotColor: Color {
        switch completionCount {
        case 3:
            // 제일 진한색
            return Color("PrimaryColor55")
        case 2:
            // 중간 색
            return Color("PrimaryColor-Varient75")
        case 1:
            // 연한 색
            return Color("PrimaryColor-Varient85")
        default:
            return Color.clear
        }
    }
}

#Preview {
    HistoryView()
        .environment(NavigationRouter())
        .environment(SessionStore())
}
