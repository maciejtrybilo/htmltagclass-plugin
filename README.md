## What's it for?

This command SPM plugin allows you to automatically generate an enum with all CSS classes declared in your css files. 

For example if you're using Vapor with [Elementary](https://swiftpackageindex.com/sliemeobn/elementary) to build a web frontend, instead of writing:
```
span(.class("slider round startsChecked")) {}
```
you can write:
```
span(.class(.slider, .round, .startsChecked)) {}
```

#### Note

To make this work with Elementary, you will need this extension:
```
extension HTMLAttribute where Tag: HTMLTrait.Attributes.Global {
    static func `class`(_ values: HTMLTagClass...) -> Self {
        HTMLAttribute(name: "class", value: values.map(\.rawValue).joined(separator: " "), mergedBy: .appending(seperatedBy: " "))
    }
}
```

## Installation and Use

Add the package as a dependency to your project.

```
let package = Package(
    dependencies: [
        .package(url: "https://github.com/maciejtrybilo/htmltagclass-plugin.git", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "HTMLTagClassPlugin", package: "htmltagclass-plugin")
            ]
        )
    ]
)
```

Launch the command to generate the code:
```
> swift package plugin generateHTMLTagClass --allow-writing-to-package-directory
```

You can also use entr to regenerate the code automatically every time a css file is saved, e.g.:
```
> find ./Public/css | grep '\.css$' | entr -r swift package plugin generateHTMLTagClass --allow-writing-to-package-directory
```

## How does it work?

The plugin looks into the `Public/css` directory and all of its subdirectories and tries to parse out all classes that are referred to in the css files. 
Then it creates the `HTMLTagClass.swift` file in the Sources/App directory containing the `HTMLTagClass` enum e.g.:
```
enum HTMLTagClass: String {
  case slider
  case round
  case startsChecked
}
```

The plugin tries to massage some of the edge cases such as when the class name isn't a valid Swift identifier, so a CSS file with:
```
.left-panel {}
.switch {}
```
will be result in:
```
enum HTMLTagClass: String {
  case left_panel = "left-panel"
  case `switch`
}
```

You're welcome to contribute any other fixes if the plugin fails in your case!
