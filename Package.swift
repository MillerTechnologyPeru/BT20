// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Topdon",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "Topdon",
            targets: ["Topdon"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Bluetooth.git",
            .upToNextMajor(from: "6.0.0")
        ),
        .package(
            url: "https://github.com/PureSwift/GATT.git",
            from: "3.2.0"
        ),
        .package(
            url: "https://github.com/MillerTechnologyPeru/Telink.git",
            branch: "master"
        )
    ],
    targets: [
        .target(
            name: "Topdon",
            dependencies: [
                .product(
                    name: "Bluetooth",
                    package: "Bluetooth"
                ),
                .product(
                    name: "GATT",
                    package: "GATT"
                ),
                .product(
                    name: "Telink",
                    package: "Telink"
                ),
            ]
        ),
        .testTarget(
            name: "TopdonTests",
            dependencies: [
                "Topdon",
                .product(
                    name: "Bluetooth",
                    package: "Bluetooth"
                ),
                .product(
                    name: "BluetoothGAP",
                    package: "Bluetooth",
                    condition: .when(platforms: [.macOS, .linux])
                ),
                .product(
                    name: "GATT",
                    package: "GATT"
                ),
                .product(
                    name: "Telink",
                    package: "Telink"
                )
            ]
        ),
    ]
)
