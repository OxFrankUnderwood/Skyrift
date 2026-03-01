//
//  MinimalistIconExporter.swift
//  Skyrift
//
//  Minimalist app icon exporter
//

import SwiftUI
import UIKit

// MARK: - Icon Exporter

struct MinimalistIconExporter {
    
    // Icon tasarımı
    static var iconView: some View {
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
            
            // Weather icon
            Image(systemName: "cloud.sun.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    .yellow.opacity(0.95),
                    .white.opacity(0.95)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
    }
    
    // Tüm boyutları export et
    static func exportAllSizes() {
        let sizes: [(name: String, size: CGFloat)] = [
            // App Store
            ("AppStore", 1024),
            
            // iPhone
            ("iPhone-180", 180),
            ("iPhone-120", 120),
            ("iPhone-87", 87),
            ("iPhone-80", 80),
            ("iPhone-60", 60),
            ("iPhone-58", 58),
            ("iPhone-40", 40),
            
            // iPad
            ("iPad-167", 167),
            ("iPad-152", 152),
            ("iPad-76", 76)
        ]
        
        print("\n🎨 Minimalist Icon Export Başlatılıyor...")
        print("📱 Toplam \(sizes.count) boyut oluşturulacak\n")
        
        for (name, size) in sizes {
            autoreleasepool {
                if let image = renderIcon(size: size) {
                    // Fotoğraflara kaydet
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    print("✅ \(name).png (\(Int(size))x\(Int(size))) - Kaydedildi")
                }
            }
        }
        
        print("\n✅ Tamamlandı! Tüm ikonlar Fotoğraflar'a kaydedildi.")
        print("📂 Şimdi Xcode'da: Assets.xcassets → AppIcon'a ekleyin\n")
    }
    
    @MainActor
    private static func renderIcon(size: CGFloat) -> UIImage? {
        let iconSize = size
        
        let view = iconView
            .frame(width: iconSize, height: iconSize)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1.0
        
        return renderer.uiImage
    }
}

// MARK: - Interactive Export View

struct IconExportScreen: View {
    @State private var isExporting = false
    @State private var exportComplete = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.8),
                    Color(red: 0.4, green: 0.6, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Title
                VStack(spacing: 8) {
                    Text("Skyrift")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("App Icon Generator")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                // Preview
                VStack(spacing: 20) {
                    Text("Preview")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    MinimalistIconExporter.iconView
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 44))
                        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
                    
                    Text("Minimalist Design")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                // Info
                VStack(spacing: 12) {
                    infoRow(icon: "checkmark.circle.fill", text: "Modern ve temiz tasarım")
                    infoRow(icon: "checkmark.circle.fill", text: "SF Symbols kullanıyor")
                    infoRow(icon: "checkmark.circle.fill", text: "11 farklı boyut")
                    infoRow(icon: "checkmark.circle.fill", text: "iPhone & iPad uyumlu")
                }
                .padding(20)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Export Button
                Button {
                    isExporting = true
                    
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(300))
                        MinimalistIconExporter.exportAllSizes()
                        isExporting = false
                        exportComplete = true
                        
                        try? await Task.sleep(for: .seconds(3))
                        exportComplete = false
                    }
                } label: {
                    HStack(spacing: 12) {
                        if isExporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: exportComplete ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                                .font(.title2)
                        }
                        
                        Text(isExporting ? "Export Ediliyor..." : exportComplete ? "Tamamlandı!" : "İkonları Export Et")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(exportComplete ? Color.green : Color.blue)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .disabled(isExporting)
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(.top, 60)
        }
    }
    
    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .font(.body)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
}

#Preview {
    IconExportScreen()
}
