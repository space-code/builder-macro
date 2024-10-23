//
// builder-macro
// Copyright © 2024 Space Code. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum AttributeExtractor {
    static func extractBool(from attribute: AttributeSyntax, id: String) -> Bool {
        guard let argumentList = attribute.arguments?.as(LabeledExprListSyntax.self) else {
            return false
        }

        for argument in argumentList {
            if argument.label?.text == id, let boolExpr = argument.expression.as(BooleanLiteralExprSyntax.self) {
                return boolExpr.literal.text == "true"
            }
        }

        return false
    }
}
