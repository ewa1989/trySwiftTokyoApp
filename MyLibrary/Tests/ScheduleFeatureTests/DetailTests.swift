import XCTest
import ComposableArchitecture

@testable import ScheduleFeature

import SharedModels

final class DetailTests: XCTestCase {

  @MainActor
  func test_justCreateTestStore() async {
    let session: Session = .sessionWithDetailInfo
    let store = TestStore(initialState: ScheduleDetail.State(title: session.title,
                                                             description: session.description!,
                                                             speakers: session.speakers!)) {
      ScheduleDetail()
    }

    XCTAssertNotNil(store)
  }
}
