//
//  IconExporter.swift
//  Skyrift
//
//  Export app icons programmatically
//

import SwiftUI

struct IconExporter {
    static func exportIcons() {
        let sizes: [(String, CGFloat)] = [
            ("1024", 1024),
            ("180", 180),
            ("167", 167),
            ("152", 152),
            ("120", 120),
            ("87", 87),
            ("80", 80),
            ("76", 76),
            ("60", 60),
            ("58", 58),
            ("40", 40),
            ("29", 29),
            ("20", 20)
        ]
        
        // Tasarımı seç (SunCloudIcon, MinimalistIcon, vb.)
        let iconView = SunCloudIcon()
        
        for (name, size) in sizes {
            let image = iconView
                .frame(width: size, height: size)
                .asUIImage(size: CGSize(width: size, height: size))
            
            // Save to Photos (test için)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            print("✅ Exported: \(name)x\(name).png")
        }
    }
}

extension View {
    @MainActor
    func asUIImage(size: CGSize) -> UIImage {
        let renderer = ImageRenderer(content: self)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? UIImage()
    }
}

// MARK: - Test Button

struct IconExportButton: View {
    var body: some View {
        Button("Export All Icons") {
            IconExporter.exportIcons()
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
}

#Preview {
    IconExportButton()
}
