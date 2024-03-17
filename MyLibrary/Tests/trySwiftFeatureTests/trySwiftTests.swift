import XCTest
import ComposableArchitecture

@testable import trySwiftFeature

final class trySwiftTests: XCTestCase {

  @MainActor
  func test_justCreateTeststore() async {
    let store = TestStore(initialState: TrySwift.State()) {
      TrySwift()
    }

    XCTAssertNotNil(store)
  }
}
