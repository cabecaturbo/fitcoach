// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ConversationalMacroCoach",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "ConversationalMacroCoach", targets: ["ConversationalMacroCoach"])
    ],
    targets: [
        .target(
            name: "ConversationalMacroCoach",
            path: ".",
            exclude: [
                "App",
                "Tests",
                "Design",
                "Config",
                "Package.swift",
                "README.md",
                "Design/figma_prompt.md"
            ],
            sources: [
                "Core",
                "Features"
            ]),
        .testTarget(
            name: "ConversationalMacroCoachTests",
            dependencies: ["ConversationalMacroCoach"],
            path: "Tests")
    ]
)

