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
        Task11DataTaskPublisher()
    }
}

#Preview {
    ContentView()
}

enum ViewState<Model> {
    case loading
    case data
    case error(_ error: Error)
}

struct EpisodeDto: Decodable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let characters: [URL]
    var imageData: Data?
    var charName: String?

    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case id
        case name
        case episode
        case characters
    }
}

struct CharacterDto: Decodable {
    let id: Int
    let name: String
    let image: URL
}

struct Task11DataTaskPublisher: View {

    var errorAlertView: some View {
        VStack {
            Text(viewModel.alertText.value)
                .foregroundStyle(.black)
            Button(role: .cancel) {
                viewModel.showErrorAlert.value.toggle()
            } label: {
                Text("Cancel")
                    .foregroundStyle(.red)
            }
            .foregroundStyle(.blue)
        }
        .frame(width: 300, height: 200)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.white)))
        .padding(.top, 100)
        .shadow(radius: 15)
    }

    var body: some View {
            VStack {
                switch viewModel.state {
                    case .loading:
                            Image("loading")
                                .frame(width: 200, height: 200)
                                .rotationEffect(Angle(degrees: rotating ? 360 : 0))
                                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: rotating)
                                .transition(.opacity)
                                .onAppear {
                                    self.rotating = true
                                }
                                .animation(.default, value: viewModel.showPortal.value)
                    case .data:
                            VStack(spacing: 20) {
                                Image("logo")
                                    .frame(width: 350, height: 100)
                                List(viewModel.dataToView.indices, id: \.self) { itemIndex in
                                    RoundedRectangle(cornerRadius: 8)
                                        .shadow(color: .gray, radius: 10, x: 5, y: 5)
                                        .frame(width: 350, height: 320)
                                        .overlay(alignment: .top) {
                                            VStack(alignment: .leading) {
                                                Image(uiImage: (UIImage(data: viewModel.dataToView[itemIndex].imageData ?? Data()) ?? UIImage(named: "character")!))
                                                    .resizable()
                                                    .frame(width: 350, height: 200)
                                                RoundedRectangle(cornerRadius: 10)
                                                    .background(.white)
                                                    .overlay(alignment: .leading) {
                                                        Text("\(viewModel.dataToView[itemIndex].charName ?? "")")
                                                        .font(.title2)
                                                        .bold()
                                                        .foregroundStyle(.black)
                                                        .frame(width: 350, height: 40)
                                                        .padding(.zero)
                                                }
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundStyle(.gray.opacity(0.3))
                                                    .overlay(alignment: .center) {
                                                        HStack {
                                                            Image("iconPlay")
                                                                .frame(width: 50, height: 50)
                                                                .padding(.leading)
                                                            Text("\(viewModel.dataToView[itemIndex].name) | \(viewModel.dataToView[itemIndex].episode)")
                                                                .bold()
                                                                .foregroundStyle(.black)
                                                            Spacer()
                                                            Image("heart")
                                                                .frame(width: 50, height: 50)
                                                                .padding(.trailing)
                                                        }
                                                    }
                                                    .frame(width: 350, height: 63)
                                            }
                                        }

                                }
                                .foregroundStyle(.white)
                                .background(.white)
                        }
                    case .error:
                        if viewModel.showErrorAlert.value {
                            errorAlertView
                                .transition(AnyTransition.opacity)
                                .zIndex(1)
                        }
                }
        }
        .onAppear {
            viewModel.fetch()

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                viewModel.fetchCharacters()
            }
        }
    }

    @StateObject private var viewModel = Task11DataTaskPublisherModel()
    @State private var rotating = false
}
