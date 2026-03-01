//
//  AppIconGenerator.swift
//  Skyrift
//
//  Generate app icon programmatically for testing
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Gradient arka plan
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.7, blue: 1.0),
                    Color(red: 0.2, green: 0.5, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // İkon - Güneş ve Bulut
            VStack(spacing: -20) {
                // Güneş
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 180))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .white.opacity(0.3), radius: 20, x: 0, y: 0)
                    .offset(x: -30, y: 20)
                
                // Bulut
                Image(systemName: "cloud.fill")
                    .font(.system(size: 140))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .offset(x: 30, y: -20)
            }
        }
    }
}

// MARK: - Icon Generator Helper

extension View {
    /// Render view as UIImage for app icon
    @MainActor
    func asAppIcon(size: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage {
        let renderer = ImageRenderer(content: self.frame(width: size.width, height: size.height))
        renderer.scale = 1.0
        return renderer.uiImage ?? UIImage()
    }
}

// MARK: - Preview

#Preview {
    AppIconView()
        .frame(width: 1024, height: 1024)
}

// MARK: - Usage Instructions
/*
 1. Bu Preview'ı çalıştır
 2. Screenshot al (Cmd+S)
 3. Veya şu kodu ContentView'da geçici kullan:
 
 Button("Generate Icon") {
     let icon = AppIconView().asAppIcon()
     // Save to Photos or Files
     UIImageWriteToSavedPhotosAlbum(icon, nil, nil, nil)
 }
 */
