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
        HStack {
            TextField("Ваше имя", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text(viewModel.validation)
        }
        .padding()
        Text("Hello, \(viewModel.name)")
    }
}

class FirstPipelineViewModel: ObservableObject {
    @Published var name = "..."
    @Published var validation = ""

    init() {
        $name
            .map { $0.isEmpty ? "X" : "V"}
            .assign(to: &$validation)
    }
}

struct FirstPipelineView_Previews: PreviewProvider {
    static var previews: some View {
        FirstPipelineView()
    }
}
