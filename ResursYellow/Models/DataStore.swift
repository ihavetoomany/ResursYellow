//
//  DataStore.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation

struct DataStore: Codable {
    var invoices: [Invoice]
    var transactions: [Transaction]
    var invoiceAccounts: [InvoiceAccount]
    
    init(
        invoices: [Invoice] = [],
        transactions: [Transaction] = [],
        invoiceAccounts: [InvoiceAccount] = []
    ) {
        self.invoices = invoices
        self.transactions = transactions
        self.invoiceAccounts = invoiceAccounts
    }
}


