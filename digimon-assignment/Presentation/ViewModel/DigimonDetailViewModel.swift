//
//  DigimonDetailViewModel.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 12/04/26.
//

import Foundation

enum DetailViewState {
    case loading
    case success(Digimon)
    case error(NetworkError)
}

@MainActor
final class DigimonDetailViewModel {

    private let digimonId: Int
    private let service: DigimonServiceProtocol

    var onStateChanged: ((DetailViewState) -> Void)?

    init(digimonId: Int, service: DigimonServiceProtocol) {
        self.digimonId = digimonId
        self.service = service
    }

    func load() {
        Task {
            onStateChanged?(.loading)
            let result = await service.fetchDigimonDetail(id: digimonId)
            switch result {
            case .success(let detail):
                onStateChanged?(.success(detail))
            case .failure(let error):
                onStateChanged?(.error(error))
            }
        }
    }
}
