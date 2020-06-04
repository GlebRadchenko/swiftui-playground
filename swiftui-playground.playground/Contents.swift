import SwiftUI
import PlaygroundSupport
import Combine

protocol CollectionViewLayout {
    associatedtype ID: Hashable
    associatedtype Modifier: ViewModifier

    func viewModifier(elementID: ID, using geometry: GeometryProxy) -> Modifier
}

class HorizontalCollectionViewLayout<ContentViewA: View>: CollectionViewLayout {
    typealias ID = String
    typealias Modifier = HorizontalViewModifier

    private var xPosition: CGFloat = 0
    private var yPosition: CGFloat = 0

    func viewModifier(elementID: String, using geometry: GeometryProxy) -> Modifier {
        HorizontalViewModifier(x: xPosition, y: yPosition, geometry: geometry) { newX, newY in
            print(newX, newY)
            self.xPosition = max(newX, self.xPosition)
            self.yPosition = max(newY, self.yPosition)
        }
    }

    struct HorizontalViewModifier: ViewModifier {
        let x: CGFloat
        let y: CGFloat
        let geometry: GeometryProxy
        let onPositionChange: (_ x: CGFloat, _ y: CGFloat) -> Void

        func body(content: Content) -> some View {
            content
                .background(Color.green)
                //.frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: 100)
                .alignmentGuide(.leading, computeValue: leadingAlignmentGuide(dimensions:))
                .alignmentGuide(.top, computeValue: topAlignmentGuide(dimensions:))
        }

        // MARK: - Private
        private func leadingAlignmentGuide(dimensions: ViewDimensions) -> CGFloat {
            print("leading")
            var newX = x
            var newY = y

            if x + dimensions.width < geometry.size.width {
                newX = 0
                newY += dimensions.height
            } else {
                newX += dimensions.width
            }

            onPositionChange(newX, newY)

            return newX
        }

        private func topAlignmentGuide(dimensions: ViewDimensions) -> CGFloat {
            print("top")
            onPositionChange(x, y + dimensions.height)
            return y + dimensions.height
        }
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
            ZStack {
                ForEach(dataSource.items) { item in
                    delegate.view(for: item)
                        .modifier(layout.viewModifier(elementID: item.id, using: geometry))
                        .alignmentGuide(.leading, computeValue: { dimensions in
                            print("here")
                            return 111
                        })
                }
            }
            .border(Color.red, width: 2)
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
    var items: [SomeItem] = [.init(id: "1"), .init(id: "2"), .init(id: "3"), .init(id: "4")]

    func view(for item: SomeItem) -> some View {
        Text(item.id).frame(width: 50, height: 200)
    }
}

struct ContentView: View {
    let provider = CollectionViewProvider()

    var body: some View {
        HStack {
            CollectionView(
                layout: HorizontalCollectionViewLayout<Text>(),
                delegate: provider,
                dataSource: provider
            ).border(Color.green, width: 1)
        }
    }
}


PlaygroundPage.current.setLiveView(ContentView())
PlaygroundPage.current.needsIndefiniteExecution = true
