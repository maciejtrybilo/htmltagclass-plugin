import PackagePlugin
import Foundation

@main
struct HTMLTagClassPlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        
        var argExtractor = ArgumentExtractor(arguments)
        let targetNames = argExtractor.extractOption(named: "target")
        let targets = targetNames.isEmpty ? context.package.targets : try context.package.targets(named: targetNames)
        
        for target in targets where target.name == "App" {
            
            let cssDirectoryURL = URL(fileURLWithPath: target.directory.string, isDirectory: true)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appending(path: "Public/css")
            
            let fileURLs = try cssFileURLs(directory: cssDirectoryURL)
            
            let sortedClasses = try parse(fileURLs: fileURLs).sorted()
            
            let code = generateCode(classes: sortedClasses)
            
            let outputFileURL = URL(fileURLWithPath: target.directory.string, isDirectory: true)
                .appending(path: "Sources/App/HTMLTagClass.swift")
            
            try code.write(to: outputFileURL, atomically: true, encoding: .utf8)
        }
    }
}

private extension HTMLTagClassPlugin {
    
    func generateCode(classes: [String]) -> String {
        var cases = [String]()

        for cssClass in classes {
            if cssClass.contains("-") {
                cases += [#"    case \#(cssClass.replacing("-", with: "_")) = "\#(cssClass)""#]
            } else if ["switch"].contains(cssClass) {
                cases += [#"    case `\#(cssClass)`"#]
            } else {
                cases += [#"    case \#(cssClass)"#]
            }
        }

        let code =
        #"""
        // Generated code, don't edit.

        enum HTMLTagClass: String {
        \#(cases.joined(separator: "\n"))
        }

        """#
        
        return code
    }

    func parse(fileURLs: [URL]) throws -> Set<String> {
        
        var classes = Set<String>()

        for fileURL in fileURLs {
            
            let contents = try String(contentsOfFile: fileURL.path(), encoding: .utf8)
            
            enum State {
                case inClass
                case outsideBody
                case insideBody
            }
            
            var state = State.outsideBody
            var currentClass = ""
            
            for character in contents {
                switch character {
                case ".":
                    switch state {
                    case .inClass:
                        if !currentClass.isEmpty {
                            classes.insert(currentClass)
                            currentClass = ""
                        }
                    case .outsideBody:
                        state = .inClass
                    case .insideBody:
                        break
                    }
                case "{":
                    switch state {
                    case .inClass:
                        if !currentClass.isEmpty {
                            classes.insert(currentClass)
                            currentClass = ""
                        }
                        state = .insideBody
                    case .insideBody: // well, not handled too well
                        break
                    case .outsideBody:
                        state = .insideBody
                    }
                case "}":
                    switch state {
                    case .inClass:
                        if !currentClass.isEmpty {
                            classes.insert(currentClass)
                            currentClass = ""
                        }
                        state = .outsideBody
                    case .outsideBody:
                        break
                    case .insideBody:
                        state = .outsideBody
                    }
                case " ", "\t", "\n", ":":
                    switch state {
                    case .inClass:
                        if !currentClass.isEmpty {
                            classes.insert(currentClass)
                            currentClass = ""
                        }
                        state = .outsideBody
                    case .outsideBody:
                        break
                    case .insideBody:
                        break
                    }
                default:
                    switch state {
                    case .inClass:
                        currentClass += String(character)
                    case .outsideBody:
                        break
                    case .insideBody:
                        break
                    }
                }
            }
        }
        
        return classes
    }

    func cssFileURLs(directory: URL) throws -> [URL] {
        
        let items = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey])
        
        var files = [URL]()
        
        for item in items {
            if try item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false {
                files += try cssFileURLs(directory: item)
            } else {
                if item.pathExtension == "css" {
                    files += [item]
                }
            }
        }
        
        return files
    }
}
