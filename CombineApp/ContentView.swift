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
        FuturePublisherTask8View()
    }
}

#Preview {
    ContentView()
}

struct FuturePublisherTask8View: View {

    @StateObject private var viewModel = FuturePublisherTask8ViewModel()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Введите число", text: $viewModel.inputText.value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Проверить число") {
                viewModel.checkNumber()
            }
            Text("\(viewModel.result)")
                .foregroundStyle(.green)
        }
    }
}

final class FuturePublisherTask8ViewModel: ObservableObject {
    @Published var result = ""
    var cancellable: AnyCancellable?
    var inputText = CurrentValueSubject<String, Never>("")

    func checkNumber() {
        Future<String, Never> { promise in
            for number in 2...500 {
                if let intNumber = Int(self.inputText.value), intNumber != Int(number),
                   intNumber % Int(number) == 0 {
                    print(number)
                    promise(.success("\(self.inputText.value) - Это не простое число."))
                }
            }
            promise(.success("\(self.inputText.value) - Это простое число."))
        }
        .assign(to: &$result)
    }
}
