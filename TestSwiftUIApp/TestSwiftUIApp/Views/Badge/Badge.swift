//
//  Badge.swift
//  TestSwiftUIApp
//
//  Created by Gleb Radchenko on 29.11.20.
//

import SwiftUI

struct Badge: View {
    var rotationCount = 7

    var badgeSymbols: some View {
        ForEach(0..<rotationCount) { i in
            RotatedBadgeSymbol(
                angle: .degrees(Double(i) / Double(rotationCount)) * 360.0
            )
        }
        .opacity(0.5)
    }

    var body: some View {
        ZStack {
            BadgeBackground()

            GeometryReader { geometry in
                badgeSymbols
                    .scaleEffect(1 / 4, anchor: .top)
                    .position(
                        x: geometry.size.width / 2.0,
                        y: (3 / 4) * geometry.size.height
                    )
            }
        }
        .scaledToFit()
    }
}

struct Badge_Previews: PreviewProvider {
    static var previews: some View {
        Badge()
    }
}
