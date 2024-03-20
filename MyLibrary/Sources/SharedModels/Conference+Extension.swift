extension [Schedule] {
  public func filtered(using favorites: Favorites, in day: Conference) -> Self {
    self
      .map { Schedule(time: $0.time, sessions: $0.sessions.filter { favorites.isFavorited($0, in: day) }) }
      .filter { $0.sessions.count > 0 }
  }
}
