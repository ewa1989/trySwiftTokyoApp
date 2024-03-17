import XCTest
import ComposableArchitecture

@testable import SponsorFeature

final class SponsorsTests: XCTestCase {

  @MainActor
  func test_justCreateTestStore() async {
    let store = TestStore(initialState: SponsorsList.State()) {
      SponsorsList()
    }

    XCTAssertNotNil(store)
  }
}
