//  Created by Aji Prakosa on 18/5/25.

import SwiftUI
import RxSwift
import RxCocoa

class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    @Published var hasMoreData = true
    
    private(set) var currentPage = 1
    private let networkService: NetworkServiceProtocol
    private let disposeBag = DisposeBag()
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchMovies(isRefreshing: Bool = false) {
        guard !isLoading else { return }
        
        if isRefreshing {
            currentPage = 1
            hasMoreData = true
        }
        
        guard hasMoreData else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await networkService.fetchMovies(page: currentPage)
                
                DispatchQueue.main.async {
                    if isRefreshing {
                        self.movies = response.results
                    } else {
                        self.movies += response.results
                    }
                    
                    self.currentPage += 1
                    self.hasMoreData = self.currentPage <= response.totalPagesCount
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = error as? NetworkError ?? NetworkError.decodingError("Unknown error")
                }
            }
        }
    }
    
    func loadMoreMoviesIfNeeded(currentItem item: Movie?) {
        guard let item = item else {
            fetchMovies()
            return
        }
        
        let thresholdIndex = movies.index(movies.endIndex, offsetBy: -5)
        if movies.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            fetchMovies()
        }
    }
}
