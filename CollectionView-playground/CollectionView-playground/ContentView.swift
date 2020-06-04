//
//  ContentView.swift
//  CollectionView-playground
//
//  Created by Gleb Radchenko on 04.06.20.
//  Copyright © 2020 Volkswagen AG. All rights reserved.
//

import SwiftUI
import Combine

protocol CollectionViewLayout {
    associatedtype ID: Hashable
    associatedtype ModifiedView: View

    func layout(content: AnyView, elementID: ID, geometry: GeometryProxy) -> ModifiedView
}

class HorizontalCollectionViewLayout: CollectionViewLayout {
    typealias ID = String

    fileprivate var attributes: [String: LayoutAttributes] = [:]
    var lastAttributes: LayoutAttributes?

    func layout(content: AnyView, elementID: String, geometry: GeometryProxy) -> some View {
        content
            .alignmentGuide(.leading) { dimensions in
                self.leadingAlignmentGuide(id: elementID, dimensions: dimensions, geometry: geometry)
            }
            .alignmentGuide(.top) { dimensions in
                self.topAlignmentGuide(id: elementID, dimensions: dimensions, geometry: geometry)
            }
    }

    // MARK: - Private
    fileprivate func leadingAlignmentGuide(id: String, dimensions: ViewDimensions, geometry: GeometryProxy) -> CGFloat {
        if let layoutAttributes = attributes[id], layoutAttributes.geometrySize == geometry.size {
            lastAttributes = layoutAttributes
            return -layoutAttributes.x
        } else if attributes[id] != nil {
            attributes.removeAll()
            lastAttributes = nil
        }

        var newAttributes = LayoutAttributes(
            x: 0,
            y: 0,
            page: 0,
            geometrySize: geometry.size,
            dimensions: dimensions
        )

        defer {
            lastAttributes = newAttributes
            attributes[id] = newAttributes
        }

        guard let lastAttributes = lastAttributes else {
            return -newAttributes.x
        }

        newAttributes.page = lastAttributes.page

        let x = lastAttributes.x + lastAttributes.dimensions.width

        // not enough space horizontally
        if x + dimensions.width > geometry.size.width * CGFloat(lastAttributes.page + 1) {
            let newYPosition = maxY(for: newAttributes.page) ?? 0

            // not enough space vertically
            if newYPosition + dimensions.height > geometry.size.height {
                newAttributes.page += 1
                newAttributes.y = 0
            } else {
                newAttributes.y = newYPosition
            }

            newAttributes.x = CGFloat(newAttributes.page) * geometry.size.width
        } else {
            newAttributes.x = x
            newAttributes.y = lastAttributes.y
        }

        return -newAttributes.x
    }

    fileprivate func topAlignmentGuide(id: String, dimensions: ViewDimensions, geometry: GeometryProxy) -> CGFloat {
        -(attributes[id]?.y ?? 0)
    }

    // MARK: - Private
    func maxOriginY(for page: Int) -> CGFloat? {
        attributes.values
            .filter { $0.page == page }
            .map { $0.y }
            .max()
    }

    func maxY(for page: Int) -> CGFloat? {
        attributes.values
            .filter { $0.page == page }
            .map { $0.y + $0.dimensions.height }
            .max()
    }

    struct LayoutAttributes {
        var x: CGFloat
        var y: CGFloat
        var page: Int
        let geometrySize: CGSize
        let dimensions: ViewDimensions
    }
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
            ScrollView([.horizontal], showsIndicators: true) { [delegate, dataSource, layout] in
                ZStack(alignment: .topLeading) {
                    ForEach(dataSource.items, id: \.id) { item in
                        layout.layout(
                            content: AnyView(delegate.view(for: item)),
                            elementID: item.id,
                            geometry: geometry
                        )
                    }
                }
            }
        }
    }
}

struct SomeItem: Identifiable {
    var id: String

    init(id: String) {
        self.id = id
    }
}

class CollectionViewProvider: CollectionViewDataSource, CollectionViewDelegate {
    @Published var items: [SomeItem] = []

    init() {
        items = (0...20).map {
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
            Divider()
            CollectionView(
                layout: HorizontalCollectionViewLayout(),
                delegate: provider,
                dataSource: provider
            )
            Divider()
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}
