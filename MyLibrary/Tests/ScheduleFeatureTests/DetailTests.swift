import ComposableArchitecture
import XCTest

@testable import ScheduleFeature

final class DetailTests: XCTestCase {
  @MainActor
  func testFavorite() async {
    let store = TestStore(initialState: ScheduleDetail.State(session: .mock1, isFavorited: false)) {
      ScheduleDetail()
    }

    await store.send(.view(.favoriteIconTapped)) {
      $0.isFavorited = true
    }
    await store.receive(\.delegate)
  }
}
