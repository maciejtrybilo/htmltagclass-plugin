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
    ],
    targets: [
        .plugin(name: "htmltagclass-plugin",
                capability:
                .command(intent: .custom(verb: "generateHTMLTagClass",
                                         description: "Generate an enum containing all css classes defined in css files in the Public/css directory."),
                         permissions: [.writeToPackageDirectory(reason: "Need the ability to save the generated enum.")]))
    ]
)
