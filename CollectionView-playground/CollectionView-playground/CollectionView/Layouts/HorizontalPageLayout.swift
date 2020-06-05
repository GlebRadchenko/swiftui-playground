//
//  HorizontalPageLayout.swift
//  CollectionView-playground
//
//  Created by Gleb Radchenko on 04.06.20.
//  Copyright © 2020 Volkswagen AG. All rights reserved.
//

import SwiftUI

// just a prototype :)
class HorizontalPageLayout<UniqueID: Hashable>: CollectionViewLayout {
    typealias ID = UniqueID

    fileprivate var attributes: [ID: LayoutAttributes] = [:]
    fileprivate var lastAttributes: LayoutAttributes?

    var preferredScrollViewAxis: Axis.Set {
        .horizontal
    }

    func layout(content: AnyView, elementID: ID, geometry: GeometryProxy) -> some View {
        content
            .alignmentGuide(.leading) { dimensions in
                self.leadingAlignmentGuide(id: elementID, dimensions: dimensions, geometry: geometry)
            }
            .alignmentGuide(.top) { dimensions in
                self.topAlignmentGuide(id: elementID, dimensions: dimensions, geometry: geometry)
            }
    }

    func invalidate() {
        attributes.removeAll()
        lastAttributes = nil
    }

    // MARK: - Private
    fileprivate func leadingAlignmentGuide(id: ID, dimensions: ViewDimensions, geometry: GeometryProxy) -> CGFloat {
        if let layoutAttributes = attributes[id], layoutAttributes.geometrySize == geometry.size {
            lastAttributes = layoutAttributes
            return -layoutAttributes.x
        } else if attributes[id] != nil {
            invalidate()
        }

        var newAttributes = LayoutAttributes(
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

    fileprivate func topAlignmentGuide(id: ID, dimensions: ViewDimensions, geometry: GeometryProxy) -> CGFloat {
        -(attributes[id]?.y ?? 0)
    }

    // MARK: - Private
    func maxY(for page: Int) -> CGFloat? {
        attributes.values
            .filter { $0.page == page }
            .map { $0.y + $0.dimensions.height }
            .max()
    }

    struct LayoutAttributes {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var page: Int = 0
        let geometrySize: CGSize
        let dimensions: ViewDimensions
    }
}
