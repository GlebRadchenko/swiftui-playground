//
//  CollectionView.swift
//  CollectionView-playground
//
//  Created by Gleb Radchenko on 04.06.20.
//  Copyright © 2020 Volkswagen AG. All rights reserved.
//

import SwiftUI

protocol CollectionViewLayout {
    associatedtype ID: Hashable
    associatedtype ModifiedView: View

    func layout(content: AnyView, elementID: ID, geometry: GeometryProxy) -> ModifiedView
    func invalidate()
}

protocol CollectionViewDataSource: ObservableObject {
    associatedtype Item: Identifiable
    var items: [Item] { get }
}

protocol CollectionViewDelegate {
    associatedtype Item: Identifiable
    associatedtype ContentView: View

    func view(for item: Item) -> ContentView
}

struct CollectionView<
    Content,
    Item,
    DataSource: CollectionViewDataSource,
    Delegate: CollectionViewDelegate,
    Layout: CollectionViewLayout
>: View where
    DataSource.Item == Item,
    Delegate.Item == Item,
    Delegate.ContentView == Content,
    Layout.ID == DataSource.Item.ID
{
    let layout: Layout
    let delegate: Delegate
    @ObservedObject var dataSource: DataSource

    var body: some View {
        GeometryReader { [delegate, dataSource, layout] geometry in
            ScrollView([.horizontal], showsIndicators: true) {
                VStack(alignment: .leading) {
                    ZStack(alignment: .topLeading) {
                        ForEach(dataSource.items, id: \.id) { item in
                            layout.layout(
                                content: AnyView(delegate.view(for: item)),
                                elementID: item.id,
                                geometry: geometry
                            )
                        }
                    }
                    .border(Color.green, width: 2)
                    Spacer()
                }
                .border(Color.blue, width: 2)
            }
        }
        .onReceive(dataSource.objectWillChange) { [layout] _ in
            layout.invalidate()
        }
    }
}
