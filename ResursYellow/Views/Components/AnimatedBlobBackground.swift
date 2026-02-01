//
//  AnimatedBlobBackground.swift
//  ResursYellow
//
//  Animated gradient blobs background component
//  Similar to iOS Siri/Weather app aesthetic with slow, organic movement
//

import SwiftUI

/// Animated gradient blobs that float organically, extending beyond container bounds
/// Similar to iOS Siri/Weather app aesthetic with slow, organic movement
struct AnimatedBlobBackground: View {
    let isOverdue: Bool
    @State private var animate = false
    
    // Color schemes based on payment status
    private var blobColors: [Color] {
        if isOverdue {
            // Warm, urgent colors for overdue payments
            return [
                Color(red: 1.0, green: 0.6, blue: 0.2),  // Orange
                Color(red: 1.0, green: 0.3, blue: 0.3),  // Red-orange
                Color(red: 1.0, green: 0.4, blue: 0.5)   // Pink-red
            ]
        } else {
            // Cool, calm colors for on-track payments
            return [
                Color(red: 0.2, green: 0.7, blue: 0.9),  // Sky blue
                Color(red: 0.2, green: 0.8, blue: 0.7),  // Teal
                Color(red: 0.3, green: 0.85, blue: 0.5)  // Green
            ]
        }
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60, paused: false)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                // Blob 1 - Large, positioned higher for header integration
                let blob1X = size.width * 0.15 + sin(time * 0.3) * 80
                let blob1Y = size.height * 0.25 + cos(time * 0.25) * 50
                let blob1Radius = size.width * 0.5
                
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: blob1X - blob1Radius,
                        y: blob1Y - blob1Radius,
                        width: blob1Radius * 2,
                        height: blob1Radius * 2
                    )),
                    with: .radialGradient(
                        Gradient(colors: [
                            blobColors[0].opacity(0.9),
                            blobColors[0].opacity(0.5),
                            blobColors[0].opacity(0.0)
                        ]),
                        center: .init(x: blob1X, y: blob1Y),
                        startRadius: 0,
                        endRadius: blob1Radius
                    )
                )
                
                // Blob 2 - Large, positioned higher on right side
                let blob2X = size.width * 0.85 + cos(time * 0.35 + 2) * 70
                let blob2Y = size.height * 0.3 + sin(time * 0.28 + 1.5) * 60
                let blob2Radius = size.width * 0.45
                
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: blob2X - blob2Radius,
                        y: blob2Y - blob2Radius,
                        width: blob2Radius * 2,
                        height: blob2Radius * 2
                    )),
                    with: .radialGradient(
                        Gradient(colors: [
                            blobColors[1].opacity(0.8),
                            blobColors[1].opacity(0.4),
                            blobColors[1].opacity(0.0)
                        ]),
                        center: .init(x: blob2X, y: blob2Y),
                        startRadius: 0,
                        endRadius: blob2Radius
                    )
                )
                
                // Blob 3 - Medium, centered for card area
                let blob3X = size.width * 0.5 + sin(time * 0.4 + 4) * 60
                let blob3Y = size.height * 0.65 + cos(time * 0.38 + 3) * 70
                let blob3Radius = size.width * 0.4
                
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: blob3X - blob3Radius,
                        y: blob3Y - blob3Radius,
                        width: blob3Radius * 2,
                        height: blob3Radius * 2
                    )),
                    with: .radialGradient(
                        Gradient(colors: [
                            blobColors[2].opacity(0.7),
                            blobColors[2].opacity(0.35),
                            blobColors[2].opacity(0.0)
                        ]),
                        center: .init(x: blob3X, y: blob3Y),
                        startRadius: 0,
                        endRadius: blob3Radius
                    )
                )
            }
            .blur(radius: 50)
            .allowsHitTesting(false)
        }
    }
}
