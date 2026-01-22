//
//  HistoryView.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HistoryHeaderView()
                .padding(.horizontal, 20)
                .padding(.top, 12)
            
            // 달력 섹션
            CustomCalendarView(
                selectedDate: $selectedDate,
                currentMonth: $currentMonth,
                viewModel: viewModel
            )
            .padding(.horizontal, 20)
            .padding(.top, 24)
            
            // 빈 상태 메시지
            Spacer()
            
            VStack(spacing: 8) {
                Text("아직 루틴을 수행한 기록이 없어요.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("25-Text"))
                
                Text("루틴을 수행하면 통계를 확인할 수 있어요 :)")
                    .font(.system(size: 14))
                    .foregroundStyle(Color("45-Text"))
            }
            .padding(.bottom, 100) // 하단 네비게이션 공간 확보
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
        .safeAreaPadding(.top, 1)
    }
}

// MARK: - History Header View
struct HistoryHeaderView: View {
    var body: some View {
        HStack {
            // 로고
            HStack(spacing: 4) {
                Image(systemName: "infinity")
                    .foregroundStyle(Color("PrimaryColor55"))
                    .font(.system(size: 20, weight: .bold))
                
                Text("LOOP: ON")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color("PrimaryColor55"))
            }
            
            Spacer()
            
            // 아이콘들
            HStack(spacing: 16) {
                Button(action: {
                    // 문서 아이콘 액션
                }) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 20))
                        .foregroundStyle(Color("25-Text"))
                }
                
                Button(action: {
                    // 설정 아이콘 액션
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundStyle(Color("25-Text"))
                }
            }
        }
    }
}

// MARK: - Custom Calendar View
struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    @ObservedObject var viewModel: HistoryViewModel
    
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
            
            // 요일 헤더
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color("45-Text"))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)
            
            // 날짜 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, day in
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
