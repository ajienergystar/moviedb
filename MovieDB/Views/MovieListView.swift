//  Created by Aji Prakosa on 18/5/25.

// File: Views/MovieListView.swift

import SwiftUI
import Kingfisher

struct MovieListView: View {
    @StateObject private var viewModel = MovieListViewModel()
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.movies.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    movieGridView
                }
            }
            .navigationTitle("Latest Movie")
            .searchable(text: $searchText, prompt: "Find a movie...")
            .refreshable {
                viewModel.fetchMovies(isRefreshing: true)
            }
            .overlay {
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { }
                Button("Try Again") {
                    viewModel.fetchMovies()
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Error occurred")
            }
        }
        .onAppear {
            if viewModel.movies.isEmpty {
                viewModel.fetchMovies()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No movie found")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button("Reload") {
                viewModel.fetchMovies()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var movieGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink {
                        MovieDetailView(movieId: movie.id)
                    } label: {
                        MoviePosterCard(movie: movie)
                            .onAppear {
                                viewModel.loadMoreMoviesIfNeeded(currentItem: movie)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            
            if viewModel.isLoading && !viewModel.movies.isEmpty {
                ProgressView()
                    .padding()
            }
        }
    }
}

struct MoviePosterCard: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            KFImage(movie.posterURL)
                .resizable()
                .placeholder {
                    Image("image_default_icon")
                        .resizable()
                        .frame(width: 100, height: 100)
                }
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.subheadline)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text(movie.ratingText)
                        .font(.caption)
                }
                
                Text(movie.formattedReleaseDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}
