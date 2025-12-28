//
//  DateService.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation

class DateService {
    static let shared = DateService()
    
    // Fixed date: November 20, 2025
    private let fixedDate: Date = {
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 20
        components.hour = 12
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    private init() {}
    
    /// Returns the fixed current date (Nov 20, 2025)
    func currentDate() -> Date {
        return fixedDate
    }
    
    /// Returns a date offset by the specified number of days from the fixed date
    func relativeDate(offset: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: offset, to: fixedDate) ?? fixedDate
    }
    
    /// Formats a date using localized formatting
    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// Formats a date with custom format (e.g., "Nov 20, 2025")
    func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    /// Formats a relative date offset as "Today", "Yesterday", "X days ago", etc.
    func formatRelativeDate(offset: Int) -> String {
        let date = relativeDate(offset: offset)
        let calendar = Calendar.current
        let today = currentDate()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let daysDiff = calendar.dateComponents([.day], from: date, to: today).day ?? 0
            if daysDiff > 0 {
                if daysDiff == 1 {
                    return "1 day ago"
                } else if daysDiff < 7 {
                    return "\(daysDiff) days ago"
                } else {
                    return formatDate(date, format: "MMM d, yyyy")
                }
            } else {
                let futureDays = abs(daysDiff)
                if futureDays == 1 {
                    return "Tomorrow"
                } else if futureDays < 7 {
                    return "In \(futureDays) days"
                } else {
                    return formatDate(date, format: "MMM d, yyyy")
                }
            }
        }
    }
    
    /// Formats a date offset for display (e.g., "Nov 7, 2025")
    func formatDateOffset(_ offset: Int) -> String {
        let date = relativeDate(offset: offset)
        return formatDate(date, format: "MMM d, yyyy")
    }
    
    /// Formats a date offset with time (e.g., "Nov 7, 2025, 9:05 AM")
    func formatDateOffsetWithTime(_ offset: Int, time: String) -> String {
        let dateStr = formatDateOffset(offset)
        return "\(dateStr), \(time)"
    }
}


