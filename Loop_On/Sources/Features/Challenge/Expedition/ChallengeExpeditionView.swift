//
//  ChallengeExpeditionView.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import SwiftUI

struct ChallengeExpeditionView: View {
    @StateObject private var viewModel = ChallengeExpeditionViewModel()
  
    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.horizontal, 20)
                .padding(.top, 8)

            filterSection
                .padding(.horizontal, 20)
                .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    sectionHeader("내 탐험대")

                    expeditionList(viewModel.myExpeditions)

                    Divider()
                        .background(Color.gray.opacity(0.2))

                    sectionHeader("추천 탐험대")

                    expeditionList(viewModel.recommendedExpeditions)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            createButton
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.systemGroupedBackground))
        }
        .fullScreenCover(isPresented: $viewModel.isShowingCreateModal) {
            ChallengeExpeditionCreateView(
                viewModel: viewModel
            )
            .presentationBackground(.clear)
        }
        .alert(
            viewModel.createSuccessMessage,
            isPresented: $viewModel.isShowingCreateSuccessAlert
        ) {
            Button("확인") {
                viewModel.closeCreateSuccessAlert()
            }
        }
        .alert(
            viewModel.deleteAlertTitle,
            isPresented: $viewModel.isShowingDeleteAlert
        ) {
            Button("취소", role: .cancel) {
                viewModel.cancelDelete()
            }
            Button("탐험대 삭제", role: .destructive) {
                viewModel.confirmDelete()
            }
        } message: {
            Text(viewModel.deleteAlertMessage)
        }
        .alert(
            viewModel.leaveAlertTitle,
            isPresented: $viewModel.isShowingLeaveAlert
        ) {
            Button("취소", role: .cancel) {
                viewModel.cancelLeave()
            }
            Button("탐험대 탈퇴", role: .destructive) {
                viewModel.confirmLeave()
            }
        } message: {
            Text(viewModel.leaveAlertMessage)
        }
        .alert(
            viewModel.joinPrivateAlertTitle,
            isPresented: $viewModel.isShowingJoinPrivateAlert
        ) {
            TextField("암호를 입력해주세요", text: $viewModel.joinPassword)
                .keyboardType(.numberPad)
                .onChange(of: viewModel.joinPassword) { _, newValue in
                    let digitsOnly = newValue.filter { $0.isNumber }
                    if digitsOnly.count > 8 {
                        viewModel.joinPassword = String(digitsOnly.prefix(8))
                    } else if digitsOnly != newValue {
                        viewModel.joinPassword = digitsOnly
                    }
                }
            Button("취소", role: .cancel) {
                viewModel.cancelJoinPrivate()
            }
            Button("탐험대 가입") {
                viewModel.confirmJoinPrivate()
            }
        }
        .tint(Color(.primaryColor55))
    }
}

#Preview {
    ChallengeExpeditionView()
}

private extension ChallengeExpeditionView {
    var searchBar: some View {
        HStack(spacing: 8) {
            TextField("검색", text: $viewModel.searchText)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color.black)

            if !viewModel.searchText.isEmpty {
                Button(action: viewModel.clearSearch) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.gray.opacity(0.6))
                }
                .buttonStyle(.plain)
            }

            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }

    var filterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("카테고리 필터")
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .foregroundStyle(Color("5-Text"))

            FlowLayout(items: viewModel.categories) { category in
                let isSelected = viewModel.selectedCategories.contains(category)
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
                        viewModel.toggleCategory(category)
                    }
            }
        }
    }

    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
            .foregroundStyle(Color("5-Text"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    func expeditionList(_ expeditions: [ChallengeExpedition]) -> some View {
        VStack(spacing: 0) {
            ForEach(expeditions.indices, id: \.self) { index in
                ChallengeExpeditionRow(
                    expedition: expeditions[index],
                    onRowTap: {
                        // TODO: 라우팅 연결 (탐험대 상세 화면 이동)
                    },
                    onActionTap: { viewModel.handleAction(expeditions[index]) }
                )
            }
        }
    }

    var createButton: some View {
        Button(action: viewModel.openCreateModal) {
            Text("새로운 탐험대 만들기")
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.primaryColorVarient65))
                )
        }
    }
}

private struct ChallengeExpeditionRow: View {
    let expedition: ChallengeExpedition
    var onRowTap: () -> Void
    var onActionTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.white)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(expedition.name)
                        .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .foregroundStyle(Color("5-Text"))

                    if expedition.isPrivate {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.gray)
                    }
                }

                HStack(spacing: 8) {
                    Text(expedition.category)
                    Text(expedition.progressText)
                    Text(expedition.leaderName)
                }
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color("25-Text"))
            }

            Spacer()

            Button(action: onActionTap) {
                Text(expedition.actionTitle)
                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(expedition.actionColor)
                    )
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onRowTap()
        }
        .padding(.vertical, 12)
    }
}
