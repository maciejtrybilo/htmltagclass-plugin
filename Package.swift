// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "htmltagclass-plugin",
    products: [
        .plugin(
            name: "HTMLTagClassPlugin",
            targets: [
                "htmltagclass-plugin"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/maciejtrybilo/htmltagclass-generator",
                 branch: "main")
    ],
    targets: [
        .plugin(
            name: "htmltagclass-plugin",
            capability: .buildTool(),
            dependencies: [
                .product(name: "htmltagclass-generator", package: "htmltagclass-generator"),
            ]
        )
    ]
)
