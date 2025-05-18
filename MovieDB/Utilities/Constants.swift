//  Created by Aji Prakosa on 18/5/25.

import Foundation

struct Constants {
    static let apiKey = "f5a56ab8ae2b7cc43b4060163f97b949"
    static let baseURL = "https://api.themoviedb.org/3"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    struct Endpoints {
        static let discoverMovies = "/discover/movie"
        static let movieDetails = "/movie"
        static let movieReviews = "/movie/%d/reviews"
        static let movieVideos = "/movie/%d/videos"
    }
}
