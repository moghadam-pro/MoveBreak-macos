// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "MoveBreak", platforms: [.macOS(.v14)], products: [.executable(name: "MoveBreak", targets: ["MoveBreak"])], targets: [
    .target(name: "MoveBreakCore", resources: [.process("Resources")]),
    .executableTarget(name: "MoveBreak", dependencies: ["MoveBreakCore"], resources: [.process("Resources")]),
    .testTarget(name: "MoveBreakCoreTests", dependencies: ["MoveBreakCore"])
])
