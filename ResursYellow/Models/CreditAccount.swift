//
//  CreditAccount.swift
//  ResursYellow
//
//  Credit account model for persona data.
//

import Foundation

struct CreditAccount: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let name: String
    let available: Double
    let limit: Double
    
    private enum CodingKeys: String, CodingKey {
        case name, available, limit
    }
    
    init(name: String, available: Double, limit: Double) {
        self.name = name
        self.available = available
        self.limit = limit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.available = try container.decode(Double.self, forKey: .available)
        self.limit = try container.decode(Double.self, forKey: .limit)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(available, forKey: .available)
        try container.encode(limit, forKey: .limit)
    }
}

private let sekNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    formatter.maximumFractionDigits = 0
    return formatter
}()

extension CreditAccount {
    var availableLabel: String {
        let formatted = sekNumberFormatter.string(from: NSNumber(value: available)) ?? "\(Int(available))"
        return "\(formatted) SEK"
    }
    
    var limitLabel: String {
        let formatted = sekNumberFormatter.string(from: NSNumber(value: limit)) ?? "\(Int(limit))"
        return "\(formatted) SEK"
    }
}
