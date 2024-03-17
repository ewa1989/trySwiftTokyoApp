import XCTest
import ComposableArchitecture

@testable import trySwiftFeature

final class trySwiftTests: XCTestCase {

  @MainActor
  func test_view_organizerTapped_presentOrganizers() async {
    let store = TestStore(initialState: TrySwift.State()) {
      TrySwift()
    }

    await store.send(.view(.organizerTapped)) {
      $0.path.append(.organizers(.init()))
    }
  }
}
