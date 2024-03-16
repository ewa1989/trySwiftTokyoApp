import XCTest
import ComposableArchitecture

@testable import ScheduleFeature

import DataClient
import SharedModels

final class ScheduleTests: XCTestCase {

  @MainActor
  func test_justCreateStore() async {
    let store = TestStore(initialState: Schedule.State()) {
      Schedule()
    }
    XCTAssertNotNil(store)
  }
}
