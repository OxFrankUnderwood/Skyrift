//
//  QuickAppIcon.swift
//  Skyrift
//
//  Quick app icon designs
//

import SwiftUI

// MARK: - Design 1: Sun & Cloud

struct SunCloudIcon: View {
    var body: some View {
        ZStack {
            // Sky gradient
            LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.6, blue: 1.0),
                    Color(red: 0.5, green: 0.8, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: -40) {
                // Sun
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 200, weight: .thin))
                    .foregroundStyle(.yellow)
                    .shadow(color: .white, radius: 30)
                    .offset(x: -50, y: 30)
                
                // Cloud
                Image(systemName: "cloud.fill")
                    .font(.system(size: 180))
                    .foregroundStyle(.white)
                    .shadow(radius: 20)
                    .offset(x: 50, y: -30)
            }
        }
    }
}

// MARK: - Design 2: Minimalist

struct MinimalistIcon: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.8),
                    Color(red: 0.4, green: 0.6, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Single weather icon
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 280))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.yellow, .white)
                .shadow(color: .black.opacity(0.2), radius: 30)
        }
    }
}

// MARK: - Design 3: Letter S

struct LetterSIcon: View {
    var body: some View {
        ZStack {
            // Blue gradient
            RadialGradient(
                colors: [
                    Color(red: 0.4, green: 0.7, blue: 1.0),
                    Color(red: 0.2, green: 0.5, blue: 0.9)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            
            // Letter S
            Text("S")
                .font(.system(size: 450, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Small weather icon
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 120))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.9))
                .offset(x: 150, y: -150)
        }
    }
}

// MARK: - Design 4: Abstract

struct AbstractIcon: View {
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.1, green: 0.15, blue: 0.25)
            
            // Weather elements
            ForEach(0..<3) { i in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.3),
                                Color.cyan.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat(300 - i * 50))
                    .offset(
                        x: CGFloat(i * 40 - 40),
                        y: CGFloat(i * 40 - 40)
                    )
                    .blur(radius: 10)
            }
            
            // Center icon
            Image(systemName: "sparkles")
                .font(.system(size: 200))
                .foregroundStyle(.white)
                .shadow(color: .cyan, radius: 30)
        }
    }
}

// MARK: - Previews

#Preview("Sun & Cloud") {
    SunCloudIcon()
        .frame(width: 1024, height: 1024)
}

#Preview("Minimalist") {
    MinimalistIcon()
        .frame(width: 1024, height: 1024)
}

#Preview("Letter S") {
    LetterSIcon()
        .frame(width: 1024, height: 1024)
}

#Preview("Abstract") {
    AbstractIcon()
        .frame(width: 1024, height: 1024)
}
