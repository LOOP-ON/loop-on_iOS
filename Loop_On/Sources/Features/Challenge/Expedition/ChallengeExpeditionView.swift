//
//  ChallengeExpeditionView.swift
//  Loop_On
//
//  Created by 김세은 on 1/22/26.
//

import SwiftUI

struct ChallengeExpeditionView: View {
    @Environment(NavigationRouter.self) private var router
    @ObservedObject var viewModel: ChallengeExpeditionViewModel

    init(viewModel: ChallengeExpeditionViewModel = ChallengeExpeditionViewModel()) {
        self.viewModel = viewModel
    }

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
                    if viewModel.isShowingSearchResults {
                        sectionHeader("탐험대 리스트")
                        searchResultSection
                    } else {
                        sectionHeader("내 탐험대")
                        myExpeditionSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                if viewModel.isShowingSearchResults {
                    viewModel.searchExpeditions()
                } else {
                    viewModel.refreshMyExpeditions()
                }
            }

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
            viewModel.joinResultTitle,
            isPresented: $viewModel.isShowingJoinResultAlert
        ) {
            Button("확인") {
                viewModel.closeJoinResultAlert()
            }
        } message: {
            Text(viewModel.joinResultMessage ?? "")
        }
        .alert(
            viewModel.createErrorTitle,
            isPresented: $viewModel.isShowingCreateErrorAlert
        ) {
            Button("확인") {
                viewModel.closeCreateErrorAlert()
            }
        } message: {
            Text(viewModel.createErrorMessage ?? "잠시 후 다시 시도해 주세요.")
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
        .onChange(of: viewModel.searchText) { _, newValue in
            if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                viewModel.clearSearchResults()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .expeditionListNeedsRefresh)) { _ in
            viewModel.refreshMyExpeditions()
            if viewModel.isShowingSearchResults {
                viewModel.searchExpeditions()
            }
        }
    }
}

#Preview {
    ChallengeExpeditionView()
}

private extension ChallengeExpeditionView {
    @ViewBuilder
    var searchResultSection: some View {
        if viewModel.isSearching {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(.vertical, 16)
        } else if !viewModel.searchResults.isEmpty {
            expeditionList(viewModel.searchResults, isSearchMode: true)
        } else {
            let message = viewModel.searchErrorMessage ?? "다른 키워드로 다시 검색해 보세요."
            Text(message)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                .foregroundStyle(Color("25-Text"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }

    @ViewBuilder
    var myExpeditionSection: some View {
        if viewModel.isLoadingMyExpeditions && viewModel.myExpeditions.isEmpty {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(.vertical, 16)
        } else if let message = viewModel.loadMyExpeditionsErrorMessage,
                  viewModel.myExpeditions.isEmpty {
            VStack(spacing: 8) {
                Text(message)
                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundStyle(Color("25-Text"))
                    .multilineTextAlignment(.center)
                Button("다시 시도") {
                    viewModel.refreshMyExpeditions()
                }
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(Color(.primaryColorVarient65))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        } else if viewModel.myExpeditions.isEmpty {
            Text("참여 중인 탐험대가 없습니다.")
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                .foregroundStyle(Color("25-Text"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
        } else {
            expeditionList(viewModel.myExpeditions)
        }
    }

    var searchBar: some View {
        HStack(spacing: 8) {
            TextField("검색", text: $viewModel.searchText)
                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundStyle(Color.black)
                .submitLabel(.search)
                .onSubmit {
                    viewModel.searchExpeditions()
                }

            if !viewModel.searchText.isEmpty {
                Button(action: viewModel.clearSearch) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.gray.opacity(0.6))
                }
                .buttonStyle(.plain)
            }

            Button {
                viewModel.searchExpeditions()
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.gray)
            }
            .buttonStyle(.plain)
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

    func expeditionList(_ expeditions: [ChallengeExpedition], isSearchMode: Bool = false) -> some View {
        VStack(spacing: 0) {
            ForEach(expeditions) { expedition in
                ChallengeExpeditionRow(
                    expedition: expedition,
                    isSearchMode: isSearchMode,
                    onRowTap: {
                        router.push(.app(.expeditionDetail(
                            expeditionId: expedition.id,
                            expeditionName: expedition.name,
                            isPrivate: expedition.isPrivate,
                            isAdmin: expedition.isOwner,
                            canJoin: expedition.canJoin
                        )))
                    },
                    onActionTap: { viewModel.handleAction(expedition) }
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
    let isSearchMode: Bool
    var onRowTap: () -> Void
    var onActionTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
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

            if shouldShowActionButton {
                Button(action: onActionTap) {
                    Text(actionTitle)
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
            } else if isSearchMode {
                Text(expedition.isMember ? "참여중" : "가입 불가")
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    .foregroundStyle(Color.gray)
            } else if !expedition.isMember {
                Text("가입 불가")
                    .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    .foregroundStyle(Color.gray)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onRowTap()
        }
        .padding(.vertical, 12)
    }

    private var shouldShowActionButton: Bool {
        if isSearchMode {
            return !expedition.isMember && expedition.canJoin
        }
        return expedition.shouldShowActionButton
    }

    private var actionTitle: String {
        if isSearchMode {
            return "가입"
        }
        return expedition.actionTitle
    }
}
