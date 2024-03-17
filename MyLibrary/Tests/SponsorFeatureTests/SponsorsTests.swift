import XCTest
import ComposableArchitecture

@testable import SponsorFeature

import DataClient

final class SponsorsTests: XCTestCase {

  @MainActor
  func test_view_onAppear_fetchSponsors() async {
    let store = TestStore(initialState: SponsorsList.State()) {
      SponsorsList()
    } withDependencies: {
      $0[DataClient.self].fetchSponsors = { @Sendable in .sponsorsSample }
    }

    await store.send(.view(.onAppear)) {
      $0.sponsors = .sponsorsSample
    }
  }
}
