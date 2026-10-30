import ActivityKit
import Flutter
import Foundation

/// `sprintur/live_activity`: start, update and end the lock screen view of a
/// running session (lib/timer/live_activity.dart).
enum LiveActivityChannel {
  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "sprintur/live_activity", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard #available(iOS 16.2, *) else { return result(nil) }
      let args = call.arguments as? [String: Any] ?? [:]
      Task {
        switch call.method {
        case "start": await SessionActivity.start(workout: args["workout"] as? String ?? "", state: state(args))
        case "update": await SessionActivity.update(state(args))
        case "end": await SessionActivity.end()
        default: return result(FlutterMethodNotImplemented)
        }
        result(nil)
      }
    }
  }

  @available(iOS 16.1, *)
  private static func state(_ a: [String: Any]) -> SessionActivityAttributes.ContentState {
    func date(_ key: String) -> Date? {
      (a[key] as? NSNumber).map { Date(timeIntervalSince1970: $0.doubleValue / 1000) }
    }
    return .init(
      phase: a["phase"] as? String ?? "",
      rep: a["rep"] as? Int ?? 0,
      reps: a["reps"] as? Int ?? 0,
      detail: a["detail"] as? String ?? "",
      endsAt: date("endsAt"),
      startedAt: date("startedAt"))
  }
}

@available(iOS 16.2, *)
private enum SessionActivity {
  static var current: Activity<SessionActivityAttributes>?

  static func start(workout: String, state: SessionActivityAttributes.ContentState) async {
    await end()
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    current = try? Activity.request(
      attributes: SessionActivityAttributes(workout: workout),
      content: .init(state: state, staleDate: nil))
  }

  static func update(_ state: SessionActivityAttributes.ContentState) async {
    await current?.update(.init(state: state, staleDate: nil))
  }

  /// Also clears any left over from a session the app was killed during.
  static func end() async {
    for activity in Activity<SessionActivityAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    current = nil
  }
}
