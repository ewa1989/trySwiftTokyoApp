import XCTest
import ComposableArchitecture

@testable import SponsorFeature

import DataClient
import SharedModels

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

  @MainActor
  func test_view_sponsorTapped_sponsorWithLink_onIOSAndMacOS_presentDestination() async throws {
    #if os(visionOS)
      throw XCTSkip("this test is for iOS and macOS")
    #endif

    let store = TestStore(initialState: SponsorsList.State()) {
      SponsorsList()
    }

    let sponsorWithLink: Sponsor = .sponsorWithLink(id: 1, name: "sponsorWithLink")
    await store.send(.view(.sponsorTapped(sponsorWithLink))) {
      $0.destination = .safari(.init(url: sponsorWithLink.link!))
    }
  }

  @MainActor
  func test_view_sponsorTapped_sponsorWithoutLink_onIOSAndMacOS_doNothing() async throws {
    #if os(visionOS)
      throw XCTSkip("this test is for iOS and macOS")
    #endif

    let store = TestStore(initialState: SponsorsList.State()) {
      SponsorsList()
    }

    let sponsorWithoutLink: Sponsor = .sponsorWithoutLink(id: 1, name: "sponsorWithoutLink")
    await store.send(.view(.sponsorTapped(sponsorWithoutLink)))
  }
}
