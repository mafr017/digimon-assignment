//
//  DigimonService.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 11/04/26.
//

import Foundation

protocol DigimonServiceProtocol {
    func fetchDigimonList(query: DigimonQuery) async -> Result<DigimonListResponse, NetworkError>
    func fetchFilters(endPoint: String) async -> Result<[BaseResponse], NetworkError>
    func fetchDigimonDetail(id: Int) async -> Result<Digimon, NetworkError>
}

final class DigimonService: DigimonServiceProtocol {
    
    private let network: NetworkClientProtocol
    
    init(network: NetworkClientProtocol) {
        self.network = network
    }
    
    func fetchDigimonList(query: DigimonQuery) async -> Result<DigimonListResponse, NetworkError> {
        return await network.request(
            ApiEndpoint.list,
            queryParameters: query.toQueryItems(),
            responseType: DigimonListResponse.self
        )
    }
    
    func fetchFilters(endPoint: String) async -> Result<[BaseResponse], NetworkError> {
        var listDataFilter: [BaseResponse] = []
        var page = 0
        
        while true {
            
            var items: [URLQueryItem] = []
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            
            let result = await network.request(
                endPoint,
                queryParameters: [URLQueryItem(name: "page", value: "\(page)")],
                responseType: DigimonFilter.self
            )
            
            switch result {
                
            case .success(let data):
                
                guard let dataList = data.content.fields else {
                    if listDataFilter.count > 0 {
                        return .success(listDataFilter)
                    } else {
                        return .failure(.decodingFailed)
                    }
                }
                
                listDataFilter.append(contentsOf: dataList)
                
                if data.pageable.elementsOnPage == 0 { break }
                
                page += 1
                
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func fetchDigimonDetail(id: Int) async -> Result<Digimon, NetworkError> {
        return await network.request("\(ApiEndpoint.list)/\(id)", queryParameters: nil, responseType: Digimon.self)
    }
}
