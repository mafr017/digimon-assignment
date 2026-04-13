//
//  AppDependencyInjection.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 10/04/26.
//

import Foundation

final class AppDependencyInjection {
    
    static let shared = AppDependencyInjection()
    
    private init() {}

    lazy var networkClient: NetworkClientProtocol = NetworkClient.shared

    lazy var digimonService: DigimonServiceProtocol = DigimonService(network: networkClient)

    func digimonListViewModel() -> DigimonListViewModel {
        DigimonListViewModel(service: digimonService)
    }

    func digimonDetailViewModel(digimonId: Int) -> DigimonDetailViewModel {
        DigimonDetailViewModel(digimonId: digimonId, service: digimonService)
    }
}
