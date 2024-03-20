import ComposableArchitecture
import XCTest

@testable import SharedModels

final class ConferenceTests: XCTestCase {
  @MainActor
  func testSchedulesFiltered() {
    let schedulesWith2Sessions = [Schedule(time: Date(timeIntervalSince1970: 10_000), sessions: [.mock1, .mock2])]
    let conference = Conference(id: 1, title: "conference", date: Date(timeIntervalSince1970: 1_000), schedules: schedulesWith2Sessions)
    let favoritesMock1Only = Favorites(eachConferenceFavorites: [(conference, [.mock1])])

    let actual = schedulesWith2Sessions.filtered(using: favoritesMock1Only, in: conference)

    let schedulesMock1Only = [Schedule(time: Date(timeIntervalSince1970: 10_000), sessions: [.mock1])]
    XCTAssertEqual(actual, schedulesMock1Only)
  }
}
