import StorageMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testMacros: [String: Macro.Type] = [
    "storage": StorageMacro.self,
    "nonstorage": NonStorageMacro.self
]

final class StorageTests: XCTestCase {
    func test_nonstorage_macro() {
        assertMacroExpansion(
            """
            @storage
            struct A {
                @nonstorage
                var a = false
                let b = 1
                var c: Int
                private var d = 0
            }
            """,
            expandedSource: """
            struct A {
                var a = false
                let b = 1
                var c: Int
                private var d = 0
            }
            """,
            macros: testMacros)
    }

    func test_storage_marco() {
        assertMacroExpansion(
            """
            @storage
            struct A {
                var a = false
            }
            """,
            expandedSource: """
            struct A {
                @AppStorage("io.lzhlovesjyq.a.a", store: (UserDefaults(suiteName: "io.lzhlovesjyq.userdefaults") ?? .standard))
                var a = false
            }
            """,
            macros: testMacros)
    }
}
