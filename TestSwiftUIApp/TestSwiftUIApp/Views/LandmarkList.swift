//
//  LandmarkList.swift
//  TestSwiftUIApp
//
//  Created by Gleb Radchenko on 24.11.20.
//

import SwiftUI

struct LandmarkList: View {
    @EnvironmentObject var userData: UserData

    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $userData.showFavoritesOnly) {
                    Text("Favorites only")
                }

                ForEach(userData.landmarks) { landmark in
                    if !userData.showFavoritesOnly || landmark.isFavorite {
                        NavigationLink(
                            destination: LandmarkDetail(landmark: landmark)
                        ) {
                            LandmarkRow(landmark: landmark)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Landmarks"))
        }
    }
}

struct LandmarkList_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkList()
            .environmentObject(UserData())
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 mini"))
    }
}
