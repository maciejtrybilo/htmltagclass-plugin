import PackagePlugin
import Foundation

@main
struct HTMLTagClassPlugin: BuildToolPlugin {
    
    func createBuildCommands(context: PackagePlugin.PluginContext, target: any PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        Diagnostics.remark("HTMLTagClassGenerator starting")
        guard let target = target.sourceModule else { return [] }
        
        let items = try FileManager.default.contentsOfDirectory(at: context.pluginWorkDirectoryURL, includingPropertiesForKeys: [])
        
        for item in items {
            Diagnostics.remark("item: \(item)")
        }
        
//        let inputFiles = target.sourceFiles.filter({
//            
//            Diagnostics.remark("path extension \($0.url.pathExtension)")
//            return $0.url.pathExtension == ".css"
//        })
//        
//        guard !inputFiles.isEmpty else {
//            Diagnostics.remark("No css files found")
//            return []
//        }
        
//        let inputFilePaths = inputFiles.map({ $0.url.absoluteString }).joined(separator: " ")
        let outputFilePath = context.pluginWorkDirectoryURL.appending(component: "HTMLTagClass.swift").absoluteString
        
        return [.prebuildCommand(displayName: "Generating the HTML tag classes...",
                                 executable: try context.tool(named: "htmltagclass-generator").url,
                                 arguments: [" ", "--outputFile \(outputFilePath)"],
                                 environment: [:],
                                 outputFilesDirectory: context.pluginWorkDirectoryURL)]
//        return [.buildCommand(displayName: "Generating the HTML tag classes...",
//                              executable: try context.tool(named: "htmltagclass-generator").url,
//                              arguments: [inputFilePaths, "--outputFile \(outputFilePath)"],
//                              environment: [:],
//                              inputFiles: inputFiles.map(\.url),
//                              outputFiles: [context.pluginWorkDirectoryURL.appending(component: "HTMLTagClass.swift")])]
    }
}
