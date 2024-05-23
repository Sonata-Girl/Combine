//
//  FuturePublisherView2.swift
//  CombineApp
//
//  Created by Sonata Girl on 23.05.2024.
//

import SwiftUI
import Combine

struct FuturePublisherView2: View {

    @StateObject private var viewModel = FuturePublisherViewModel2()

    var body: some View {
        VStack(spacing: 20) {
            Text("\(viewModel.firstResult)")
            Button("Запуск") {
                viewModel.runAgain()
            }

            Text(viewModel.secondResult)
                .font(.title)
                .onAppear {
                    viewModel.fetch()
                }
        }
    }
}

final class FuturePublisherViewModel2: ObservableObject {
    @Published var firstResult = ""
    @Published var secondResult = ""
    //    let futurePublisher = Future<String, Never> { promise in
    //        promise(.success("FuturePublisher сработал"))
    //        print("FuturePublisher сработал")
    //    }
    let futurePublisher = Deferred {
        Future<String, Never> { promise in
            promise(.success("FuturePublisher сработал"))
            print("FuturePublisher сработал")
        }
    }

    init() {

    }

    func fetch() {
        futurePublisher
            .assign(to: &$firstResult)
    }

    func runAgain() {
        futurePublisher
            .assign(to: &$secondResult)
    }

}
