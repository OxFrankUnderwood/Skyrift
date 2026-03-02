//
//  SplashScreenView.swift
//  Skyrift
//
//  Uygulama açılış logo ekranı
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isActive: Bool

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var iconIndex = 0
    @State private var selectedIcons: [(String, [Color])] = []

    // Tüm havadurumu ikonları havuzu
    private let allWeatherIcons: [(String, [Color])] = [
        ("sun.max.fill",
            [Color(red: 1.0, green: 0.72, blue: 0.18), Color(red: 1.0, green: 0.45, blue: 0.2)]),
        ("cloud.sun.fill",
            [Color(red: 0.25, green: 0.55, blue: 0.95), Color(red: 0.15, green: 0.45, blue: 0.85)]),
        ("cloud.fill",
            [Color(red: 0.38, green: 0.48, blue: 0.62), Color(red: 0.50, green: 0.60, blue: 0.72)]),
        ("cloud.rain.fill",
            [Color(red: 0.18, green: 0.32, blue: 0.70), Color(red: 0.28, green: 0.28, blue: 0.60)]),
        ("cloud.snow.fill",
            [Color(red: 0.48, green: 0.72, blue: 1.00), Color(red: 0.68, green: 0.85, blue: 1.00)]),
        ("cloud.bolt.fill",
            [Color(red: 0.22, green: 0.18, blue: 0.42), Color(red: 0.38, green: 0.28, blue: 0.55)]),
    ]

    private var currentColors: [Color] { selectedIcons.indices.contains(iconIndex) ? selectedIcons[iconIndex].1 : [] }
    private var currentIcon: String { selectedIcons.indices.contains(iconIndex) ? selectedIcons[iconIndex].0 : "cloud.fill" }

    var body: some View {
        ZStack {
            // Arka plan — hava durumuna göre renk değişiyor
            LinearGradient(
                colors: currentColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.55), value: iconIndex)

            VStack(spacing: 24) {
                // Animasyonlu ikon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.18))
                        .frame(width: 150, height: 150)
                        .blur(radius: 12)

                    Image(systemName: currentIcon)
                        .font(.system(size: 84))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.75)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .id(iconIndex)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.4).combined(with: .opacity),
                            removal:   .scale(scale: 1.6).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.38, dampingFraction: 0.7), value: iconIndex)
                }

                // Sadece uygulama adı
                Text(L10n.appName.localized)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Her açılışta rastgele 3 ikon seç
            selectedIcons = Array(allWeatherIcons.shuffled().prefix(3))

            // Giriş animasyonu
            withAnimation(.easeOut(duration: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }

            // İkon geçiş döngüsü: her 333ms'de bir sonraki
            Task {
                for i in 1..<3 {
                    try? await Task.sleep(for: .milliseconds(333))
                    withAnimation {
                        iconIndex = i
                    }
                }
            }

            // 3 ikon × 333ms ≈ 1s + 0.7s giriş → 1.4s sonra kapat
            Task {
                try? await Task.sleep(for: .milliseconds(1400))
                withAnimation(.easeInOut(duration: 0.4)) {
                    isActive = false
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isActive = true
    SplashScreenView(isActive: $isActive)
}
