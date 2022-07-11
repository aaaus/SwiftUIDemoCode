//
//  KnowledgeView.swift
//  SmartBrick
//
//  Created by Alexander Andrusenko on 11.05.2022.
//

import SwiftUI

struct KnowledgeView: View {
    @EnvironmentObject var serviceProvider: ServiceProvider
    @StateObject private var viewModel = KnowledgeViewModel()
    
    private let telegram = "@diia_gov"
    
    var body: some View {
        ZStack {
            if viewModel.isFetched == .fetched {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            ForEach(viewModel.questionRows, id: \.id) { row in
                                VStack {
                                    HStack {
                                        Text("\(row.id + 1)")
                                            .font(FontsTool.gilroyBold.font(16))
                                            .foregroundColor(Asset.Colors.purple.color())
                                            .lineSpacing(5)
                                            .padding(.horizontal, 8)
                                        
                                        Text(row.name)
                                            .font(FontsTool.gilroy.font(14))
                                            .foregroundColor(Asset.Colors.black.color())
                                        
                                        Spacer()
                                        
                                        Image(row.isActive ? "pd_arrow_up" : "pd_arrow")
                                            .padding(.trailing, 8)
                                    }
                                    
                                    if row.isActive {
                                        HStack {
                                            Text(row.detailText)
                                                .font(FontsTool.gilroy.font(14))
                                                .foregroundColor(Asset.Colors.black.color())
                                                .lineSpacing(4)
                                                .multilineTextAlignment(.leading)
                                                .padding(.top, 4)
                                            Spacer()
                                        }
                                        .padding(.leading, 8)
                                    }
                                    
                                    Rectangle()
                                        .fill(Asset.Colors.gray.color().opacity(0.1))
                                        .frame(width: viewModel.listWidth - 16, height: 1, alignment: .center)
                                        .isHidden(row.id == viewModel.questionRows.count - 1)
                                        .padding(.top, 4)
                                }
                                .padding(.bottom, 8)
                                .onTapGesture {
                                    viewModel.questionRows[row.id].isActive.toggle()
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(EdgeInsets(top: 32, leading: 16, bottom: 16, trailing: 16))
                    
                    Spacer()
                    
                    Button(action: {
                        toTelegram()
                    }, label: {
                        ZStack {
                            Asset.Images.knowledgeBtn.image()
                            Asset.Images.knowledgeBtnGradient.image()
                            Text(L10n.Knowledge.knowledgeBtn.localized(serviceProvider.bundle))
                                .font(FontsTool.gilroyBold.font(14))
                                .foregroundColor(Asset.Colors.white.color())
                        }
                    })
                    .padding(.bottom, 16)
                }
            } else {
                PreloaderView(isFetched: viewModel.isFetched) {
                    viewModel.isFetched = .notFetched
                    viewModel.fetchData(serviceProvider: serviceProvider)
                }
                .environmentObject(serviceProvider)
            }
        }
        .background(Asset.Colors.background.color().edgesIgnoringSafeArea(.all))
        .onAppear {
            if viewModel.isFetched != .error && viewModel.isFetched != .notFetched {
                viewModel.isFetched = .notFetched
                viewModel.fetchData(serviceProvider: serviceProvider)
            }
        }
    }
    
    func toTelegram() {
        if let url = URL(string: "tg://msg?&to=\(telegram)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}
