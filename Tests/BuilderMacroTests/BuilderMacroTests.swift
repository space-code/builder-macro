//
// builder-macro
// Copyright © 2024 Space Code. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(BuilderMacroMacros)
    import BuilderMacroMacros

    let testMacros: [String: Macro.Type] = [
        "Builder": BuilderMacro.self,
    ]
#endif

// MARK: - BuilderMacroTests

final class BuilderMacroTests: XCTestCase {
    func testBuilderMacro() throws {
        #if canImport(BuilderMacroMacros)
            assertMacroExpansion("""
            @Builder
            struct Person {
                let firstName: String
                let lastName: String
                let birthday: Date
                let city: String
            }
            """, expandedSource: """
            struct Person {
                let firstName: String
                let lastName: String
                let birthday: Date
                let city: String

                struct PersonBuilder {
                    var firstName: String?
                    var lastName: String?
                    var birthday: Date?
                    var city: String?

                    func firstName(_ firstName: String) -> Self {
                        var copy = self
                        copy.firstName = firstName
                        return copy
                    }

                    func lastName(_ lastName: String) -> Self {
                        var copy = self
                        copy.lastName = lastName
                        return copy
                    }

                    func birthday(_ birthday: Date) -> Self {
                        var copy = self
                        copy.birthday = birthday
                        return copy
                    }

                    func city(_ city: String) -> Self {
                        var copy = self
                        copy.city = city
                        return copy
                    }

                    enum BuildError: Swift.Error {
                        case missingRequiredField(description: String)
                    }

                    func build() throws -> Person {
                        guard let firstName = firstName else {
                            throw BuildError.missingRequiredField(description: "firstName")
                        }

                        guard let lastName = lastName else {
                            throw BuildError.missingRequiredField(description: "lastName")
                        }

                        guard let birthday = birthday else {
                            throw BuildError.missingRequiredField(description: "birthday")
                        }

                        guard let city = city else {
                            throw BuildError.missingRequiredField(description: "city")
                        }

                        return Person(
                            firstName: firstName,
                            lastName: lastName,
                            birthday: birthday,
                            city: city
                        )
                    }
                }
            }
            """, macros: testMacros)
        #endif
    }
}
