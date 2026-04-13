//
//  DigimonListViewModel.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 12/04/26.
//

import Foundation

enum ViewState {
    case idle
    case loading
    case success
    case error(NetworkError)
    case empty
}

@MainActor
final class DigimonListViewModel {
    
    private let service: DigimonServiceProtocol
    
    var onStateChanged: ((ViewState) -> Void)?
    var onFiltersLoaded: (() -> Void)?
    var onLoadMoreCompleted: (() -> Void)?
    
    private var query = DigimonQuery()
    
    var digimons: [DigimonList] = []
    var attributes: [BaseResponse] = []
    var levels: [BaseResponse] = []
    
    var searchName: String? = nil
    var selectedAttribute: String? = nil
    var selectedLevel: String? = nil
    
    private var currentPage = 0
    private let pageSize = 8
    private var isFetchMore = false
    private var hasMoreData = true
    
    init(service: DigimonServiceProtocol) {
        self.service = service
    }
    
    func initialLoad() {
        Task {
            onStateChanged?(.loading)
            async let digimonTask: () = loadFirstPage()
            async let filterTask: () = loadFilters()
            await digimonTask
            await filterTask
        }
    }
    
    func loadFirstPage() async {
        currentPage = 0
        hasMoreData = true
        digimons = []
        onStateChanged?(.loading)
        await fetchDigimons(isLoadMore: false)
    }
    
    private func loadFilters() async {
        async let attributeResult = service.fetchFilters(endPoint: ApiEndpoint.attribute)
        async let levelResult = service.fetchFilters(endPoint: ApiEndpoint.level)
        
        let (attrRes, levelRes) = await (attributeResult, levelResult)
        
        if case .success(let attrs) = attrRes { attributes = attrs }
        if case .success(let lvls) = levelRes { levels = lvls }
        
        onFiltersLoaded?()
    }
    
    private func fetchDigimons(isLoadMore: Bool) async {
        let result = await service.fetchDigimonList(
            query: DigimonQuery(
                name: searchName,
                attribute: selectedAttribute,
                level: selectedLevel,
                page: currentPage,
                pageSize: pageSize
            )
        )
        
        switch result {
        case .success(let listResult):
            
            if listResult.pageable.elementsOnPage == 0 {
                hasMoreData = false
                
                if !isLoadMore && digimons.isEmpty {
                    onStateChanged?(.empty)
                } else {
                    onStateChanged?(.success)
                }
                
                return
            }
            
            guard let data = listResult.content else {
                onStateChanged?(.empty)
                return
            }
            
            if isLoadMore {
                digimons.append(contentsOf: data)
                onLoadMoreCompleted?()
            } else {
                digimons = data
                onStateChanged?(digimons.isEmpty ? .empty : .success)
            }
            
            hasMoreData = currentPage < listResult.pageable.totalPages - 1
            
        case .failure(let error):
            onStateChanged?(.error(error))
        }
    }
    
    func loadMore() {
        guard !isFetchMore, hasMoreData else { return }
        Task {
            isFetchMore = true
            currentPage += 1
            await fetchDigimons(isLoadMore: true)
            isFetchMore = false
        }
    }
    
    func applySearch(_ name: String?) {
        searchName = name?.isEmpty == true ? nil : name
        Task { await loadFirstPage() }
    }
    
    func applyFilter(attribute: String?, level: String?) {
        selectedAttribute = attribute
        selectedLevel = level
        Task { await loadFirstPage() }
    }
}
