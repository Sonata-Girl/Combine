//
//  PassThroughSubjectTimerView.swift
//  CombineApp
//
//  Created by Sonata Girl on 23.05.2024.
//

import SwiftUI
import Combine

struct Post: Decodable {
    let title: String
    let body: String
}

struct URLSessionDataTaskPublisherView: View {

    @StateObject private var viewModel = URLSessionDataTaskPublisherViewModel()

    var body: some View {
        VStack(spacing: 20) {
            List(viewModel.dataToView, id: \.title) { post in
                Text(post.title)
                    .font(.title)
                    .bold()
                Text(post.body)
                    .font(.caption2)
            }
            .onAppear {
                viewModel.fetch()
            }
        }
    }
}

final class URLSessionDataTaskPublisherViewModel: ObservableObject {
    @Published var dataToView: [Post] = []

    var cancellables: Set<AnyCancellable> = []

    func fetch() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Post].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [unowned self] posts in
                dataToView = posts
            }
            .store(in: &cancellables)
    }
}
