// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "MeowAuth",
    dependencies: [
        .Package(url: "https://github.com/OpenKitten/MeowVapor.git", majorVersion: 0)
    ]
)
