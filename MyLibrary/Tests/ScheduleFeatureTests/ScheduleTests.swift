import ComposableArchitecture
import DataClient
import FileClient
import SharedModels
import XCTest

@testable import ScheduleFeature

final class ScheduleTests: XCTestCase {
  @MainActor
  func testOnAppear() async {
    let store = TestStore(initialState: Schedule.State()) {
      Schedule()
    } withDependencies: {
      $0[DataClient.self].fetchDay1 = { @Sendable in .mock1 }
      $0[DataClient.self].fetchDay2 = { @Sendable in .mock2 }
      $0[DataClient.self].fetchWorkshop = { @Sendable in .mock3 }
      $0[FileClient.self].loadFavorites = { @Sendable in .mock1 }
    }
    await store.send(.view(.onAppear))
    await store.receive(\.fetchResponse.success) {
      $0.day1 = .mock1
      $0.day2 = .mock2
      $0.workshop = .mock3
    }
    await store.receive(\.loadResponse.success) {
      $0.favorites = .mock1
    }
  }

  @MainActor
  func testFetchDataFailure() async {
    struct FetchError: Equatable, Error {}
    let store = TestStore(initialState: Schedule.State()) {
      Schedule()
    } withDependencies: {
      $0[DataClient.self].fetchDay1 = { @Sendable in throw FetchError() }
      $0[DataClient.self].fetchDay2 = { @Sendable in .mock2 }
      $0[DataClient.self].fetchWorkshop = { @Sendable in .mock3 }
      $0[FileClient.self].loadFavorites = { @Sendable in .mock1}
    }
    await store.send(.view(.onAppear))
    await store.receive(\.fetchResponse.failure)
    await store.receive(\.loadResponse) {
      $0.favorites = .mock1
    }
  }

  @MainActor
  func testLoadFavoritesFailure() async {
    struct LoadError: Equatable, Error {}
    let store = TestStore(initialState: Schedule.State()) {
      Schedule()
    } withDependencies: {
      $0[DataClient.self].fetchDay1 = { @Sendable in .mock1 }
      $0[DataClient.self].fetchDay2 = { @Sendable in .mock2 }
      $0[DataClient.self].fetchWorkshop = { @Sendable in .mock3 }
      $0[FileClient.self].loadFavorites = { @Sendable in throw LoadError() }
    }
    await store.send(.view(.onAppear))
    await store.receive(\.fetchResponse.success) {
      $0.day1 = .mock1
      $0.day2 = .mock2
      $0.workshop = .mock3
    }
    await store.receive(\.loadResponse.failure)
  }

  @MainActor
  func testAddingFavorites() async {
    let initialState: ScheduleFeature.Schedule.State = ScheduleTests.selectingDay1ScheduleWithNoFavorites
    let firstSession = initialState.day1!.schedules.first!.sessions.first!
    let firstSessionFavorited = [initialState.day1!.title: [firstSession]]
    let store = TestStore(initialState: initialState) {
      Schedule()
    } withDependencies: {
      $0[FileClient.self].saveFavorites = { @Sendable in XCTAssertEqual($0, firstSessionFavorited) }
    }

    await store.send(.view(.favoriteIconTapped(firstSession)))
    await store.receive(\.savedFavorites) {
      $0.favorites = firstSessionFavorited
    }
  }

  @MainActor
  func testRemovingFavorites() async {
    let initialState: ScheduleFeature.Schedule.State = ScheduleTests.selectingDay1ScheduleWithOneFavorite
    let firstSession = initialState.day1!.schedules.first!.sessions.first!
    let noFavorites: Favorites = [initialState.day1!.title: []]
    let store = TestStore(initialState: initialState) {
      Schedule()
    } withDependencies: {
      $0[FileClient.self].saveFavorites = { @Sendable in XCTAssertEqual($0, noFavorites) }
    }

    await store.send(.view(.favoriteIconTapped(firstSession)))
    await store.receive(\.savedFavorites) {
      $0.favorites = noFavorites
    }
  }

  @MainActor
  func testSyncFavoritesWithDetailView() async {
    let initialState: ScheduleFeature.Schedule.State = ScheduleTests.selectingDay1ScheduleWithNoFavorites
    let lastSession = initialState.day1!.schedules.first!.sessions.last!
    let lastSessionFavorited: Favorites = [initialState.day1!.title: [lastSession]]
    let store = TestStore(initialState: initialState) {
      Schedule()
    } withDependencies: {
      $0[FileClient.self].saveFavorites = { @Sendable in XCTAssertEqual($0, lastSessionFavorited) }
    }
    store.exhaustivity = .off

    await store.send(.view(.disclosureTapped(lastSession)))
    await store.send(.path(.element(id: 0, action: .detail(.delegate(.updateFavoriteState(lastSession))))))
    await store.skipReceivedActions()
    store.assert {
      $0.favorites = lastSessionFavorited
    }
  }

  static let selectingDay1ScheduleWithNoFavorites = {
    var initialState = Schedule.State()
    initialState.selectedDay = .day1
    initialState.day1 = .mock1
    return initialState
  }()

  static let selectingDay1ScheduleWithOneFavorite = {
    var initialState = Schedule.State()
    initialState.selectedDay = .day1
    initialState.day1 = .mock1
    let firstSession = initialState.day1!.schedules.first!.sessions.first!
    initialState.favorites = [initialState.day1!.title: [firstSession]]
    return initialState
  }()

  @MainActor
  func testSchedulesFilteredFavoritesOnly() async {
    let initialState: ScheduleFeature.Schedule.State = ScheduleTests.selectingDay1ScheduleWithOneFavorite
    let store = TestStore(initialState: initialState) {
      Schedule()
    }
    let schedulesMock1Only = [Schedule(time: Date(timeIntervalSince1970: 10_000), sessions: [.mock1])]
    let expected = Conference(
      id: 1,
      title: "conference1",
      date: Date(timeIntervalSince1970: 1_000),
      schedules: schedulesMock1Only
    )

    await store.send(.binding(.set(\.selectedFilter, Schedule.FilterItem.favorite))) {
      $0.selectedFilter = .favorite
      XCTAssertEqual($0.day1ToShow, expected)
    }
  }
}
