import PackagePlugin
import Foundation

@main
struct HTMLTagClassPlugin: BuildToolPlugin {
    
    func createBuildCommands(context: PackagePlugin.PluginContext, target: any PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        Diagnostics.remark("HTMLTagClassGenerator starting")
        guard let target = target.sourceModule else { return [] }
        
        Diagnostics.remark("current directory \(context.pluginWorkDirectoryURL.absoluteString)")
        
        let cssDirectory = URL(fileURLWithPath: target.directory.string, isDirectory: true)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(component: "Public")
            .appending(path: "css")
        
        let fileURLs = try cssFileURLs(directory: cssDirectory)
        
        Diagnostics.remark("css file urls \(fileURLs.count)")
        for fileURL in fileURLs {
            Diagnostics.remark("url: \(fileURL.path())")
        }
        
        let outputFilePath = target.directory.appending(subpath: "HTMLTagClass.swift").string
                
        return [.buildCommand(displayName: "Generating the HTML tag classes...",
                              executable: try context.tool(named: "htmltagclass-generator").url,
                              arguments: fileURLs.map({ $0.path() }) + ["--output-file", outputFilePath],
                              environment: [:],
                              inputFiles: fileURLs,
                              outputFiles: [URL(filePath: outputFilePath)])]
    }
    
    private func cssFileURLs(directory: URL) throws -> [URL] {
        
        let items = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey])
        
        var files = [URL]()
        
        for item in items {
            if try item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false {
                files += try cssFileURLs(directory: item)
            } else {
                Diagnostics.remark("Checking file \(item.absoluteString) \(item.pathExtension)")
                if item.pathExtension == "css" {
                    files += [item]
                }
            }
        }
        
        return files
    }
}
