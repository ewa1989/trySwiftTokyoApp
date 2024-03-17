import SharedModels
import Foundation

extension [Organizer] {
  static let organizersSample = [
    Organizer(id: 1, name: "name", imageName: "imageName", bio: "bio", links: [.linkSample])
  ]
}

extension Organizer.Link {
  static let linkSample = Organizer.Link(name: "name", url: URL(string: "http://example.com")!)
}
