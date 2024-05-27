//
//  DataTaskPublisher2.swift
//  CombineApp
//
//  Created by Sonata Girl on 24.05.2024.
//


import SwiftUI
import Combine

struct DataTaskPublisher2: View {

    @StateObject private var viewModel = DataTaskPublisher2Model()

    var body: some View {
        VStack(spacing: 20) {
            viewModel.avatarImage
        }
        .onAppear {
            viewModel.fetch()
        }
    }
}

struct ErrorForAlert: Error, Identifiable {
    let id = UUID()
    let title = "Error"
    var message = "try again later"
}

final class DataTaskPublisher2Model: ObservableObject {
    @Published var avatarImage: Image?
    @Published var alertError: ErrorForAlert?

    var cancellables: Set<AnyCancellable> = []

    func fetch() {
        guard let url = URL(string: "https://via.placeholder.com/600/d32776") else {
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .tryMap { data in
                guard let uiImage = UIImage(data: data) else {
                    throw ErrorForAlert(message: "No image")
                }
                return Image(uiImage: uiImage)
            }
            .receive(on: RunLoop.main)
            .replaceError(with: Image("blank"))
            .sink { [unowned self] image in 
                self.avatarImage = image
            }
            .store(in: &cancellables)
    }
}
