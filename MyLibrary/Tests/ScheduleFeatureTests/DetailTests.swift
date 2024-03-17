import XCTest
import ComposableArchitecture

@testable import ScheduleFeature

import SharedModels

final class DetailTests: XCTestCase {

  @MainActor
  func test_view_snsTapped_onIOSAndMacOS_presentSafari() async throws {
    #if os(visionOS)
      throw XCTSkip("this test is for iOS and macOS")
    #endif

    let session: Session = .sessionWithDetailInfo
    let store = TestStore(initialState: ScheduleDetail.State(title: session.title,
                                                             description: session.description!,
                                                             speakers: session.speakers!)) {
      ScheduleDetail()
    }
    
    let url = session.speakers!.first!.links!.first!.url
    await store.send(.view(.snsTapped(url))) {
      $0.destination = .safari(.init(url: url))
    }
  }
}
