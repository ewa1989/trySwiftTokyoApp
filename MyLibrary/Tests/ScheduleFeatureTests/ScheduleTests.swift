import XCTest
import ComposableArchitecture

@testable import ScheduleFeature

import DataClient
import SharedModels

final class ScheduleTests: XCTestCase {

  @MainActor
  func test_view_onAppear_fetchThreeDaySchedule() async {
    let store = TestStore(initialState: Schedule.State()) {
      Schedule()
    } withDependencies: {
      $0[DataClient.self].fetchDay1 = { @Sendable in .day1Sample }
      $0[DataClient.self].fetchDay2 = { @Sendable in .day2Sample }
      $0[DataClient.self].fetchWorkshop = { @Sendable in .workshopSample }
    }

    await store.send(.view(.onAppear)) {
      $0.day1 = .day1Sample
      $0.day2 = .day2Sample
      $0.workshop = .workshopSample
    }
  }

  @MainActor
  func test_view_mapItemTapped_onIOSAndMacOS_presentGuidance() async throws {
    #if os(visionOS)
      throw XCTSkip("this test is for iOS and macOS")
    #endif

    let store = TestStore(initialState: Schedule.State()) {
      Schedule()
    }

    await store.send(.view(.mapItemTapped)) {
      $0.destination = .guidance(.init(url: URL(string: "https://twitter.com/tryswiftconf/status/1108474796788977664")!))
    }
  }

  @MainActor
  func test_view_mapItemTapped_onVisionOS_presentGuidance() async throws {
    #if os(iOS) || os(macOS)
      throw XCTSkip("this test is for visionOS")
    #endif

    let clock = TestClock()
    let store = TestStore(initialState: Schedule.State()) {
      Schedule()
    } withDependencies: {
      $0.openURL = OpenURLEffect {
        XCTAssertEqual($0, URL(string: "https://twitter.com/tryswiftconf/status/1108474796788977664"))
        return true
      }
      $0.continuousClock = clock
    }

    await store.send(.view(.mapItemTapped))

    // ensure to finish running all side effects
    await clock.advance(by: .seconds(1))
  }

  @MainActor
  func test_view_disclosureTapped_sessionWithDetailInfo_presentDetail() async {
    let store = TestStore(initialState: Schedule.State()) {
      Schedule()
    }

    let session: Session = .sessionWithDetailInfo
    await store.send(.view(.disclosureTapped(session))) {
      $0.path.append(.detail(ScheduleDetail.State(title: session.title,
                                                  description: session.description!,
                                                  requirements: session.requirements!,
                                                  speakers: session.speakers!)))
    }
  }

  @MainActor
  func test_view_disclosureTapped_sessionWithoutDetailInfo_doNothing() async {
    let store = TestStore(initialState: Schedule.State()) {
      Schedule()
    }

    await store.send(.view(.disclosureTapped(.sessionWithoutDetailInfo)))
  }
}
