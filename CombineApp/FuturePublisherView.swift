//
//  FuturePublisherView2.swift
//  CombineApp
//
//  Created by Sonata Girl on 23.05.2024.
//

import SwiftUI
import Combine

struct FuturePublisherView: View {

    @StateObject private var viewModel = FuturePublisherViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("\(viewModel.firstResult)")
            Button("Запуск") {
                viewModel.fetch()
            }
        }
    }
}

final class FuturePublisherViewModel: ObservableObject {
    @Published var firstResult = ""
    var cancellable: AnyCancellable?

    let futurePublisher = Deferred {
        Future<String, Never> { promise in
            promise(.success("FuturePublisher сработал"))
            print("FuturePublisher сработал")
        }
    }

    init() {

    }

    func createFetch(url: URL) -> AnyPublisher<String?, Error> {
        Future { promise in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                promise(.success(response?.url?.absoluteString ?? ""))
            }
            task.resume()
        }
        .eraseToAnyPublisher()
    }

    func fetch() {
        guard let url = URL(string: "https://google.com") else { return }
        cancellable = createFetch(url: url)
            .receive(on: RunLoop.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [unowned self] value in
                firstResult = value ?? ""
            }
    }
}
