#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct StoragePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StorageMacro.self,
        NonStorageMacro.self
    ]
}
#endif
