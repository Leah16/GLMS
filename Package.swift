// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GLMMonitor",
    platforms: [
        .macOS(.v26)
    ],
    targets: [
        .executableTarget(
            name: "GLMMonitor",
            path: "GLMMonitor",
            exclude: [
                "GLMMonitor.entitlements",
                "Info.plist"
            ],
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
