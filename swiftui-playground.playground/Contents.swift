import SwiftUI
import PlaygroundSupport
import Combine

// First method - with wrapper, allows to inject VM

protocol ContentViewModelProtocol {
    var tapsCount: AnyPublisher<Int, Never> { get }
    func handleButtonTap()
    func handleTextChanged(_ text: String)
}

class ContentViewModel: ContentViewModelProtocol {
    private let tapsCountSubject = CurrentValueSubject<Int, Never>(0)
    lazy var tapsCount: AnyPublisher<Int, Never> = tapsCountSubject.eraseToAnyPublisher()

    func handleButtonTap() {
        tapsCountSubject.send(tapsCountSubject.value + 1)
    }

    func handleTextChanged(_ text: String) {
        tapsCountSubject.send(111)
    }
}

class SwiftUIViewModelWrapperBase<ViewModel> {
    let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

protocol SomeProtocol {
    var text2: String { get }

    func handleButtonTap()
    func handleTextChanged(_ text: String)
}

protocol IsLoadingable {
    var isLoading: Bool { get }
}

class WrapperViewModel: SwiftUIViewModelWrapperBase<ContentViewModelProtocol>, SomeProtocol, IsLoadingable, ObservableObject {
    @Published var isLoading: Bool = false
    @Published var text2: String = ""
    private var subscriptions: Set<AnyCancellable> = []

    override init(viewModel: ContentViewModelProtocol) {
        super.init(viewModel: viewModel)
        viewModel.tapsCount
            .map { "Taps: \($0)" }
            .receive(on: DispatchQueue.main)
            .assign(to: \.text2, on: self)
            .store(in: &subscriptions)
    }

    func handleButtonTap() {
        viewModel.handleButtonTap()
    }

    func handleTextChanged(_ text: String) {
        viewModel.handleTextChanged(text)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: WrapperViewModel

    var body: some View {
        VStack {
            Text(viewModel.text2)
            Button("Button") {
                self.viewModel.handleButtonTap()
            }
            Form {
                TextField(
                    "Textfield",
                    text: .init(get: { self.viewModel.text2 }, set: { self.viewModel.handleTextChanged($0) }),
                    onEditingChanged: { print("Editing changed: \($0)") },
                    onCommit: { print("commit") }
                )
            }
        }.onTapGesture {
            UIApplication.shared.keyWindow?.endEditing(true)
        }
    }
}

let viewModel = ContentViewModel()
let wrapper = WrapperViewModel(viewModel: viewModel)
let view = ContentView(viewModel: wrapper)

//####################################################################################################################
// no wrapper, can't inject but view model can be SwiftUI agnostic

protocol AnotherViewModelProtocol {
    var text: String { get }
    func handleTap()
}

class AnotherViewModel: AnotherViewModelProtocol, ObservableObject {
    @Published var text: String = "test"
    var tapsCount = 0 { didSet { text = "\(tapsCount)" } }
    func handleTap() { tapsCount += 1 }
}

class AnotherViewModelMock: AnotherViewModelProtocol, ObservableObject {
    var text = ""
    func handleTap() {}
}

struct AnotherView<ViewModel: AnotherViewModelProtocol & ObservableObject>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            Text(viewModel.text)
            Button(action: { self.viewModel.handleTap() }) {
                Text("Button")
            }
        }
    }
}

// this is the most important part here
func createAnotherViewModel() -> some AnotherViewModelProtocol & ObservableObject {
    return AnotherViewModel()
    //return AnotherViewModelMock()
}

let anotherView = AnotherView(viewModel: createAnotherViewModel())

PlaygroundPage.current.setLiveView(anotherView)
PlaygroundPage.current.needsIndefiniteExecution = true

var a: Float = 293.64999999999998
print((a * 100) / 100)
