import XCTest
import ComposableArchitecture

@testable import trySwiftFeature

import DataClient
import SharedModels

final class OrganizersTests: XCTestCase {

  @MainActor
  func test_view_onAppear_fetchOrganizers() async {
    let organizers: [Organizer] = .organizersSample
    let store = TestStore(initialState: Organizers.State()) {
      Organizers()
    } withDependencies: {
      $0[DataClient.self].fetchOrganizers = { @Sendable in organizers }
    }

    await store.send(.view(.onAppear)) {
      $0.organizers.append(contentsOf: organizers)
    }
  }
}
