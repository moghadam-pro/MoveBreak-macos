import Foundation

/// Pure active-time policy. The caller supplies monotonic elapsed time and activity state.
public struct BreakEngine: Sendable {
    public enum Kind: String, Codable, Sendable { case movement, eyes }
    public private(set) var remaining: Double
    public private(set) var eyeRemaining: Double = 1200
    public private(set) var pending: Kind?
    public var paused = false
    public var interval: Double
    public var eyesEnabled = true
    public init(interval: Double = 2700) {
        self.interval = max(60, interval)
        remaining = max(60, interval)
    }
    /// Returns newly counted work seconds. Never counts sleeping, idle or reminder time.
    @discardableResult public mutating func advance(seconds: Double, active: Bool, deferred: Bool) -> Double {
        guard !paused, active, pending == nil, seconds.isFinite, seconds > 0 else { return 0 }
        remaining = max(0, remaining - seconds)
        if eyesEnabled { eyeRemaining = max(0, eyeRemaining - seconds) }
        if !deferred {
            if remaining == 0 { pending = .movement }
            else if eyesEnabled && eyeRemaining == 0 { pending = .eyes }
        }
        return seconds
    }
    public mutating func requestBreak() {
        guard pending == nil else { return }
        pending = .movement
    }
    public mutating func resolve(snooze: Bool = false) {
        guard let kind = pending else { return }
        if kind == .movement { remaining = snooze ? 300 : interval }
        if kind == .eyes || !snooze { eyeRemaining = snooze ? 300 : 1200 }
        pending = nil
    }
    public mutating func restart() {
        remaining = interval; eyeRemaining = 1200; pending = nil
    }
}

public struct BreakRecord: Codable, Identifiable, Sendable {
    public enum Outcome: String, Codable, Sendable { case completed, skipped, snoozed }
    public var id: UUID
    public var date: Date
    public var exerciseID: Int
    public var kind: BreakEngine.Kind
    public var outcome: Outcome
    public init(exerciseID: Int, kind: BreakEngine.Kind, outcome: Outcome, date: Date = Date()) {
        id = UUID(); self.date = date; self.exerciseID = exerciseID; self.kind = kind; self.outcome = outcome
    }
}
