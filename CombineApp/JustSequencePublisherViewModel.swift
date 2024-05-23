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
                Section(header: Text("Участники конкурса").padding()) {
                    List(viewModel.dataToView, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            .font(.title)
            .onAppear {
                viewModel.fetch()
            }

        }
    }
}

final class JustSequencePublisherViewModel: ObservableObject {
    @Published var title = ""
    @Published var dataToView: [String] = []

    var names = ["Julian", "Jack", "Marina"]

    func fetch() {
        _ = names.publisher
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [unowned self] value in
                dataToView.append(value)
                print(value)
            })

        if names.count > 0 {
            //  в Future можно возвращать ошибку а тут такого нет можно отправить значения
            // Just и Future отправляют единожды
            Just(names[1])
                .map { item in
                    item.uppercased()
                }
                .assign(to: &$title)
        }
    }
}
