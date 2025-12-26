//
//  LocalizationService.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation
import SwiftUI
import Combine

enum Language: String, Codable, CaseIterable, Identifiable {
    case swedish = "sv"
    case english = "en"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .swedish: return "Svenska"
        case .english: return "English"
        }
    }
}

class LocalizationService: ObservableObject {
    static let shared = LocalizationService()
    
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
            loadLocalizedStrings()
            // Explicitly notify observers that the language changed
            objectWillChange.send()
        }
    }
    
    @Published private var localizedStrings: [String: String] = [:]
    private var bundle: Bundle?
    
    private init() {
        // Load saved language or default to English
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language"),
           let language = Language(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = .english
        }
        loadLocalizedStrings()
    }
    
    private func loadLocalizedStrings() {
        // Load language-specific strings
        // Try multiple path strategies since bundle structure can vary
        var stringsPath: String?
        
        switch currentLanguage {
        case .swedish:
            // Try different path strategies for Swedish
            let pathsToTry = [
                Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: "Data/sv.lproj"),
                Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: "sv.lproj"),
                Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: "Data/sv.lproj")?.path,
                Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: "sv.lproj")?.path,
                Bundle.main.path(forResource: "sv", ofType: "lproj").map { "\($0)/Localizable.strings" }
            ]
            for path in pathsToTry {
                if let p = path, FileManager.default.fileExists(atPath: p) {
                    stringsPath = p
                    break
                }
            }
        case .english:
            // Try different path strategies for English
            let pathsToTry = [
                Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: "Data"),
                Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: "Data")?.path,
                Bundle.main.path(forResource: "Localizable", ofType: "strings")
            ]
            for path in pathsToTry {
                if let p = path, FileManager.default.fileExists(atPath: p) {
                    stringsPath = p
                    break
                }
            }
        }
        
        // If bundle lookup failed, try loading from source files (for development)
        if stringsPath == nil {
            let sourceBasePath = Bundle.main.resourcePath ?? ""
            switch currentLanguage {
            case .swedish:
                let sourcePath = "\(sourceBasePath)/Data/sv.lproj/Localizable.strings"
                if FileManager.default.fileExists(atPath: sourcePath) {
                    stringsPath = sourcePath
                } else {
                    // Try relative to project root
                    let projectPath = "/Users/R01501/Desktop/ResursApps/ResursYellow/ResursYellow/Data/sv.lproj/Localizable.strings"
                    if FileManager.default.fileExists(atPath: projectPath) {
                        stringsPath = projectPath
                    }
                }
            case .english:
                let sourcePath = "\(sourceBasePath)/Data/Localizable.strings"
                if FileManager.default.fileExists(atPath: sourcePath) {
                    stringsPath = sourcePath
                } else {
                    // Try relative to project root
                    let projectPath = "/Users/R01501/Desktop/ResursApps/ResursYellow/ResursYellow/Data/Localizable.strings"
                    if FileManager.default.fileExists(atPath: projectPath) {
                        stringsPath = projectPath
                    }
                }
            }
        }
        
        if let path = stringsPath,
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            localizedStrings = dict
        } else {
            // Fallback: empty dictionary
            localizedStrings = [:]
        }
        // Notify observers that strings have been reloaded
        objectWillChange.send()
    }
    
    func localizedString(_ key: String, fallback: String? = nil) -> String {
        return localizedStrings[key] ?? fallback ?? key
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
    }
}

// Convenience extension for easy access
extension String {
    var localized: String {
        return LocalizationService.shared.localizedString(self, fallback: self)
    }
}

