import ActivityKit
import SwiftUI
import WidgetKit

// Home screen widgets and the live session. The app writes already formatted
// text into the shared app group (lib/app/home_widgets.dart); these views
// only lay it out.

private let appGroup = "group.com.livinlabs.sprintur"

private extension Color {
  static let bg = Color(red: 0x0B / 255, green: 0x0C / 255, blue: 0x0E / 255)
  static let surface = Color(red: 0x16 / 255, green: 0x18 / 255, blue: 0x1C / 255)
  static let line = Color(red: 0x2A / 255, green: 0x2E / 255, blue: 0x35 / 255)
  static let text = Color(red: 0xF2 / 255, green: 0xF3 / 255, blue: 0xF5 / 255)
  static let textSoft = Color(red: 0xB4 / 255, green: 0xBA / 255, blue: 0xC4 / 255)
  static let muted = Color(red: 0x9A / 255, green: 0xA1 / 255, blue: 0xAC / 255)
  static let lime = Color(red: 0xD4 / 255, green: 0xFF / 255, blue: 0x3A / 255)
}

private extension Font {
  /// Barlow is not bundled in the extension; the condensed system face is
  /// close enough at widget sizes.
  static func display(_ size: CGFloat) -> Font {
    .system(size: size, weight: .heavy).width(.condensed)
  }
}

struct SprintEntry: TimelineEntry {
  let date: Date
  let nextTitle: String
  let nextName: String
  let bestLabel: String
  let bestTime: String
  let bestNote: String
  let weekMetres: String
  let weekNote: String
  let weekDays: [Int]
  let today: Int

  static let sample = SprintEntry(
    date: .now, nextTitle: "6 × 30 m", nextName: "Acceleration",
    bestLabel: "30 m PB", bestTime: "4.41", bestNote: "−0.09 s this month",
    weekMetres: "600 m", weekNote: "2 of 3 sessions",
    weekDays: [180, 0, 240, 0, 180, 0, 0], today: 4)

  static func load() -> SprintEntry {
    let d = UserDefaults(suiteName: appGroup)
    func s(_ key: String, _ fallback: String) -> String { d?.string(forKey: key) ?? fallback }
    let days = s("week_days", "0,0,0,0,0,0,0").split(separator: ",").map { Int($0) ?? 0 }
    return SprintEntry(
      date: .now,
      nextTitle: s("next_title", "6 × 30 m"),
      nextName: s("next_name", "Acceleration"),
      bestLabel: s("best_label", "30 m PB"),
      bestTime: s("best_time", "–"),
      bestNote: s("best_note", "Time a rep to set one"),
      weekMetres: s("week_metres", "0 m"),
      weekNote: s("week_note", "0 sessions"),
      weekDays: days.count == 7 ? days : Array(repeating: 0, count: 7),
      today: d?.object(forKey: "week_today") as? Int ?? -1)
  }
}

struct SprintProvider: TimelineProvider {
  func placeholder(in context: Context) -> SprintEntry { .sample }

  func getSnapshot(in context: Context, completion: @escaping (SprintEntry) -> Void) {
    completion(context.isPreview ? .sample : .load())
  }

  /// The app reloads the timelines whenever the data changes; the daily
  /// refresh only rolls the week over.
  func getTimeline(in context: Context, completion: @escaping (Timeline<SprintEntry>) -> Void) {
    let tomorrow = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
    completion(Timeline(entries: [.load()], policy: .after(tomorrow)))
  }
}

/// `homeWidget` marks the link for the home_widget plugin's click stream.
private func appLink(_ path: String) -> URL {
  URL(string: "sprintur://\(path)?homeWidget")!
}

private struct Label: View {
  let text: String
  var color: Color = .muted
  var body: some View {
    Text(text.uppercased())
      .font(.system(size: 11, weight: .bold))
      .tracking(1.2)
      .foregroundStyle(color)
  }
}

struct NextUpView: View {
  let entry: SprintEntry
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Label(text: "Next up", color: .bg)
      Text(entry.nextTitle)
        .font(.display(30)).foregroundStyle(Color.bg)
        .lineLimit(1).minimumScaleFactor(0.6)
        .padding(.top, 2)
      Text(entry.nextName)
        .font(.system(size: 13)).foregroundStyle(Color.bg.opacity(0.75))
        .lineLimit(1)
      Spacer(minLength: 6)
      Link(destination: appLink("start")) {
        Text("Start")
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(Color.text)
          .frame(maxWidth: .infinity, minHeight: 36)
          .background(Color.bg, in: RoundedRectangle(cornerRadius: 12))
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .containerBackground(Color.lime, for: .widget)
    .widgetURL(appLink("home"))
  }
}

struct BestView: View {
  let entry: SprintEntry
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Label(text: entry.bestLabel)
      Spacer(minLength: 4)
      Text(entry.bestTime)
        .font(.display(46)).monospacedDigit()
        .foregroundStyle(Color.lime)
        .lineLimit(1).minimumScaleFactor(0.6)
      Text(entry.bestNote)
        .font(.system(size: 12)).foregroundStyle(Color.textSoft)
        .lineLimit(2)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .containerBackground(Color.surface, for: .widget)
    .widgetURL(appLink("history"))
  }
}

struct WeekView: View {
  let entry: SprintEntry
  private let letters = ["M", "T", "W", "T", "F", "S", "S"]

  var body: some View {
    let top = max(entry.weekDays.max() ?? 0, 1)
    VStack(alignment: .leading, spacing: 2) {
      Label(text: "This week")
      Text(entry.weekMetres)
        .font(.display(28)).foregroundStyle(Color.text)
        .lineLimit(1).minimumScaleFactor(0.6)
      Text(entry.weekNote)
        .font(.system(size: 12)).foregroundStyle(Color.textSoft)
        .lineLimit(1)
      Spacer(minLength: 6)
      HStack(alignment: .bottom, spacing: 5) {
        ForEach(0..<7, id: \.self) { i in
          let metres = entry.weekDays[i]
          VStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 3)
              .fill(metres > 0 ? Color.lime : Color.line)
              .overlay {
                if i == entry.today && metres == 0 {
                  RoundedRectangle(cornerRadius: 3).stroke(Color.muted, lineWidth: 1.5)
                }
              }
              .frame(height: metres > 0 ? 4 + 28 * CGFloat(metres) / CGFloat(top) : 4)
              .frame(height: 32, alignment: .bottom)
            Text(letters[i])
              .font(.system(size: 9, weight: .medium))
              .foregroundStyle(i == entry.today ? Color.text : Color.muted)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .containerBackground(Color.surface, for: .widget)
    .widgetURL(appLink("history"))
  }
}

struct NextUpWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "NextUpWidget", provider: SprintProvider()) { NextUpView(entry: $0) }
      .configurationDisplayName("Next up")
      .description("Your next workout, one tap to start.")
      .supportedFamilies([.systemSmall])
  }
}

struct BestWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "BestWidget", provider: SprintProvider()) { BestView(entry: $0) }
      .configurationDisplayName("Personal best")
      .description("Your best time at the next workout's distance.")
      .supportedFamilies([.systemSmall])
  }
}

struct WeekWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "WeekWidget", provider: SprintProvider()) { WeekView(entry: $0) }
      .configurationDisplayName("This week")
      .description("Metres and sessions this week.")
      .supportedFamilies([.systemSmall])
  }
}

// MARK: - Live session

/// The phase's clock: counts down rest and lead-in, counts up a rep. The
/// system ticks it, so the app only updates on phase changes.
private struct PhaseClock: View {
  let state: SessionActivityAttributes.ContentState
  var size: CGFloat

  var body: some View {
    Group {
      if let end = state.endsAt, end > .now {
        Text(timerInterval: Date.now...end, countsDown: true)
      } else if let start = state.startedAt {
        Text(start, style: .timer)
      } else {
        Text(" ")
      }
    }
    .font(.display(size)).monospacedDigit()
    .multilineTextAlignment(.trailing)
  }
}

struct SessionLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: SessionActivityAttributes.self) { context in
      let s = context.state
      HStack(alignment: .center, spacing: 12) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Sprintur · Rep \(s.rep) of \(s.reps)")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.muted)
          Text(s.phase)
            .font(.display(30))
            .foregroundStyle(s.phase == "RUN" ? Color.lime : Color.text)
          Text(s.detail)
            .font(.system(size: 13))
            .foregroundStyle(Color.textSoft)
        }
        Spacer()
        PhaseClock(state: s, size: 44)
          .foregroundStyle(Color.lime)
          .frame(maxWidth: 140, alignment: .trailing)
      }
      .padding(16)
      .activityBackgroundTint(Color.bg)
      .activitySystemActionForegroundColor(Color.lime)
      .widgetURL(URL(string: "sprintur://live"))
    } dynamicIsland: { context in
      let s = context.state
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          VStack(alignment: .leading) {
            Text(s.phase).font(.display(22)).foregroundStyle(Color.lime)
            Text("Rep \(s.rep) of \(s.reps)").font(.caption).foregroundStyle(Color.muted)
          }
        }
        DynamicIslandExpandedRegion(.trailing) {
          PhaseClock(state: s, size: 28).foregroundStyle(Color.text)
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text(s.detail).font(.caption).foregroundStyle(Color.textSoft)
        }
      } compactLeading: {
        Text("\(s.rep)/\(s.reps)").font(.caption.bold()).foregroundStyle(Color.lime)
      } compactTrailing: {
        PhaseClock(state: s, size: 14).foregroundStyle(Color.text).frame(maxWidth: 48)
      } minimal: {
        Image(systemName: "figure.run").foregroundStyle(Color.lime)
      }
    }
  }
}

@main
struct SprinturWidgets: WidgetBundle {
  var body: some Widget {
    NextUpWidget()
    BestWidget()
    WeekWidget()
    SessionLiveActivity()
  }
}
