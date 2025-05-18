//  Created by Aji Prakosa on 18/5/25.

import SwiftUI
import RxSwift
import RxCocoa

class MovieDetailViewModel: ObservableObject {
    @Published var movieDetail: MovieDetail?
    @Published var reviews: [Review] = []
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    
    private let networkService: NetworkServiceProtocol
    private let disposeBag = DisposeBag()
    
    init(movieId: Int, networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
        fetchMovieDetails(movieId: movieId)
    }
    
    func fetchMovieDetails(movieId: Int) {
        isLoading = true
        error = nil
        
        Task {
            do {
                async let detail = networkService.fetchMovieDetails(id: movieId)
                async let reviews = networkService.fetchMovieReviews(id: movieId)
                async let videos = networkService.fetchMovieVideos(id: movieId)
                
                let (movieDetail, reviewResponse, videoResponse) = try await (detail, reviews, videos)
                
                DispatchQueue.main.async {
                    self.movieDetail = movieDetail
                    self.reviews = reviewResponse.results
                    self.videos = videoResponse.results
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = error as? NetworkError
                }
            }
        }
    }
    
    var youtubeTrailer: Video? {
        videos.first { $0.site == "YouTube" && $0.type == "Trailer" }
    }
}
