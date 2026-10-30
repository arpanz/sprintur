import ActivityKit
import Foundation

/// A running session on the lock screen and in the Dynamic Island. Compiled
/// into both the app (which starts and updates it) and the widget extension
/// (which draws it), so the two must stay in step.
@available(iOS 16.1, *)
struct SessionActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    /// GET READY, ON YOUR MARKS, SET, RUN, REST or DONE.
    var phase: String
    var rep: Int
    var reps: Int
    /// "Last 4.41 s" or "Next: 30 m".
    var detail: String
    /// Rest and lead-in count down to this.
    var endsAt: Date?
    /// A rep counts up from this.
    var startedAt: Date?
  }

  /// "6 × 30 m Acceleration"
  var workout: String
}
