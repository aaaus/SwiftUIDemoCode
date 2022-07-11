//
//  KnowledgeViewModel.swift
//  SmartBrick
//
//  Created by Alexander Andrusenko on 22.06.2022.
//

import UIKit
import Combine

protocol KnowledgeViewModelProtocol {
    var questionRows: [PdQuestionRow] { get }
    var isFetched: IsFetched { get set}
    var listWidth: CGFloat { get }
    var dataManager: ServiceProtocol { get }
    var cancellableSet: Set<AnyCancellable> { get }
    func fetchData(serviceProvider: ServiceProvider)
}

class KnowledgeViewModel: KnowledgeViewModelProtocol, ObservableObject {
    @Published var questionRows: [PdQuestionRow] = []
    @Published var isFetched: IsFetched = .fetching
    var listWidth = UIScreen.screenWidth - 24
    
    internal var dataManager: ServiceProtocol
    internal var cancellableSet: Set<AnyCancellable> = []
    
    init( dataManager: ServiceProtocol = NetworkService.shared) {
        self.dataManager = dataManager
    }
    
    func fetchData(serviceProvider: ServiceProvider) {
        dataManager.fetchData(Knowledge.self, path: ApiConstants.knowledge.rawValue)
            .sink { (dataResponse) in
                self.questionRows = []
                if dataResponse.error != nil {
                    print("KnowledgeViewModel error \(dataResponse.error!)")
                    self.isFetched = .error
                } else {
                    guard let object = dataResponse.value, let items = object.items else { return }
                    
                    self.questionRows = []
                    items.enumerated().forEach { [unowned self] (index, item) in
                        self.questionRows.append(
                            PdQuestionRow(id: index,
                                          itemId: item.id ?? "\(index)",
                                          name: item.title ?? "",
                                          detailText: item.description ?? "",
                                          isActive: false)
                        )
                    }
                    
                    if self.questionRows.count > 0 {
                        self.isFetched = .fetched
                    }
                }
            }.store(in: &cancellableSet)
    }
}
