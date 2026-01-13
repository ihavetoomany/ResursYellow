//
//  Persona.swift
//  ResursYellow
//
//  Created for prototype persona switching.
//

import Foundation

struct Persona: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let displayName: String
    
    static let john = Persona(
        id: "john",
        name: "john",
        displayName: "John"
    )
    
    static let bill = Persona(
        id: "bill",
        name: "bill",
        displayName: "Bill"
    )
    
    static let kim = Persona(
        id: "kim",
        name: "kim",
        displayName: "Kim"
    )
    
    static let allPersonas: [Persona] = [john, bill, kim]
    
    static func persona(withId id: String) -> Persona? {
        allPersonas.first { $0.id == id }
    }
}
