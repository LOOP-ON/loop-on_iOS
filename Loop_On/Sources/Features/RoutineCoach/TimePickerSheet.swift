//
//  TimePickerSheet.swift
//  Loop_On
//
//  Created by 이경민 on 1/21/26.
//

import Foundation
import SwiftUI

struct TimePickerSheet: View {
    @Binding var selectedDate: Date
    var onSave: () -> Void
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "bell")
                        .foregroundStyle(Color.black)
                    Text("알림 시간")
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(Color.black)
                }
                .font(.headline)
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                        .foregroundStyle(Color.black)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)
            .padding(.bottom, 0)
            
            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                .padding(.bottom, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
        .onDisappear {
                    onSave()
        }
    }
}

struct TimePickerSheet_Previews: PreviewProvider {
    static var previews: some View {
        // 프리뷰를 위해 임시 상태값(@State)을 사용하는 래퍼 뷰
        TimePickerContainer()
    }
    
    struct TimePickerContainer: View {
        @State private var previewDate = Date()
        
        var body: some View {
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.3).ignoresSafeArea()
                
                TimePickerSheet(
                    selectedDate: $previewDate,
                    onSave: { print("시간 저장됨: \(previewDate)") },
                    onClose: { print("닫기 버튼 클릭됨") }
                )
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
