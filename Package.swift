// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Rebase",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "Rebase", targets: ["Rebase"]),
    ],
    targets: [
        .executableTarget(
            name: "Rebase",
            path: "Sources/Rebase",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
