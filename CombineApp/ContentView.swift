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
            if viewModel.numberText.value == 2 {
                Text("Введенное число больше загаданного")
            } else if viewModel.numberText.value == 3 {
                Text("Введенное число меньше загаданного")
            } else if viewModel.numberText.value == 1 {
                Text("Вы угадали!")
            }
            if showNumber {
                Text("Загаданное число: \(viewModel.guessNumber.value)")
            }
        }
    }
}

final class GuessNumberViewModel: ObservableObject {

    var selection = CurrentValueSubject<String, Never>("0")
    var guessNumber = CurrentValueSubject<Int, Never>(Int.random(in: 1...100))
    var numberText = CurrentValueSubject<Int, Never>(0)
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
                numberText.value = value
                // запускаем обновление UI
                objectWillChange.send()
            }
            .store(in: &cancellable)
    }

    func cancelGame() {
        cancellable.removeAll()
    }
}


//PUBLISHED //////////////////

//import SwiftUI
//import Combine
//
//struct ContentView: View {
//    var body: some View {
//        CurrentValueSubjectView()
//    }
//}
//
//#Preview {
//    ContentView()
//}
//
//struct CurrentValueSubjectView: View {
//
//    @StateObject private var viewModel = CurrentValueSubjectViewModel()
//
//    var body: some View {
//        VStack {
//            Text("\(viewModel.selectionSame ? "Два раза выбрали" : "") \(viewModel.selection)")
//                .foregroundStyle(viewModel.selectionSame ? .red : .green)
//                .padding()
//            Button("Выбрать колу") {
//                viewModel.selection = "Кола"
//            }
//            .padding()
//            Button("Выбрать бургер") {
//                viewModel.selection = "Бургер"
//            }
//            .padding()
//        }
//    }
//}
//
//final class CurrentValueSubjectViewModel: ObservableObject {
//
//    @Published var selection = "Корзина пуста"
//    @Published var selectionSame = false
//
//    var cancellable: Set<AnyCancellable> = []
//
//    init() {
//        $selection
//            .map { [unowned self] newValue -> Bool in
//                if newValue == selection {
//                    return true
//                } else {
//                    return false
//                }
//            }
//            .sink { [unowned self] value in
//                print(value)
//                selectionSame = value
//            }
//            .store(in: &cancellable)
//    }
//}
