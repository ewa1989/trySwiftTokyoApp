import ComposableArchitecture
import DataClient
import Foundation
import Safari
import SharedModels
import SwiftUI
import TipKit

@Reducer
public struct Schedule {
  enum Days: LocalizedStringKey, Equatable, CaseIterable, Identifiable {
    case day1 = "Day 1"
    case day2 = "Day 2"
    case day3 = "Day 3"

    var id: Self { self }
  }

  @ObservableState
  public struct State: Equatable {

    var path = StackState<Path.State>()
    var selectedDay: Days = .day1
    var searchText: String = ""
    var isSearchBarPresented: Bool = false
    var day1: Conference?
    var day2: Conference?
    var workshop: Conference?
    var favoritedOnlyFilterEnabled: Bool = false
    var selectedFilter: Action.FilterItem = .all
    @Presents var destination: Destination.State?

    public init() {
      try! Tips.configure([.displayFrequency(.immediate)])
    }
  }

  public enum Action: BindableAction, ViewAction {
    case binding(BindingAction<State>)
    case path(StackAction<Path.State, Path.Action>)
    case destination(PresentationAction<Destination.Action>)
    case view(View)

    public enum View {
      case onAppear
      case disclosureTapped(Session)
      case mapItemTapped
      case favoriteIconTapped(Session)
    }

    public enum FilterItem: String, CaseIterable {
      case all = "All"
      case favorite = "Favorite"
    }
  }

  @Reducer(state: .equatable)
  public enum Path {
    case detail(ScheduleDetail)
  }

  @Reducer(state: .equatable)
  public enum Destination {
    case guidance(Safari)
  }

  @Dependency(DataClient.self) var dataClient
  @Dependency(\.openURL) var openURL

  public init() {}

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .view(.onAppear):
        state.day1 = try! dataClient.fetchDay1()
        state.day2 = try! dataClient.fetchDay2()
        state.workshop = try! dataClient.fetchWorkshop()
        return .none
      case let .view(.disclosureTapped(session)):
        guard let description = session.description, let speakers = session.speakers else {
          return .none
        }
        state.path.append(
          .detail(
            .init(
              title: session.title,
              description: description,
              requirements: session.requirements,
              speakers: speakers
            )
          )
        )
        return .none
      case .view(.mapItemTapped):
        let url = URL(string: String(localized: "Guidance URL", bundle: .module))!
        #if os(iOS) || os(macOS)
          state.destination = .guidance(.init(url: url))
          return .none
        #elseif os(visionOS)
          return .run { _ in await openURL(url) }
        #endif
      case let .view(.favoriteIconTapped(session)):
        switch state.selectedDay {
        case .day1:
          state.day1 = update(state.day1!, togglingFavoriteOf: session)
        case .day2:
          state.day2 = update(state.day2!, togglingFavoriteOf: session)
        case .day3:
          state.workshop = update(state.workshop!, togglingFavoriteOf: session)
        }
        let day1 = state.day1!
        let day2 = state.day2!
        let workshop = state.workshop!
        return .run { _ in
          try? dataClient.saveDay1(day1)
          try? dataClient.saveDay2(day2)
          try? dataClient.saveWorkshop(workshop)
        }
      case .binding, .path, .destination:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
    .ifLet(\.$destination, action: \.destination)
  }

  private func update(_ conference: Conference, togglingFavoriteOf session: Session) -> Conference {
    var newValue = conference
    newValue.toggleFavorite(of: session)
    return newValue
  }
}

@ViewAction(for: Schedule.self)
public struct ScheduleView: View {

  @Bindable public var store: StoreOf<Schedule>

  let mapTip: MapTip = .init()

  public init(store: StoreOf<Schedule>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      root
    } destination: { store in
      switch store.state {
      case .detail:
        if let store = store.scope(state: \.detail, action: \.detail) {
          ScheduleDetailView(store: store)
        }
      }
    }
    .sheet(item: $store.scope(state: \.destination?.guidance, action: \.destination.guidance)) {
      sheetStore in
      SafariViewRepresentation(url: sheetStore.url)
        .ignoresSafeArea()
    }
  }

  @ViewBuilder
  var root: some View {
    ScrollView {
      Picker("Days", selection: $store.selectedDay) {
        ForEach(Schedule.Days.allCases) { day in
          Text(day.rawValue, bundle: .module)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal)
      switch store.selectedDay {
      case .day1:
        if let day1 = store.day1 {
          conferenceList(conference: day1)
        } else {
          Text("")
        }
      case .day2:
        if let day2 = store.day2 {
          conferenceList(conference: day2)
        } else {
          Text("")
        }
      case .day3:
        if let workshop = store.workshop {
          conferenceList(conference: workshop)
        } else {
          Text("")
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Image(systemName: "map")
          .onTapGesture {
            send(.mapItemTapped)
          }
          .popoverTip(mapTip)

      }

      ToolbarItem(placement: .topBarLeading) {
        Menu {
          Picker(String(localized: "Filter", bundle: .module), selection: $store.selectedFilter, content: {
            ForEach(Schedule.Action.FilterItem.allCases, id:\.self) { item in
              Text(String(localized: String.LocalizationValue(item.rawValue), bundle: .module))
                .tag(item)
            }
          })
        } label: {
          HStack {
            Image(systemName: "line.horizontal.3.decrease")
            Text(String(localized: "Filter", bundle: .module))
          }
        }
      }
    }
    .onAppear(perform: {
      send(.onAppear)
    })
    .navigationTitle(Text("Schedule", bundle: .module))
    .searchable(text: $store.searchText, isPresented: $store.isSearchBarPresented)
  }

  @ViewBuilder
  func conferenceList(conference: Conference) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(conference.date, style: .date)
        .font(.title2)

      let schedules = extractFilteredSchedules(from: conference)
      if schedules.count > 0 {
        ForEach(schedules, id: \.self) { schedule in
          VStack(alignment: .leading, spacing: 4) {
            Text(schedule.time, style: .time)
              .font(.subheadline.bold())
            ForEach(schedule.sessions, id: \.self) { session in
              if session.description != nil {
                Button {
                  send(.disclosureTapped(session))
                } label: {
                  listRow(session: session)
                    .padding()
                }
                .background(
                  Color(uiColor: .secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                )
              } else {
                listRow(session: session)
                  .padding()
                  .background(
                    Color(uiColor: .secondarySystemBackground)
                      .clipShape(RoundedRectangle(cornerRadius: 8))
                  )
              }
            }
          }
        }
      } else {
        noItemsToShowMessage()
      }
    }
    .padding()
  }

  @ViewBuilder
  func noItemsToShowMessage() -> some View {
    Text(String(localized: "No items to show.", bundle: .module))
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(
        Color(uiColor: .secondarySystemBackground)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      )
  }

  @ViewBuilder
  func listRow(session: Session) -> some View {
    HStack(spacing: 8) {
      VStack {
        if let speakers = session.speakers {
          ForEach(speakers, id: \.self) { speaker in
            Image(speaker.imageName, bundle: .module)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .clipShape(Circle())
              .background(
                Color(uiColor: .systemBackground)
                  .clipShape(Circle())
              )
              .frame(width: 60)
          }
        } else {
          Image(.tokyo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .frame(width: 60)
        }
      }
      VStack(alignment: .leading) {
        if session.title == "Office hour", let speakers = session.speakers {
          let title = officeHourTitle(speakers: speakers)
          Text(title)
            .font(.title3)
            .multilineTextAlignment(.leading)
        } else {
          Text(LocalizedStringKey(session.title), bundle: .module)
            .font(.title3)
            .multilineTextAlignment(.leading)
        }
        if let speakers = session.speakers {
          Text(ListFormatter.localizedString(byJoining: speakers.map(\.name)))
            .foregroundStyle(Color.init(uiColor: .label))
        }
        if let summary = session.summary {
          if session.title == "Office hour", let speakers = session.speakers {
            let description = officeHourDescription(speakers: speakers)
            Text(description)
              .foregroundStyle(Color(uiColor: .secondaryLabel))
          } else {
            Text(LocalizedStringKey(summary), bundle: .module)
              .foregroundStyle(Color(uiColor: .secondaryLabel))
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      favoriteIcon(for: session)
        .onTapGesture {
          send(.favoriteIconTapped(session))
        }
    }
  }

  @ViewBuilder
  func favoriteIcon(for session: Session) -> some View {
    if let isFavorited = session.isFavorited, isFavorited {
      Image(systemName: "star.fill")
        .foregroundColor(.yellow)
    } else {
      Image(systemName: "star")
        .foregroundColor(.gray)
    }
  }

  func extractFilteredSchedules(from conference: Conference) -> [SharedModels.Schedule] {
    switch store.selectedFilter {
    case .all:
      return conference.schedules
    case .favorite:
      return conference.schedules.filteredFavoritedOnly
    }
  }

  func officeHourTitle(speakers: [Speaker]) -> String {
    let names = givenNameList(speakers: speakers)
    return String(localized: "Office hour \(names)", bundle: .module)
  }

  func officeHourDescription(speakers: [Speaker]) -> String {
    let names = givenNameList(speakers: speakers)
    return String(localized: "Office hour description \(names)", bundle: .module)
  }

  private func givenNameList(speakers: [Speaker]) -> String {
    let givenNames = speakers.compactMap {
      let name = $0.name
      let components = try! PersonNameComponents(name).givenName
      return components
    }
    let formatter = ListFormatter()
    return formatter.string(from: givenNames)!
  }
}

struct MapTip: Tip, Equatable {
  var title: Text = Text("Go Shibuya First, NOT Garden", bundle: .module)
  var message: Text? = Text(
    "There are two kinds of Bellesalle in Shibuya. Learn how to get from Shibuya Station to \"Bellesalle Shibuya FIRST\". ",
    bundle: .module)
  var image: Image? = .init(systemName: "map.circle.fill")
}

private extension [Session] {
  var favorited: Self {
    return self.filter {
      guard let isFavorited = $0.isFavorited else {
        return false
      }
      return isFavorited
    }
  }
}

private extension [SharedModels.Schedule] {
  var filteredFavoritedOnly: Self {
    self
      .map { SharedModels.Schedule(time: $0.time, sessions: $0.sessions.favorited) }
      .filter { $0.sessions.count > 0 }
  }
}

#Preview {
  ScheduleView(
    store: .init(
      initialState: .init(),
      reducer: {
        Schedule()
      }))
}
