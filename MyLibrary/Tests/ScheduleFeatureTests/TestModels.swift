import Foundation
import SharedModels

extension Conference {
  static let day1Sample = conference(id: 1, title: "Day 1", date: .march(22))
  static let day2Sample = conference(id: 2, title: "Day 2", date: .march(23))
  static let workshopSample = conference(id: 3, title: "Day 3", date: .march(24))

  static func conference(id: Int, title: String, date: Date) -> Self {
    Conference(id: id, title: title, date: date, schedules: .havingOneSession(at: date))
  }
}

extension Date {
  static func march(_ day: Int) -> Self {
    ISO8601DateFormatter().date(from: "2024-03-" + String(format:"%02d", day) + "T09:00:00+09:00")!
  }
}

extension [SharedModels.Schedule] {
  static func havingOneSession(at date: Date) -> Self {
    [Schedule(time: Date.now, sessions: [.sessionWithDetailInfo])]
  }
}

extension Session {
  static let sessionWithDetailInfo = Session(
    title: "sessionTitle",
    speakers: [.sampleSpeaker],
    place: "sessionPlace",
    description: "sessionDescription",
    requirements: "sessionRequirements"
  )

  static let sessionWithoutDetailInfo = Session(
    title: "sessionTitle",
    speakers: nil,
    place: nil,
    description: nil,
    requirements: nil)
}

extension Speaker {
  static let sampleSpeaker = Speaker(
    name: "speakerName",
    imageName: "imageName",
    bio: "bio",
    links: [Speaker.Link(name: "speakerLinkName", url: URL(string: "http://example.com")!)]
  )
}
