//
//  ChallengeExpeditionCreateView.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import SwiftUI

struct ChallengeExpeditionCreateView: View {
    @ObservedObject var viewModel: ChallengeExpeditionViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.closeCreateModal()
                }

            VStack(spacing: 0) {
                header
                    .padding(.top, 36)
                    .padding(.bottom, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        nameSection
                        memberSection
                        visibilitySection

                        if !viewModel.isPublicExpedition {
                            passwordSection
                        }

                        categorySection
                        photoSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
                .scrollIndicators(.hidden)

                Divider()

                footerButtons
                    .frame(height: 56)
            }
            .frame(width: 340, height: 560)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
        .sheet(isPresented: $viewModel.isShowingMemberPicker) {
            ChallengeExpeditionMemberPickerSheet(
                memberCount: $viewModel.createMemberCount,
                onClose: viewModel.closeMemberPicker
            )
            .presentationDetents([.fraction(0.35)])
        }
    }
}

private extension ChallengeExpeditionCreateView {
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("새로운 탐험대 만들기")
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                .foregroundStyle(Color("5-Text"))

            Text("나만의 탐험대를 만들어보세요 :)")
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                .foregroundStyle(Color(.primaryColorVarient65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("탐험대 이름")
            TextField("탐험대 이름 (띄어쓰기 포함 최대 15글자)", text: $viewModel.createName)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                .onChange(of: viewModel.createName) { _, newValue in
                    if newValue.count > 15 {
                        viewModel.createName = String(newValue.prefix(15))
                    }
                }
        }
    }

    var memberSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("탐험대 인원")
            Button(action: viewModel.openMemberPicker) {
                HStack {
                    Text("\(viewModel.createMemberCount)명")
                        .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(Color("5-Text"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(.plain)
        }
    }

    var visibilitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("공개 설정")

            HStack(spacing: 8) {
                toggleButton(title: "공개", isSelected: viewModel.isPublicExpedition) {
                    viewModel.isPublicExpedition = true
                }
                toggleButton(title: "비공개", isSelected: !viewModel.isPublicExpedition) {
                    viewModel.isPublicExpedition = false
                }
            }
        }
    }

    var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("암호 설정")
            TextField("암호 입력 (숫자 4~8자리)", text: $viewModel.password)
                .keyboardType(.numberPad)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                .onChange(of: viewModel.password) { _, newValue in
                    let digitsOnly = newValue.filter { $0.isNumber }
                    if digitsOnly.count > 8 {
                        viewModel.password = String(digitsOnly.prefix(8))
                    } else if digitsOnly != newValue {
                        viewModel.password = digitsOnly
                    }
                }
        }
    }

    var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("카테고리")
            FlowLayout(items: viewModel.categories) { category in
                let isSelected = viewModel.selectedCreateCategories.contains(category)
                Text(category)
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color(.primaryColor55) : Color(.primaryColorVarient95))
                    )
                    .foregroundStyle(isSelected ? Color.white : Color(.primaryColor55))
                    .onTapGesture {
                        viewModel.toggleCreateCategory(category)
                    }
            }
        }
    }

    var photoSection: some View {
        HStack {
            Spacer()
            Button("사진 추가") {
                // TODO: API 연결 시 탐험대 사진 추가 처리
            }
            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.primaryColorVarient65))
            )
        }
    }

    var footerButtons: some View {
        HStack(spacing: 0) {
            Button("취소") {
                viewModel.closeCreateModal()
            }
            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
            .foregroundStyle(Color(.systemRed))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            Button("탐험대 생성") {
                viewModel.createExpedition()
            }
            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
            .foregroundStyle(viewModel.isCreateValid ? Color(.primaryColorVarient65) : Color.gray.opacity(0.5))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .disabled(!viewModel.isCreateValid || viewModel.isCreatingExpedition)
        }
    }

    //섹션별 제목 스타일
    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
            .foregroundStyle(Color("5-Text"))
    }

    func toggleButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .foregroundStyle(isSelected ? Color.white : Color("5-Text"))
                .frame(maxWidth: .infinity, minHeight: 32)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color(.primaryColorVarient65) : Color.gray.opacity(0.2))
                )
        }
        .buttonStyle(.plain)
    }
}

struct ChallengeExpeditionMemberPickerSheet: View {
    @Binding var memberCount: Int
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("탐험대 인원")
                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)

            Picker("", selection: $memberCount) {
                ForEach(1...50, id: \.self) { count in
                    Text("\(count)")
                        .tag(count)
                }
            }
            .pickerStyle(.wheel)
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    ChallengeExpeditionCreateView(viewModel: ChallengeExpeditionViewModel())
}
