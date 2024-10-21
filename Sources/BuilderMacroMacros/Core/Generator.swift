//
// builder-macro
// Copyright © 2024 Space Code. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - Generator

struct Generator {
    // MARK: Types

    enum Error: Swift.Error {
        case wrongDeclarationSyntax
    }

    // MARK: Internal

    func generate(_ declaration: some DeclGroupSyntax, attribute: AttributeSyntax) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw Error.wrongDeclarationSyntax
        }

        let addGuards = AttributeExtractor.extractBool(from: attribute, id: .addGuards)

        let name = structDecl.name.text

        var items: [BodyItem?] = []

        for member in structDecl.memberBlock.members {
            if let variableDecl = member.decl.as(VariableDeclSyntax.self) {
                for binding in variableDecl.bindings {
                    if let pattern = identifierPatternSyntax(from: binding.pattern),
                       let type = binding.typeAnnotation?.type
                    {
                        items.append(generate(pattern: pattern, type: type))
                    }
                }
            }
        }

        let builderStruct = generateBuilderMethod(from: items.compactMap { $0 }, name: name, addGuards: addGuards)
        return [DeclSyntax(stringLiteral: builderStruct)]
    }

    // MARK: Private

    private func identifierPatternSyntax(from patternSyntax: PatternSyntax) -> IdentifierPatternSyntax? {
        if let valuePattern = patternSyntax.as(ValueBindingPatternSyntax.self) {
            return valuePattern.pattern.as(IdentifierPatternSyntax.self)
        } else {
            return patternSyntax.as(IdentifierPatternSyntax.self)
        }
    }

    private func generate(pattern: IdentifierPatternSyntax, type: TypeSyntax) -> BodyItem {
        var builderProperty = ""
        var requiredProperty: TypedVariable
        var isOptional = false

        let propertyName = pattern.identifier.text
        let propertyType = type.description.trimmingCharacters(in: .whitespaces)

        if type.as(OptionalTypeSyntax.self) != nil {
            builderProperty = """
            var \(propertyName): \(propertyType)
            """
        } else {
            builderProperty = """
            var \(propertyName): \(propertyType)?
            """

            isOptional = true
        }

        requiredProperty = TypedVariable(name: propertyName, type: .init(value: propertyType, isOptional: isOptional))

        let builderMethod = """
        func \(propertyName)(_ \(propertyName): \(propertyType)) -> Self {
            var copy = self
            copy.\(propertyName) = \(propertyName)
            return copy
        }
        """

        return BodyItem(
            builderProperty: builderProperty,
            builderMethod: builderMethod,
            requiredProperty: requiredProperty
        )
    }

    private func generateBuilderMethod(from bodyItems: [BodyItem], name: String, addGuards: Bool) -> String {
        let builderName = "\(name)Builder"

        let guardAssignment: String

        if addGuards {
            guardAssignment = (bodyItems.map(\.requiredProperty).guardAssignment)
        } else {
            guardAssignment = (bodyItems.map(\.requiredProperty).filter(\.type.isOptional).guardAssignment)
        }

        let buildMethod = """
        enum BuildError: Swift.Error {
            case missingRequiredField(description: String)
        }

        func build() throws -> \(name) {
        \(guardAssignment)

        return \(name)(
            \(bodyItems.map(\.requiredProperty).initAssignments)
        )
        }
        """

        let builderStruct = """
        struct \(builderName) {
        \(bodyItems.map(\.builderProperty).joined(separator: "\n"))

        \(bodyItems.map(\.builderMethod).joined(separator: "\n\n"))

        \(buildMethod)
        }
        """

        return builderStruct
    }
}

// MARK: Generator.BodyItem

private extension Generator {
    struct BodyItem {
        let builderProperty: String
        let builderMethod: String
        let requiredProperty: TypedVariable
    }
}

private extension String {
    static let addGuards = "addGuards"
}
