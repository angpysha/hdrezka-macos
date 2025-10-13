import Defaults
import SwiftUI

struct TVHomeView: View {
    private let title = String(localized: "key.home")
    
    @State private var viewModel = HomeViewModel()
    
    @Default(.isLoggedIn) private var isLoggedIn
    
    @State private var movieDestination: MovieSimple?
    @Namespace private var namespace
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 60, pinnedViews: []) {
                if let categories = viewModel.state.data, !categories.isEmpty {
                    ForEach(categories) { category in
                        VStack(alignment: .leading, spacing: 30) {
                            // Заголовок категорії
                            HStack(alignment: .center) {
                                Text(category.title)
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                NavigationLink(value: Destinations.category(HomeCategory.latest)) {
                                    HStack(spacing: 12) {
                                        Text("key.see_all")
                                            .font(.system(size: 32))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 32))
                                    }
                                }
                            }
                            .padding(.horizontal, 90)
                            
                            // Горизонтальний скрол фільмів
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(alignment: .top, spacing: 50) {
                                    ForEach(category.movies) { movie in
                                        NavigationLink(value: movie) {
                                            TVCardView(movie: movie, width: 300)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 90)
                            }
                            .frame(height: 550)
                        }
                    }
                }
            }
            .padding(.vertical, 60)
            
            if let error = viewModel.paginationState.error {
                VStack(spacing: 30) {
                    Text(error.localizedDescription)
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    
                    Button {
                        viewModel.loadMore(reset: true)
                    } label: {
                        Text("key.retry")
                            .font(.system(size: 28))
                    }
                }
                .padding(60)
            } else if viewModel.paginationState == .loading {
                ProgressView()
                    .scaleEffect(2.0)
                    .padding(60)
            }
        }
        .onScrollTargetVisibilityChange(idType: Category.ID.self) { onScreenCategories in
            if let categories = viewModel.state.data,
               !categories.isEmpty,
               let last = categories.last,
               onScreenCategories.contains(where: { $0 == last.id }),
               viewModel.paginationState == .idle
            {
                viewModel.loadMore()
            }
        }
        .overlay {
            if let error = viewModel.state.error {
                VStack(spacing: 40) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                    
                    Text(error.localizedDescription)
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        viewModel.load()
                    } label: {
                        Text("key.retry")
                            .font(.system(size: 28))
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                    }
                }
                .padding(90)
            } else if let categories = viewModel.state.data, categories.isEmpty {
                VStack(spacing: 40) {
                    Image(systemName: "film")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                    
                    Text("key.home.empty")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    
                    Button {
                        viewModel.load()
                    } label: {
                        Text("key.retry")
                            .font(.system(size: 28))
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                    }
                }
                .padding(90)
            } else if viewModel.state == .loading {
                ProgressView()
                    .scaleEffect(2.0)
            }
        }
        .task(id: isLoggedIn) {
            switch viewModel.state {
            case .data:
                break
            default:
                viewModel.load()
            }
        }
        .navigationDestination(item: $movieDestination) {
            TVDetailsView(movie: $0)
        }
        .navigationDestination(for: MovieSimple.self) { movie in
            TVDetailsView(movie: movie)
        }
        .navigationDestination(for: Destinations.self) { destination in
            switch destination {
            case .category(let category):
                Text("Category: \(category.localized)")
            case .person(let person):
                Text("Person: \(person.name)")
            case .collection(let collection):
                Text("Collection: \(collection.name)")
            }
        }
    }
}

