## What's it for?

This command SPM plugin allows you to automatically generate an enum with all CSS classes declared in your css files. 

For example if you're using Vapor with [Elementary](https://swiftpackageindex.com/sliemeobn/elementary) to build a web frontend, instead of writing:
```swift
span(.class("slider round startsChecked")) {}
```
you can write:
```swift
span(.class(.slider, .round, .startsChecked)) {}
```

#### Note

To make this work with Elementary, you will need this extension:
```swift
extension HTMLAttribute where Tag: HTMLTrait.Attributes.Global {
    static func `class`(_ values: HTMLTagClass...) -> Self {
        HTMLAttribute(name: "class", value: values.map(\.rawValue).joined(separator: " "), mergedBy: .appending(seperatedBy: " "))
    }
}
```

## Installation and Use

Add the package as a dependency to your project.

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/maciejtrybilo/htmltagclass-plugin.git", from: "0.1.0")
    ],
)
```

Note: You only should add it as a package dependency, not anywhere under `targets`.x

Launch the command to generate the code:
```shell
❯ swift package plugin generateHTMLTagClass --target <MyAppTarget> --allow-writing-to-package-directory
```

You can also use [entr](https://github.com/eradman/entr) to regenerate the code automatically every time a css file is saved, e.g.:
```shell
❯ find ./Public/css | grep '\.css$' | entr -r swift package plugin generateHTMLTagClass --target <MyAppTarget> --allow-writing-to-package-directory
```

## How does it work?

The plugin looks into the `Public/css` directory and all of its subdirectories and tries to parse out all classes that are referred to in the css files. 
Then it creates the `HTMLTagClass.swift` file in the Sources/<MyAppTarget> directory containing the `HTMLTagClass` enum e.g.:
```swift
enum HTMLTagClass: String {
  case slider
  case round
  case startsChecked
}
```

The plugin tries to massage some of the edge cases such as when the class name isn't a valid Swift identifier, so a CSS file with:
```css
.left-panel {}
.switch {}
```
will result in:
```swift
enum HTMLTagClass: String {
  case left_panel = "left-panel"
  case `switch`
}
```

You're welcome to contribute any other fixes if the plugin fails in your case!
