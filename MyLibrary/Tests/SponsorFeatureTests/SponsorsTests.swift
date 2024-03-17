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

  @MainActor
  func test_view_sponsorTapped_sponsorWithLink_onVisionOS_openURL() async throws {
    #if os(iOS) || os(macOS)
      throw XCTSkip("this test is for visionOS")
    #endif

    let sponsorWithLink: Sponsor = .sponsorWithLink(id: 1, name: "sponsorWithLink")

    let clock = TestClock()
    let store = TestStore(initialState: SponsorsList.State()) {
      SponsorsList()
    } withDependencies: {
      $0.openURL = OpenURLEffect {
        XCTAssertEqual($0, sponsorWithLink.link)
        return true
      }
      $0.continuousClock = clock
    }

    await store.send(.view(.sponsorTapped(sponsorWithLink)))

    // ensure to finish running all side effects
    await clock.advance(by: .seconds(1))
  }

  @MainActor
  func test_view_sponsorTapped_sponsorWithoutLink_onVisionOS_doNothing() async throws {
    #if os(iOS) || os(macOS)
      throw XCTSkip("this test is for visionOS")
    #endif

    let clock = TestClock()
    let store = TestStore(initialState: SponsorsList.State()) {
      SponsorsList()
    }

    await store.send(.view(.sponsorTapped(.sponsorWithoutLink(id: 1, name: "sponsorWithoutLink"))))
  }
}
