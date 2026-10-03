import Testing
@testable import MoveBreakCore

@Test func idleAndPauseDoNotCount() {
    var engine = BreakEngine(interval: 60)
    #expect(engine.advance(seconds: 40, active: false, deferred: false) == 0)
    engine.paused = true
    engine.advance(seconds: 40, active: true, deferred: false)
    #expect(engine.remaining == 60)
}
@Test func deferredReminderAndSingleDelivery() {
    var engine = BreakEngine(interval: 60)
    engine.advance(seconds: 60, active: true, deferred: true)
    #expect(engine.pending == nil)
    engine.advance(seconds: 1, active: true, deferred: false)
    #expect(engine.pending == .movement)
    #expect(engine.advance(seconds: 50, active: true, deferred: false) == 0)
    engine.resolve(snooze: true)
    #expect(engine.remaining == 300)
}
@Test func eyeReminderIsIndependent() {
    var engine = BreakEngine(interval: 2700)
    engine.advance(seconds: 1200, active: true, deferred: false)
    #expect(engine.pending == .eyes)
    engine.resolve()
    #expect(engine.remaining == 1500)
    #expect(engine.eyeRemaining == 1200)
}
@Test func invalidElapsedTimeIsIgnored() {
    var engine = BreakEngine()
    engine.advance(seconds: .nan, active: true, deferred: false)
    engine.advance(seconds: -5, active: true, deferred: false)
    #expect(engine.remaining == 2700)
}
@Test func manualBreakDoesNotConsumeWorkTime() {
    var engine = BreakEngine()
    engine.requestBreak()
    #expect(engine.pending == .movement)
    #expect(engine.remaining == 2700)
    engine.resolve()
    #expect(engine.remaining == 2700)
}
@Test func eyeSnoozeKeepsMovementDeadline() {
    var engine = BreakEngine()
    engine.advance(seconds: 1200, active: true, deferred: false)
    engine.resolve(snooze: true)
    #expect(engine.eyeRemaining == 300)
    #expect(engine.remaining == 1500)
}
@Test func disabledEyesAndRestart() {
    var engine = BreakEngine()
    engine.eyesEnabled = false
    engine.advance(seconds: 1200, active: true, deferred: false)
    #expect(engine.pending == nil)
    engine.requestBreak()
    engine.restart()
    #expect(engine.pending == nil)
    #expect(engine.remaining == 2700)
}
