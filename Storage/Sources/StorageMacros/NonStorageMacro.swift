import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum NonStorageError: CustomStringConvertible, Error {
    case onlyApplicableToVariables

    var description: String {
        switch self {
        case .onlyApplicableToVariables:
            return "@nonstorage is only applicable to properties."
        }
    }
}

public enum NonStorageMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self),
              case let .keyword(keyword) = variableDecl.bindingSpecifier.tokenKind,
              keyword == Keyword.var
        else {
            throw NonStorageError.onlyApplicableToVariables
        }
        return []
    }
}
