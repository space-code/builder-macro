//
// builder-macro
// Copyright © 2024 Space Code. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - BuilderMacro

public struct BuilderMacro: MemberMacro {
    enum Error: Swift.Error {
        case wrongDeclarationSyntax
    }

    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw Error.wrongDeclarationSyntax
        }

        return try Generator().generate(structDecl, attribute: attribute)
    }
}

// MARK: - BuilderMacro.Error + CustomStringConvertible

extension BuilderMacro.Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .wrongDeclarationSyntax:
            return "Builder Macro supports only structs"
        }
    }
}
