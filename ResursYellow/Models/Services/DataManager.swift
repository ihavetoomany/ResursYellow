//
//  DataManager.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var invoices: [Invoice] = []
    @Published var transactions: [Transaction] = []
    @Published var invoiceAccounts: [InvoiceAccount] = []
    
    private let dateService = DateService.shared
    
    // UserDefaults keys
    private let invoicesKey = "override_invoices"
    private let transactionsKey = "override_transactions"
    private let invoiceAccountsKey = "override_invoice_accounts"
    
    private init() {
        loadData()
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        loadDefaultData()
        applyOverrides()
    }
    
    private func loadDefaultData() {
        // Load invoices
        if let invoicesData = loadJSONFile(named: "default_invoices") {
            do {
                let decoder = JSONDecoder()
                let dataStore = try decoder.decode(DataStore.self, from: invoicesData)
                self.invoices = dataStore.invoices
            } catch {
                print("Error loading default invoices: \(error)")
                self.invoices = []
            }
        } else {
            self.invoices = []
        }
        
        // Load transactions
        if let transactionsData = loadJSONFile(named: "default_transactions") {
            do {
                let decoder = JSONDecoder()
                let dataStore = try decoder.decode(DataStore.self, from: transactionsData)
                self.transactions = dataStore.transactions
            } catch {
                print("Error loading default transactions: \(error)")
                self.transactions = []
            }
        } else {
            self.transactions = []
        }
        
        // Load invoice accounts
        if let accountsData = loadJSONFile(named: "default_invoice_accounts") {
            do {
                let decoder = JSONDecoder()
                let dataStore = try decoder.decode(DataStore.self, from: accountsData)
                self.invoiceAccounts = dataStore.invoiceAccounts
            } catch {
                print("Error loading default invoice accounts: \(error)")
                self.invoiceAccounts = []
            }
        } else {
            self.invoiceAccounts = []
        }
    }
    
    private func loadJSONFile(named filename: String) -> Data? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Could not find \(filename).json in bundle")
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
    private func applyOverrides() {
        // Apply invoice overrides
        if let data = UserDefaults.standard.data(forKey: invoicesKey),
           let overrides = try? JSONDecoder().decode([Invoice].self, from: data) {
            // Merge overrides with defaults (overrides take precedence by ID)
            var mergedInvoices = invoices
            for override in overrides {
                if let index = mergedInvoices.firstIndex(where: { $0.id == override.id }) {
                    mergedInvoices[index] = override
                } else {
                    mergedInvoices.append(override)
                }
            }
            invoices = mergedInvoices
        }
        
        // Apply transaction overrides
        if let data = UserDefaults.standard.data(forKey: transactionsKey),
           let overrides = try? JSONDecoder().decode([Transaction].self, from: data) {
            var mergedTransactions = transactions
            for override in overrides {
                if let index = mergedTransactions.firstIndex(where: { $0.id == override.id }) {
                    mergedTransactions[index] = override
                } else {
                    mergedTransactions.append(override)
                }
            }
            transactions = mergedTransactions
        }
        
        // Apply invoice account overrides
        if let data = UserDefaults.standard.data(forKey: invoiceAccountsKey),
           let overrides = try? JSONDecoder().decode([InvoiceAccount].self, from: data) {
            var mergedAccounts = invoiceAccounts
            for override in overrides {
                if let index = mergedAccounts.firstIndex(where: { $0.id == override.id }) {
                    mergedAccounts[index] = override
                } else {
                    mergedAccounts.append(override)
                }
            }
            invoiceAccounts = mergedAccounts
        }
    }
    
    // MARK: - Save Methods
    
    func saveInvoice(_ invoice: Invoice) {
        // Update in-memory array
        if let index = invoices.firstIndex(where: { $0.id == invoice.id }) {
            invoices[index] = invoice
        } else {
            invoices.append(invoice)
        }
        
        // Save to UserDefaults
        saveInvoicesToUserDefaults()
    }
    
    func saveTransaction(_ transaction: Transaction) {
        // Update in-memory array
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        } else {
            transactions.append(transaction)
        }
        
        // Save to UserDefaults
        saveTransactionsToUserDefaults()
    }
    
    func saveInvoiceAccount(_ account: InvoiceAccount) {
        // Update in-memory array
        if let index = invoiceAccounts.firstIndex(where: { $0.id == account.id }) {
            invoiceAccounts[index] = account
        } else {
            invoiceAccounts.append(account)
        }
        
        // Save to UserDefaults
        saveInvoiceAccountsToUserDefaults()
    }
    
    private func saveInvoicesToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(invoices) {
            UserDefaults.standard.set(encoded, forKey: invoicesKey)
        }
    }
    
    private func saveTransactionsToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: transactionsKey)
        }
    }
    
    private func saveInvoiceAccountsToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(invoiceAccounts) {
            UserDefaults.standard.set(encoded, forKey: invoiceAccountsKey)
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: invoicesKey)
        UserDefaults.standard.removeObject(forKey: transactionsKey)
        UserDefaults.standard.removeObject(forKey: invoiceAccountsKey)
        
        // Reload from JSON files
        loadDefaultData()
    }
    
    // MARK: - Query Methods
    
    func invoicesForCategory(_ category: Invoice.InvoiceCategory) -> [Invoice] {
        return invoices.filter { $0.category == category }
    }
    
    func transactionsForAccount(_ accountId: UUID) -> [Transaction] {
        return transactions.filter { $0.accountId == accountId }
    }
    
    func invoiceAccount(withId id: UUID) -> InvoiceAccount? {
        return invoiceAccounts.first { $0.id == id }
    }
}

