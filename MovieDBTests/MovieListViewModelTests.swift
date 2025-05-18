//  Created by Aji Prakosa on 18/5/25.

import XCTest
import RxSwift
@testable import MovieDB

class MovieListViewModelTests: XCTestCase {
    var viewModel: MovieListViewModel!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = MovieListViewModel(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testFetchMoviesSuccess() {
        // Given
        let mockMovies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/poster1.jpg", backdropPath: "/backdrop1.jpg", voteAverage: 8.0, releaseDate: "2023-01-01"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/poster2.jpg", backdropPath: "/backdrop2.jpg", voteAverage: 7.5, releaseDate: "2023-01-02")
        ]
        
        mockNetworkService.mockMovieResponse = MovieResponse(page: 1, results: mockMovies, totalPages: 1, totalResults: 2)
        
        // When
        viewModel.fetchMovies()
        
        // Then
        XCTAssertTrue(viewModel.isLoading)
        
        let expectation = XCTestExpectation(description: "Wait for movies to load")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertEqual(self.viewModel.movies.count, 2)
            XCTAssertEqual(self.viewModel.movies[0].title, "Movie 1")
            XCTAssertEqual(self.viewModel.movies[1].title, "Movie 2")
            XCTAssertNil(self.viewModel.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchMoviesFailure() {
        // Given
        mockNetworkService.shouldFail = true
        
        // When
        viewModel.fetchMovies()
        
        // Then
        XCTAssertTrue(viewModel.isLoading)
        
        let expectation = XCTestExpectation(description: "Wait for error")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertTrue(self.viewModel.movies.isEmpty)
            XCTAssertNotNil(self.viewModel.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadMoreMovies() {
        // Given
        let mockMoviesPage1 = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/poster1.jpg", backdropPath: "/backdrop1.jpg", voteAverage: 8.0, releaseDate: "2023-01-01")
        ]
        
        let mockMoviesPage2 = [
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/poster2.jpg", backdropPath: "/backdrop2.jpg", voteAverage: 7.5, releaseDate: "2023-01-02")
        ]
        
        mockNetworkService.mockMovieResponse = MovieResponse(page: 1, results: mockMoviesPage1, totalPages: 2, totalResults: 2)
        
        // When - Load first page
        viewModel.fetchMovies()
        
        let expectation1 = XCTestExpectation(description: "Wait for first page")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then
            XCTAssertEqual(self.viewModel.movies.count, 1)
            XCTAssertEqual(self.viewModel.currentPage, 2)
            XCTAssertTrue(self.viewModel.hasMoreData)
            
            // Setup second page
            self.mockNetworkService.mockMovieResponse = MovieResponse(page: 2, results: mockMoviesPage2, totalPages: 2, totalResults: 2)
            
            // When - Load second page
            self.viewModel.loadMoreMoviesIfNeeded(currentItem: self.viewModel.movies.last)
            
            let expectation2 = XCTestExpectation(description: "Wait for second page")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then
                XCTAssertEqual(self.viewModel.movies.count, 2)
                XCTAssertEqual(self.viewModel.currentPage, 3)
                XCTAssertFalse(self.viewModel.hasMoreData)
                expectation2.fulfill()
            }
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 1.0)
    }
}

class MockNetworkService: NetworkServiceProtocol {
    var mockMovieResponse: MovieResponse!
    var shouldFail = false
    
    func fetchMovies(page: Int) async throws -> MovieResponse {
        if shouldFail {
            throw NetworkError.invalidResponse
        }
        return mockMovieResponse
    }
    
    func fetchMovieDetails(id: Int) async throws -> MovieDetail {
        throw NetworkError.invalidResponse
    }
    
    func fetchMovieReviews(id: Int) async throws -> ReviewResponse {
        throw NetworkError.invalidResponse
    }
    
    func fetchMovieVideos(id: Int) async throws -> VideoResponse {
        throw NetworkError.invalidResponse
    }
}


