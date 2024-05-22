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
        EmptyFailurePublishersView()
    }
}

#Preview {
    ContentView()
}

struct EmptyFailurePublishersView: View {

    @StateObject private var viewModel = EmptyFailurePublishersViewModel()
    @State var textFieldString: String = ""

    var body: some View {
        VStack {
            VStack {
                Spacer()
                TextField("Введите строку", text: $viewModel.inputText.value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                HStack {
                    if viewModel.isButtonVisible {
                        Button("Добавить") {
                            viewModel.selectionForAddWord.value = viewModel.inputText.value
                        }
                    } else {
                        Text("Добавить")
                            .foregroundStyle(.gray)
                    }
                    Button("Очистить список") {
                       viewModel.clearList()
                    }
                }
            }
            .background(.white)
            .frame(height: 150)
            VStack {
                List(viewModel.dataToView.value, id: \.self) { item in
                    Text(item)
                }
            }
            .background(Color(uiColor: .lightGray))
            Spacer()
        }
    }
}

final class EmptyFailurePublishersViewModel: ObservableObject {
    var dataToView = CurrentValueSubject<[String], Never>([])
    @Published var isButtonVisible = false
    var selectionForAddWord = CurrentValueSubject<String, Never>("")
    var inputText = CurrentValueSubject<String, Never>("")

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
        selectionForAddWord
            .filter {
                !$0.isEmpty
            }
            .sink { [unowned self] newValue in
                datas.append(newValue)
                dataToView.value.removeAll()
                fetch()
                inputText.value = ""
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

    func clearList() {
        datas.removeAll()
        dataToView.value.removeAll()
        objectWillChange.send()
    }
}
