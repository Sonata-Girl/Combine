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
        MagazineView()
    }
}

#Preview {
    ContentView()
}

struct MagazineView: View {

    @StateObject var viewModel = MagazineViewModel()

    var body: some View {
        VStack {
            ForEach(viewModel.goods.indices, id: \.self) { productIndex in
                HStack {
                    Text(viewModel.goods[productIndex].name)
                    Text("\(viewModel.goods[productIndex].price)")
                    Button {
                        viewModel.selectionForAddCheck = productIndex
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        viewModel.selectionForRemoveCheck = productIndex
                    } label: {
                        Image(systemName: "minus")
                    }
                }
                .padding()
            }

            Spacer()
            VStack {
                Text("Чек")
                ForEach(viewModel.checkGoods.indices, id: \.self) { productIndex in
                    HStack {
                        Text(viewModel.checkGoods[productIndex].name)
                        Spacer()
                        Text("\(viewModel.checkGoods[productIndex].price)")
                    }
                }
                Text("Итоговая сумма: \(viewModel.checkSum)")
            }
            .padding()
            Button {
                viewModel.clearCheck()
            } label: {
                Text("Очистить корзину")
            }
        }
    }
}

struct Good {
    let name: String
    let price: Int
}

final class MagazineViewModel: ObservableObject {
    @Published var goods: [Good] = []
    @Published var checkGoods: [Good] = []
    @Published var selectionForAddCheck: Int?
    @Published var selectionForRemoveCheck: Int?
    @Published var checkSum: Int = 0

    private var validationCancellables: Set<AnyCancellable> = []

    init() {
        goods = [.init(name: "Хлеб", price: 40),
                 .init(name: "Масло", price: 150),
                 .init(name: "Помидоры", price: 200),
                 .init(name: "Огурцы", price: 150),
                 .init(name: "Икра", price: 1300)]

        $selectionForAddCheck
            .map { [unowned self] selectedIndex -> Good? in
                if let index = selectedIndex, goods.indices.contains(index) {
                    return goods[index]
                }
                return nil
            }
            .filter {
                if let good = $0 {
                    good.price < 1000
                } else {
                    false
                }
            }
            .sink { [unowned self] value in
                if let good = value {
                    checkGoods.append(good)
                }
            }
            .store(in: &validationCancellables)

        $selectionForRemoveCheck
            .sink { [unowned self] selectedIndex in
                if let index = selectedIndex, goods.indices.contains(index) {
                    if let indexCart = checkGoods.firstIndex(where: { $0.name == goods[index].name }) {
                    checkGoods.remove(at: indexCart)
                    }
                }
            }
            .store(in: &validationCancellables)

        $checkGoods
            .map { $0.reduce(0) { $0 + $1.price } }
            .scan(0) { total, newSubtotal in
                newSubtotal == 0 ? 0 : newSubtotal + 100
            }
            .assign(to: \.checkSum, on: self)
            .store(in: &validationCancellables)
    }

    func clearCheck() {
        checkGoods.removeAll()
    }
}
