import SwiftUI

@Observable
final class AppState {
    var selectedLane: Lane = .ideas
    var draft: String = ""
}
