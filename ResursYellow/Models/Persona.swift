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
    /// When true, the Merchants tab shows one shared credit across all connected merchants instead of per-merchant credits.
    let usesSharedMerchantCredit: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, name, displayName
    }
    
    init(id: String, name: String, displayName: String, usesSharedMerchantCredit: Bool = false) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.usesSharedMerchantCredit = usesSharedMerchantCredit
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        displayName = try c.decode(String.self, forKey: .displayName)
        usesSharedMerchantCredit = false
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(displayName, forKey: .displayName)
    }
    
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
    
    /// Same products, purchases, invoices and merchants as John, but with one shared credit across all connected merchants.
    static let futureJohn = Persona(
        id: "future_john",
        name: "future_john",
        displayName: "Future John",
        usesSharedMerchantCredit: true
    )
    
    static let allPersonas: [Persona] = [john, bill, kim, futureJohn]
    
    static func persona(withId id: String) -> Persona? {
        allPersonas.first { $0.id == id }
    }
}
