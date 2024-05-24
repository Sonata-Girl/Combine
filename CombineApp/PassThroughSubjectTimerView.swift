//
//  PassThroughSubjectTimerView.swift
//  CombineApp
//
//  Created by Sonata Girl on 23.05.2024.
//

import SwiftUI
import Combine

enum ViewState<Model> {
    case loading
    case data(_ data: Model)
    case error(_ error: Error)
}

struct PassThroughSubjectTimerView: View {

    @StateObject private var viewModel = PassThroughSubjectTimerViewModel()

    var body: some View {
        VStack {
            switch viewModel.state {
                case .loading:
                    Button("Старт") {
                        viewModel.verifyState.send("00:00")
                        viewModel.start()
                    }
                case .data(let time):
                    Text(time)
                        .font(.title)
                        .foregroundStyle(.green)
                case .error(let error):
                    Text(error.localizedDescription)
            }
        }
    }
}

final class PassThroughSubjectTimerViewModel: ObservableObject {
    @Published var state: ViewState<String> = .loading

    let verifyState = PassthroughSubject<String, Never>()

    var cancellable: AnyCancellable?
    var timerCancellable: AnyCancellable?

    init() {
        bind()
    }

    func bind() {
        cancellable = verifyState
            .sink(receiveValue: { [unowned self] value in
                if !value.isEmpty {
                    state = .data(value)
                    start()
                } else {
                    state = .error(NSError(domain: "Error time", code: 101))
                }
            })
    }

    func start() {
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "00:ss"

        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [unowned self] datum in
                verifyState.send(timeFormat.string(from: datum))
            })
    }
}
