//
//  JustSequencePublisherViewModel.swift
//  CombineApp
//
//  Created by Sonata Girl on 23.05.2024.
//

import SwiftUI
import Combine

struct JustSequencePublisherView: View {

    @StateObject private var viewModel = JustSequencePublisherViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("\(viewModel.title)")
                .bold()

            Form {
                Section(header: Text("Фрукты").padding()) {
                    List(viewModel.dataToView, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            .font(.title)
            .onAppear {
                viewModel.fetch()
            }
            HStack {
                Button("Добавить фрукт") {
                    viewModel.addFruit()
                }
                Button("Удалить фрукт") {
                    viewModel.removeFruit()
                }
            }
        }
    }
}

final class JustSequencePublisherViewModel: ObservableObject {
    @Published var title = ""
    @Published var dataToView: [String] = []

    var fruits = ["Apple", "Banana", "Ananas", "Pinepple"]
    var fruitsDop = ["Apple2", "Banana2", "Ananas2", "Pinepple3"]

    func fetch() {
        _ = fruits.publisher
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [unowned self] value in
                dataToView.append(value)
                print(value)
            })

        if fruits.count > 0 {
            Just(fruits[1])
                .map { item in
                    item.uppercased()
                }
                .assign(to: &$title)
        }
    }

    func addFruit() {
        if fruitsDop.count > 0 {
            fruits.append(fruitsDop.removeFirst())
            dataToView.removeAll()
            fetch()
        }
    }

    func removeFruit() {
        if fruits.count > 4 {
            fruitsDop.append(fruits.removeLast())
            if dataToView.count > 0 {
                dataToView.removeAll()
            }
            fetch()
        }
    }
}
