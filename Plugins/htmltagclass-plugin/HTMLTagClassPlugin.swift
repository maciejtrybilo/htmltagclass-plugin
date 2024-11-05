import PackagePlugin
import Foundation

@main
struct HTMLTagClassPlugin: BuildToolPlugin {
    
    func createBuildCommands(context: PackagePlugin.PluginContext, target: any PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        Diagnostics.progress("HTMLTagClassGenerator starting")
        guard let target = target.sourceModule else { return [] }
        let inputFiles = target.sourceFiles.filter({ $0.url.pathExtension == "css" })
        
        guard !inputFiles.isEmpty else {
            Diagnostics.progress("No css files found")
            return []
        }
        
        let inputFilePaths = inputFiles.map({ $0.url.absoluteString }).joined(separator: " ")
        let outputFilePath = context.pluginWorkDirectoryURL.appending(component: "HTMLTagClass.swift").absoluteString
        
        return [.buildCommand(displayName: "Generating the HTML tag classes...",
                              executable: try context.tool(named: "htmltagclass-generator").url,
                              arguments: [inputFilePaths, "--outputFile \(outputFilePath)"],
                              environment: [:],
                              inputFiles: inputFiles.map(\.url),
                              outputFiles: [context.pluginWorkDirectoryURL.appending(component: "HTMLTagClass.swift")])]
    }
}
