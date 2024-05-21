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
        CurrentValueSubjectView()
    }
}

#Preview {
    ContentView()
}

struct CurrentValueSubjectView: View {

    @StateObject private var viewModel = CurrentValueSubjectViewModel()

    var body: some View {
        VStack {
            Text("\(viewModel.selectionSame.value ? "Два раза выбрали" : "") \(viewModel.selection.value)")
                .foregroundStyle(viewModel.selectionSame.value ? .red : .green)
                .padding()
            Button("Выбрать колу") {
                viewModel.selection.value = "Кола"
            }
            .padding()
            Button("Выбрать бургер") {
                // аналог  viewModel.selection.value = "Кола"
                viewModel.selection.send("Бургер")
            }
            .padding()
        }
    }
}

final class CurrentValueSubjectViewModel: ObservableObject {

    // этот паблишер требует тип который он будет хранить и какуюто ошибку обычно
    // в данном случае Never - говорит о том что он ошибки не обрабатывает(обычно его и используют)
    var selection = CurrentValueSubject<String, Never>("Корзина пуста")
    var selectionSame = CurrentValueSubject<Bool, Never>(false)

    var cancellable: Set<AnyCancellable> = []

    init() {
        selection
            .map { [unowned self] newValue -> Bool in
                if newValue == selection.value {
                    return true
                } else {
                    return false
                }
            }
            .sink { [unowned self] value in
                print(value)
                selectionSame.value = value
                // запускаем обновление UI
                objectWillChange.send()
            }
            .store(in: &cancellable)
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
