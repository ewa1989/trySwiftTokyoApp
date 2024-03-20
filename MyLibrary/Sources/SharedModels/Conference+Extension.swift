extension [Schedule] {
  public func filtered(using favorites: Favorites, in conference: Conference) -> Self {
    self
      .map { Schedule(time: $0.time, sessions: $0.sessions.filter { favorites.isFavorited($0, in: conference) }) }
      .filter { $0.sessions.count > 0 }
  }
}
