//
// builder-macro
// Copyright © 2024 Space Code. All rights reserved.
//

@attached(member, names: arbitrary)
public macro Builder() = #externalMacro(
    module: "BuilderMacroMacros",
    type: "BuilderMacro"
)
