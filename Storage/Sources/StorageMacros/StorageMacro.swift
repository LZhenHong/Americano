import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum StorageMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let variableDecl = member.as(VariableDeclSyntax.self),
              case let .keyword(keyword) = variableDecl.bindingSpecifier.tokenKind,
              keyword == Keyword.var
        else {
            return []
        }

        if !variableDecl.attributes.isEmpty {
            let identifiers = variableDecl.attributes
                .compactMap { $0.as(AttributeSyntax.self) }
                .compactMap { $0.attributeName.as(IdentifierTypeSyntax.self) }
            if identifiers.contains(where: { $0.name.text == "nonstorage" }) {
                return []
            }
        }

        let bindings = variableDecl.bindings.compactMap { $0.as(PatternBindingSyntax.self) }
        guard !bindings.isEmpty,
              let property = bindings.first,
              let propertyName = property.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let _ = property.initializer
        else {
            return []
        }

        return [
            """
            @AppStorage("io.lzhlovesjyq.\(raw: propertyName.lowercased())", store: (UserDefaults(suiteName: "io.lzhlovesjyq.userdefaults") ?? .standard))
            """
        ]
    }
}
