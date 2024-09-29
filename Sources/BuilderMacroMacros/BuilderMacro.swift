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

    // swiftlint:disable:next function_body_length
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw Error.wrongDeclarationSyntax
        }

        let name = structDecl.name.text
        let builderName = "\(name)Builder"

        var builderProperties: [String] = []
        var builderMethods: [String] = []
        var requiredProperties: [TypedVariable] = []

        for member in structDecl.memberBlock.members {
            if let variableDecl = member.decl.as(VariableDeclSyntax.self),
               let firstBuilding = variableDecl.bindings.first,
               let pattern = firstBuilding.pattern.as(IdentifierPatternSyntax.self),
               let type = firstBuilding.typeAnnotation?.type
            {
                let propertyName = pattern.identifier.text
                let propertyType = type.description.trimmingCharacters(in: .whitespaces)

                let builderProperty = """
                var \(propertyName): \(propertyType)?
                """

                builderProperties.append(builderProperty)
                requiredProperties.append(TypedVariable(name: propertyName, type: propertyType))

                let builderMethod = """
                func \(propertyName)(_ \(propertyName): \(propertyType)) -> Self {
                    var copy = self
                    copy.\(propertyName) = \(propertyName)
                    return copy
                }
                """

                builderMethods.append(builderMethod)
            }
        }

        let buildMethod = """
        enum BuildError: Swift.Error {
            case missingRequiredField(description: String)
        }

        func build() throws -> \(name) {
        \(requiredProperties.guardAssignment)

        return \(name)(
            \(requiredProperties.initAssignments)
        )
        }
        """

        let builderStruct = """
        struct \(builderName) {
        \(builderProperties.joined(separator: "\n"))

        \(builderMethods.joined(separator: "\n\n"))

        \(buildMethod)
        }
        """

        return [DeclSyntax(stringLiteral: builderStruct)]
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
