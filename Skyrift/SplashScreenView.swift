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
    
    var body: some View {
        ZStack {
            // Gradient arka plan
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.cyan.opacity(0.6),
                    Color.blue.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo - SF Symbol kullanıyorum, kendi logonuz varsa değiştirebilirsiniz
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .blur(radius: 10)
                    
                    Image(systemName: "cloud.sun.rain.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .symbolEffect(.pulse, options: .repeating)
                }
                
                // Uygulama adı
                Text("Skyrift")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                // Alt yazı (opsiyonel)
                Text("Hava Durumu")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Animasyonlu giriş
            withAnimation(.easeInOut(duration: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // 2 saniye sonra splash screen'i kapat
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(false))
}
