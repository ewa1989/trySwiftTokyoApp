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

  @MainActor
  func test_view_snsTapped_onVisionOS_openURL() async throws {
    #if os(iOS) || os(macOS)
      throw XCTSkip("this test is for visionOS")
    #endif

    let session: Session = .sessionWithDetailInfo
    let url = session.speakers!.first!.links!.first!.url

    let clock = TestClock()
    let store = TestStore(initialState: ScheduleDetail.State(title: session.title,
                                                             description: session.description!,
                                                             speakers: session.speakers!)) {
      ScheduleDetail()
    } withDependencies: {
      $0.openURL = OpenURLEffect {
        XCTAssertEqual($0, url)
        return true
      }
      $0.continuousClock = clock
    }

    await store.send(.view(.snsTapped(url)))

    // ensure to finish running all side effects
    await clock.advance(by: .seconds(1))
  }
}
