import Foundation
import SharedModels

extension Sponsors {
  static let sponsorsSample = Sponsors(
    platinum: .platinumSponsorsSample,
    gold: .goldSponsorsSample,
    silver: .silverSponsorsSample,
    bronze: .bronzeSponsorsSample,
    diversity: .diversitySponsorsSample,
    student: .studentSponsorsSample,
    community: .communitySponsorsSample,
    individual: .individualSponsorsSample
  )
}

extension [Sponsor] {
  static let platinumSponsorsSample: Self = [.sponsorWithLink(id: 1, name: "platinumSponsor")]
  static let goldSponsorsSample: Self = [.sponsorWithLink(id: 2, name: "goldSponsor")]
  static let silverSponsorsSample: Self = [.sponsorWithLink(id: 3, name: "silverSponsor")]
  static let bronzeSponsorsSample: Self = [.sponsorWithLink(id: 4, name: "bronzeSponsor")]
  static let diversitySponsorsSample: Self = [.sponsorWithLink(id: 5, name: "diversitySponsor")]
  static let studentSponsorsSample: Self = [.sponsorWithLink(id: 6, name: "studentSponsor")]
  static let communitySponsorsSample: Self = [.sponsorWithLink(id: 7, name: "communitySponsor")]
  static let individualSponsorsSample: Self = [.sponsorWithLink(id: 8, name: "individualSponsor")]
}

extension Sponsor {
  static func sponsorWithLink(id: Int, name: String) -> Self {
    Sponsor(id: id, name: name, imageName: "imageName", link: URL(string: "http://example.com")!)
  }
  static func sponsorWithoutLink(id: Int, name: String) -> Self {
    Sponsor(id: id, name: name, imageName: "imageName")
  }
}
