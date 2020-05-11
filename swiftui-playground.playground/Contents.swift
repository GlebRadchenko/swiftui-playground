import SwiftUI
import PlaygroundSupport
import Combine
import MapKit

struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(
            latitude: 34.011286,
            longitude: -116.166868
        )
        let span = MKCoordinateSpan(
            latitudeDelta: 2.0,
            longitudeDelta: 2.0
        )
        let region = MKCoordinateRegion(
            center: coordinate,
            span: span
        )
        uiView.setRegion(region, animated: true)
    }
}

struct CircleImage: View {
    var body: some View {
        Color.blue
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(radius: 10)

    }
}

struct ContentView: View {
    public var body: some View {
        VStack {
            MapView()
                .edgesIgnoringSafeArea(.top)
                .frame(height: 300)
            CircleImage()
                .offset(y: -130)
                .padding(.bottom, -130)
            VStack(alignment: .leading) {
                Text("Header")
                    .font(.title)
                HStack(alignment: .top) {
                    Text("Some Text")
                        .font(.subheadline)
                    Spacer()
                    Text("Some other")
                        .font(.subheadline)
                }
            }
            .padding()
            Spacer()
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())
PlaygroundPage.current.needsIndefiniteExecution = true
