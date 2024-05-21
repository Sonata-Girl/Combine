//
//  ContentView.swift
//  CombineApp
//
//  Created by Sonata Girl on 20.05.2024.
//

import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        FirstPipelineView()
    }
}

#Preview {
    ContentView()
}

struct FirstPipelineView: View {

    @StateObject var viewModel = FirstPipelineViewModel()

    var body: some View {
        VStack {
            TextField("Ваше имя", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Ваша фамилия", text: $viewModel.surname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text(viewModel.validation)
        }
        .padding()
        Text("Hello, \(viewModel.name) \(viewModel.surname)")
        Button("Отмена подписки") {
            viewModel.validation = ""
            viewModel.anyCancellable?.cancel()
        }
    }
}

final class FirstPipelineViewModel: ObservableObject {
    @Published var name = "..."
    @Published var surname = "..."
    @Published var validation = ""

    var anyCancellable: AnyCancellable?

    init() {
        anyCancellable = $name
            .map { $0.isEmpty || self.surname.isEmpty ? "❌" : "✅"}
            .sink { value in
                self.validation = value

            }
        anyCancellable = $surname
            .map { $0.isEmpty || self.name.isEmpty ? "❌" : "✅"}
            .sink { value in
                self.validation = value

            }
    }
}
