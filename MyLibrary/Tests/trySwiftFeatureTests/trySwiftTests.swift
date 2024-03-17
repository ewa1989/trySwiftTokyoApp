import XCTest
import ComposableArchitecture

@testable import trySwiftFeature

final class trySwiftTests: XCTestCase {

  @MainActor
  func test_view_organizerTapped_presentOrganizers() async {
    let store = TestStore(initialState: TrySwift.State()) {
      TrySwift()
    }

    await store.send(.view(.organizerTapped)) {
      $0.path.append(.organizers(.init()))
    }
  }

  @MainActor
  func test_view_codeOfConductTapped_onIOSAndMacOS_presentSafari() async throws {
    #if os(visionOS)
      throw XCTSkip("this test is for iOS and macOS")
    #endif

    let store = TestStore(initialState: TrySwift.State()) {
      TrySwift()
    }

    await store.send(.view(.codeOfConductTapped)) {
      $0.destination = .safari(.init(url: URL(string: "https://tryswift.jp/code-of-conduct")!))
    }
  }

  @MainActor
  func test_view_codeOfConductTapped_onVisionOS_openURL() async throws {
    #if os(iOS) || os(macOS)
      throw XCTSkip("this test is for visionOS")
    #endif

    let clock = TestClock()
    let store = TestStore(initialState: TrySwift.State()) {
      TrySwift()
    } withDependencies: {
      $0.openURL = OpenURLEffect {
        XCTAssertEqual($0, URL(string: "https://tryswift.jp/code-of-conduct"))
        return true
      }
      $0.continuousClock = clock
    }

    await store.send(.view(.codeOfConductTapped))

    // ensure to finish running all side effects
    await clock.advance(by: .seconds(1))
  }

  @MainActor
  func test_view_privacyPolicyTapped_onIOSAndMacOS_presentSafari() async throws {
    #if os(visionOS)
      throw XCTSkip("this test is for iOS and macOS")
    #endif

    let store = TestStore(initialState: TrySwift.State()) {
      TrySwift()
    }

    await store.send(.view(.privacyPolicyTapped)) {
      $0.destination = .safari(.init(url: URL(string: "https://tryswift.jp/privacy-policy")!))
    }
  }

  @MainActor
  func test_view_privacyPolicyTapped_onVisionOS_openURL() async throws {
    #if os(iOS) || os(macOS)
      throw XCTSkip("this test is for visionOS")
    #endif

    let clock = TestClock()
    let store = TestStore(initialState: TrySwift.State()) {
      TrySwift()
    } withDependencies: {
      $0.openURL = OpenURLEffect {
        XCTAssertEqual($0, URL(string: "https://tryswift.jp/privacy-policy"))
        return true
      }
      $0.continuousClock = clock
    }

    await store.send(.view(.privacyPolicyTapped))

    // ensure to finish running all side effects
    await clock.advance(by: .seconds(1))
  }

  @MainActor
  func test_view_acknowledgementsTapped_presentOrganizers() async {
    let store = TestStore(initialState: TrySwift.State()) {
      TrySwift()
    }

    await store.send(.view(.acknowledgementsTapped)) {
      $0.path.append(.acknowledgements(.init()))
    }
  }

  @MainActor
  func test_view_eventbriteTapped_onIOSAndMacOS_presentSafari() async throws {
    #if os(visionOS)
      throw XCTSkip("this test is for iOS and macOS")
    #endif

    let store = TestStore(initialState: TrySwift.State()) {
      TrySwift()
    }

    await store.send(.view(.eventbriteTapped)) {
      $0.destination = .safari(.init(url: URL(string: "https://www.eventbrite.com/e/try-swift-tokyo-2024-tickets-712565200697")!))
    }
  }

  @MainActor
  func test_view_eventbriteTapped_onVisionOS_openURL() async throws {
    #if os(iOS) || os(macOS)
      throw XCTSkip("this test is for visionOS")
    #endif

    let clock = TestClock()
    let store = TestStore(initialState: TrySwift.State()) {
      TrySwift()
    } withDependencies: {
      $0.openURL = OpenURLEffect {
        XCTAssertEqual($0, URL(string: "https://www.eventbrite.com/e/try-swift-tokyo-2024-tickets-712565200697"))
        return true
      }
      $0.continuousClock = clock
    }

    await store.send(.view(.eventbriteTapped))

    // ensure to finish running all side effects
    await clock.advance(by: .seconds(1))
  }
}
