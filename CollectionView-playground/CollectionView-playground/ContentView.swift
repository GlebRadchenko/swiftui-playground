//
//  ContentView.swift
//  CollectionView-playground
//
//  Created by Gleb Radchenko on 04.06.20.
//  Copyright © 2020 Volkswagen AG. All rights reserved.
//

import SwiftUI
import Combine

struct SomeItem: Identifiable {
    var id: String

    init(id: String) {
        self.id = id
    }
}

class CollectionViewProvider: CollectionViewDataSource, CollectionViewDelegate {
    @Published var items: [SomeItem] = []

    init() {
        generateNewItems()
    }

    func generateNewItems() {
        items = (0...100).map {
            SomeItem(id: "\($0)")
        }
    }

    func view(for item: SomeItem) -> some View {
        HStack {
            Spacer()
            Text(item.id)
            Spacer()
        }
        .frame(width: .random(in: 50...150), height: .random(in: 50...150))
        .border(Color.black, width: 1)
    }
}

struct ExampleView: View {
    let provider = CollectionViewProvider()

    var body: some View {
        VStack {
            Spacer()
            CollectionView(
                layout: HorizontalPageLayout(),
                delegate: provider,
                dataSource: provider
            )
            .border(Color.red, width: 2)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}
