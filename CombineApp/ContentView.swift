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
        PassThroughSubjectTimerTask10View()
    }
}

#Preview {
    ContentView()
}

enum ViewStateGoods<Model> {
    case connecting(_ data: Model)
    case loading(_ data: Model)
    case data(_ data: Model)
    case error(_ error: Error)
}


struct PassThroughSubjectTimerTask10View: View {

    @StateObject private var viewModel = PassThroughSubjectTimerTask10ViewModel()
    @State var showFirstLoading = false
    @State var showSecondLoading = false
    @State var showSecondTable = false

    var body: some View {
        VStack {
            switch viewModel.state {
                case .connecting(let time):
                    VStack {
                        Text("Connecting...\(time)")
                    }
                    .background(.white)
                    .frame(height: 60)
                case .loading(let time):
                    VStack {
                        Text("Loading \(time)")
                    }
                    .background(.white)
                    .frame(height: 60)
                case .data(let time):
                    Text("Loaded \(time)")
                        .background(.white)
                        .frame(height: 60)
                case .error(let error):
                    Text(error.localizedDescription)
                        .background(.white)
                        .frame(height: 60)
            }
        }

        if showFirstLoading {
            VStack {
                Text("wait")
                    .font(.largeTitle)
                    .transition(.slide)
            }
        } else if showSecondLoading {
            VStack {
                Text("please wait")
                    .transition(.slide)
                    .transition(.opacity)
                    .font(.title)
                ProgressView()
                    .transition(.slide)
                    .frame(height: 100)
            }
        } else {
            if showSecondTable {
                VStack(spacing: 20) {
                    Form {
                        List(viewModel.dataToView, id: \.self) { item in
                            HStack {
                                Image(systemName: item.imageName)
                                Text("\(item.name) \(item.price) руб")
                            }
                        }
                    }
                }
            }
        }
        Spacer()
        Button("Старт") {
            viewModel.start()
            withAnimation(.easeIn) {
                showFirstLoading.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeIn) {
                    showFirstLoading.toggle()
                    showSecondLoading.toggle()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                withAnimation(.easeIn) {
                    showSecondLoading.toggle()
                    viewModel.fetch()
                    showSecondTable.toggle()
                }
            }
        }
    }
}

struct Good: Hashable {
    let imageName: String
    let price: Int
    let name: String
}

final class PassThroughSubjectTimerTask10ViewModel: ObservableObject {
    @Published var state: ViewStateGoods<String> = .connecting("00:00")
    @Published var dataToView: [Good] = []

    var goods: [Good] = [.init(imageName: "", price: 40, name: "Огурцы"),
                         .init(imageName: "star", price: 105, name: "Помидоры"),
                         .init(imageName: "star.slash", price: 140, name: "Хлеб"),
                         .init(imageName: "star.square", price: 150, name: "Сыр"),
                         .init(imageName: "star.leadinghalf.filled", price: 120, name: "Соль"),
                         .init(imageName: "star.square.fill", price: 100, name: "Вода"),
                         .init(imageName: "star.slash.fill", price: 102, name: "Черри"),
                         .init(imageName: "moon.stars", price: 103, name: "Лук")]

    let verifyState = PassthroughSubject<String, Never>()
    let secondsState = PassthroughSubject<Int, Never>()

    var cancellable: AnyCancellable?
    var timerCancellable: AnyCancellable?

    init() {
    }

    func fetch() {
        _ = goods.publisher
            .filter {
                $0.price > 100 && $0.imageName != ""
            }
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [unowned self] value in
                dataToView.append(value)
                print(value)
            })
    }

    func start() {
        var leftTime = 10
        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [unowned self] datum in
                secondsState.send(leftTime)
                verifyState.send("00:\(String(format: "%02d", leftTime))")
                if leftTime > 6 {
                    state = .connecting("00:\(String(format: "%02d", leftTime))")
                } else if leftTime < 4 {
                    state = .data("00:\(String(format: "%02d", leftTime))")
                } else if leftTime < 7 {
                    state = .loading("00:\(String(format: "%02d", leftTime))")
                } else {
                    state = .error(NSError(domain: "Error time", code: 101))
                }
                if leftTime == 0 {
                    timerCancellable?.cancel()
                }
                leftTime -= 1
            })
    }
}
