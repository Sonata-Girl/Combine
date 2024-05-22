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
        GuessNumberView()
    }
}

#Preview {
    ContentView()
}

struct GuessNumberView: View {

    @StateObject private var viewModel = GuessNumberViewModel()
    @State private var showNumber = false

    var body: some View {
        VStack {
            Spacer()
            TextField("Введите любое число", text: $viewModel.selection.value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()
            Button("Завершить игру") {
                showNumber.toggle()
                viewModel.cancelGame()
            }
            Spacer()
            Text(viewModel.text.value)

            if showNumber {
                Text("Загаданное число: \(viewModel.guessNumber.value)")
            }
        }
    }
}

final class GuessNumberViewModel: ObservableObject {

    var selection = CurrentValueSubject<String, Never>("0")
    var guessNumber = CurrentValueSubject<Int, Never>(Int.random(in: 1...100))
    var text = CurrentValueSubject<String, Never>("")
    var cancellable: Set<AnyCancellable> = []

    init() {
        selection
            .map { [unowned self] newValue -> Int in
                if Int(newValue) ?? 0 == guessNumber.value {
                    return 1
                } else if Int(newValue) ?? 0 > guessNumber.value {
                    return 2
                } else if Int(newValue) ?? 0 < guessNumber.value {
                    return 3
                } else {
                    return 0
                }
            }
            .delay(for: 0.8, scheduler: DispatchQueue.main)
            .sink { [unowned self] value in
                if value == 2 {
                    text.value = "Введенное число больше загаданного"
                } else if value == 3 {
                    text.value = "Введенное число меньше загаданного"
                } else if value == 1 {
                    text.value = "Вы угадали!"
                }
                // запускаем обновление UI
                objectWillChange.send()
            }
            .store(in: &cancellable)
    }

    func cancelGame() {
        cancellable.removeAll()
    }
}
