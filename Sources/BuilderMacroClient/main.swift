//
// builder-macro
// Copyright © 2024 Space Code. All rights reserved.
//

import BuilderMacro
import Foundation

@Builder
struct Person {
    let id: UUID
    let name: String
    let bday: Date
}
