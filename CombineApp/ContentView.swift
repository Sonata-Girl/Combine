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
        Task7PublishersView()
    }
}

#Preview {
    ContentView()
}

struct Task7PublishersView: View {

    @StateObject private var viewModel = Task7PublishersViewModel()
    @State var textFieldString: String = ""

    var body: some View {
        VStack {
            VStack {
                Spacer()
                TextField("Введите число", text: $viewModel.inputText.value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                HStack {
                    if viewModel.isButtonVisible {
                        Button("Добавить") {
                            viewModel.addNumber()
//                            viewModel.selectionForAddWord.value = viewModel.inputText.value
                        }
                    } else {
                        Text("Добавить")
                            .foregroundStyle(.gray)
                    }
                    Button("Очистить список") {
                        viewModel.clearList()
                    }
                }
                if let error = viewModel.error?.rawValue {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
            .background(.white)
            .frame(height: 150)
            VStack {
                List(viewModel.dataToView.value, id: \.self) { item in
                    Text("\(item)")
                }
            }
            .background(Color(uiColor: .lightGray))
            Spacer()
        }
    }
}

enum InvalidIntError: String, Error, Identifiable {
    var id: String { rawValue }
    case isNotInt = "Введенное значение не является числом"
}

final class Task7PublishersViewModel: ObservableObject {
    
    @Published var isButtonVisible = false
    @Published var error: InvalidIntError?
    var selectionForAddWord = CurrentValueSubject<String, Never>("")
    var inputText = CurrentValueSubject<String, Never>("")
    var dataToView = CurrentValueSubject<[String], Never>([])

    var datas: [String?] = []
    var cancellable: Set<AnyCancellable> = []

    init() {
        inputText
            .map { newValue -> Bool in
                newValue.isEmpty ? false : true
            }
            .sink { [unowned self] value in
                self.isButtonVisible = value
            }
            .store(in: &cancellable)
    }

    func fetch() {
        _ = datas.publisher
            .flatMap { item -> AnyPublisher<String, Never> in
                if let item = item {
                    return Just(item)
                        .eraseToAnyPublisher()
                } else {
                    return Empty(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
            }
            .sink { [unowned self] item in
                dataToView.value.append(item)
            }
    }

    func addNumber() {
        _ = validationPublisher(numberText: inputText.value)
            .sink { completion in
                switch completion {
                    case .failure(let error):
                        self.error = error
                    case .finished:
                        self.error = nil
                        break
                }
            } receiveValue: { [unowned self] value in
                datas.append(String(value))
                dataToView.value.append(String(value))
                inputText.value = ""
                objectWillChange.send()
            }
    }

    func validationPublisher(numberText: String) -> AnyPublisher<String, InvalidIntError> {
        if numberText.isEmpty {
            return Just("")
                .setFailureType(to: InvalidIntError.self)
                .eraseToAnyPublisher()
        } else if let intNumber = Int(numberText) {
            return Just(String(intNumber))
            // из Never в Just делает определенный тип ошибки
                .setFailureType(to: InvalidIntError.self)
                .eraseToAnyPublisher()

        } else {
            return Fail(error: InvalidIntError.isNotInt)
                .eraseToAnyPublisher()
        }
    }

    func clearList() {
        datas.removeAll()
        dataToView.value.removeAll()
        objectWillChange.send()
    }
}
