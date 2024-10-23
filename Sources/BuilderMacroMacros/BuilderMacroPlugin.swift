//
// builder-macro
// Copyright © 2024 Space Code. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - BuilderMacroPlugin

@main
struct BuilderMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BuilderMacro.self,
    ]
}
