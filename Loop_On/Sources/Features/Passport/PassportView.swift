import SwiftUI

struct PassportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex = 0

    private let pages: [PassportPage] = [
        PassportPage(
            journeyNo: "001",
            startDate: "2025.12.23",
            journeyTitle: "건강한 생활 만들기",
            stampImageName: "stamp_ROUTINE"
        ),
        PassportPage(
            journeyNo: "002",
            startDate: "2025.12.23",
            journeyTitle: "역량 강화 관련 여정",
            stampImageName: "stamp_GROWTH"
        ),
        PassportPage(
            journeyNo: "003",
            startDate: "2025.12.23",
            journeyTitle: "내면 관리 관련 여정",
            stampImageName: "stamp_MENTAL"
        )
    ]

    var body: some View {
        GeometryReader { proxy in
            let coverHeight = min(max(proxy.size.height * 0.62, 540), 660)
            let cardHeight = coverHeight

            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    TabView(selection: $selectedIndex) {
                        coverPage(height: coverHeight)
                            .tag(0)

                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            detailPage(page: page, height: cardHeight)
                                .tag(index + 1)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .padding(.top, 20)
                    .frame(maxHeight: .infinity)
                }

                if selectedIndex > 0 {
                    VStack {
                        Spacer()
                        Button {
                            // TODO: 해당 여정 상세 화면 라우팅 연결
                        } label: {
                            Text("해당 여정 이어가기")
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color("PrimaryColor-Varient65"))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                    }
                    .transition(.opacity)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

private extension PassportView {
    var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("5-Text"))
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("LOOP:ON 여정 여권")
                .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                .foregroundStyle(Color("5-Text"))

            Spacer()

            Color.clear
                .frame(width: 40, height: 40)
        }
    }

    func coverPage(height: CGFloat) -> some View {
        VStack {
            Spacer(minLength: 0)
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(red: 0.81, green: 0.35, blue: 0.29))
                    .frame(width: 12)

                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color("PrimaryColor-Varient65"))

                    VStack(spacing: 0) {
                        Spacer(minLength: 0)

                        VStack(spacing: 10) {
                            Image(systemName: "infinity")
                                .font(.system(size: 52, weight: .medium))
                                .foregroundStyle(Color.white)

                            Text("루프온 여권")
                                .font(LoopOnFontFamily.Pretendard.bold.swiftUIFont(size: 19))
                                .foregroundStyle(Color.white)

                            Text("LOOP:ON PASSPORT")
                                .font(LoopOnFontFamily.Pretendard.bold.swiftUIFont(size: 19))
                                .foregroundStyle(Color.white)
                        }
                        .padding(.bottom, height * 0.18)

                        Spacer(minLength: 0)
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image("passport")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(Color.white.opacity(0.95))
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .padding(.trailing, 18)
                                .padding(.bottom, 18)
                        }
                    }
                }
            }
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 22)
            Spacer(minLength: 0)
        }
    }

    func detailPage(page: PassportPage, height: CGFloat) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.97, green: 0.96, blue: 0.93))
                .overlay {
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("여정 no.")
                                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 11))
                                    .foregroundStyle(Color("45-Text"))
                                Text(page.journeyNo)
                                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                    .foregroundStyle(Color("5-Text"))
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 6) {
                                Text("시작 날짜")
                                    .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 11))
                                    .foregroundStyle(Color("45-Text"))
                                Text(page.startDate)
                                    .font(LoopOnFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                    .foregroundStyle(Color("5-Text"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 18)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("여정 이름")
                                .font(LoopOnFontFamily.Pretendard.regular.swiftUIFont(size: 11))
                                .foregroundStyle(Color("45-Text"))

                            Text(page.journeyTitle)
                                .font(LoopOnFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                .foregroundStyle(Color("5-Text"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 18)

                        Divider()
                            .padding(.horizontal, 20)
                            .padding(.top, 12)

                        VStack {
                            Image(page.stampImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
                .frame(height: height)
                .padding(.top, 42)
                .padding(.horizontal, 22)

            Spacer()
        }
    }
}

private struct PassportPage {
    let journeyNo: String
    let startDate: String
    let journeyTitle: String
    let stampImageName: String
}

#Preview {
    NavigationStack {
        PassportView()
    }
}
