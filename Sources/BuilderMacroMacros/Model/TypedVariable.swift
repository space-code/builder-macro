//
// builder-macro
// Copyright © 2024 Space Code. All rights reserved.
//

import Foundation

// MARK: - TypedVariable

struct TypedVariable {
    let name: String
    let type: VariableType

    var initAssignment: String {
        "\(name): \(name)"
    }

    var guardAssignment: String {
        """
        guard let \(name) = \(name) else {
            throw BuildError.missingRequiredField(description: \"\(name)\")
        }
        """
    }
}

extension [TypedVariable] {
    var initAssignments: String {
        map(\.initAssignment)
            .joined(separator: ",\n")
    }

    var guardAssignment: String {
        map(\.guardAssignment)
            .joined(separator: "\n\n")
    }
}

// MARK: - TypedVariable.VariableType

extension TypedVariable {
    struct VariableType {
        let value: String
        let isOptional: Bool
    }
}
