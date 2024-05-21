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
            Spacer()
            Text(viewModel.data)
                .font(.title)
                .foregroundStyle(.green)
            Text(viewModel.status)
                .foregroundStyle(.blue)

            Spacer()

            Button {
                viewModel.cancel()
            } label: {
                Text("Отменить подписку")
                    .padding(.vertical, 8)
                    .padding(.horizontal)
            }
            .background(.red)
            .cornerRadius(8)
            .opacity(viewModel.status == "Запрос в банк..." ? 1.0 : 0.0)

            Button {
                viewModel.refresh()
            } label: {
                Text("Запрос данных")
                    .padding(.vertical, 8)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
            }
            .background(.blue)
            .cornerRadius(8)
            .padding()
        }
        .padding()

    }
}

final class FirstPipelineViewModel: ObservableObject {
    @Published var data = ""
    @Published var status = ""
    @Published var validation = ""

    private var cancellable: AnyCancellable?

    init() {
        cancellable = $data
            .map { [unowned self] value -> String in
                self.status = "Запрос в банк..."
                return value
            }
            .delay(for: 5, scheduler: DispatchQueue.main)
            .sink { [unowned self] value in
                self.data = "Сумма всех счетов 1 млн."
                self.status = "Данные получены."

            }
    }

    func refresh() {
        data = "Перезапрос данных"
    }

    func cancel() {
        status = "Операция отменена"
        cancellable?.cancel()
        cancellable = nil
    }
}
