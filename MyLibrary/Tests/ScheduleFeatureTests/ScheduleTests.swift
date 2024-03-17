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
  func test_view_mapItemTapped_presentGuidance() async {
    let store = TestStore(initialState: Schedule.State()) {
      Schedule()
    }

    await store.send(.view(.mapItemTapped)) {
      $0.destination = .guidance(.init(url: URL(string: "https://twitter.com/tryswiftconf/status/1108474796788977664")!))
    }
  }
}

private extension Conference {
  static let day1Sample = conference(id: 1, title: "Day 1", date: .march(22))
  static let day2Sample = conference(id: 2, title: "Day 2", date: .march(23))
  static let workshopSample = conference(id: 3, title: "Day 3", date: .march(24))

  static func conference(id: Int, title: String, date: Date) -> Self {
    Conference(id: id, title: title, date: date, schedules: .havingOneSession(at: date))
  }
}

private extension Date {
  static func march(_ day: Int) -> Self {
    ISO8601DateFormatter().date(from: "2024-03-" + String(format:"%02d", day) + "T09:00:00+09:00")!
  }
}

private extension [SharedModels.Schedule] {
  static func havingOneSession(at date: Date) -> Self {
    [Schedule(time: Date.now, sessions: [.sampleSession])]
  }
}

private extension Session {
  static let sampleSession = Session(
    title: "sessionTitle",
    speakers: [.sampleSpeaker],
    place: "sessionPlace",
    description: "sessionDescription",
    requirements: "sessionRequirements"
  )
}

private extension Speaker {
  static let sampleSpeaker = Speaker(
    name: "speakerName",
    imageName: "imageName",
    bio: "bio",
    links: [Speaker.Link(name: "speakerLinkName", url: URL(string: "http://example.com")!)]
  )
}
