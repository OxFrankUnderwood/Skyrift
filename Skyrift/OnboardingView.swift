//
//  OnboardingView.swift
//  Skyrift
//
//  İlk açılış deneyimi
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Gradient arka plan
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.8),
                    Color(red: 0.4, green: 0.6, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    onboardingPage(
                        icon: "cloud.sun.fill",
                        title: "Hava Durumunu Takip Edin",
                        description: "Gerçek zamanlı hava durumu ve 7 günlük tahminler",
                        page: 0
                    )
                    
                    onboardingPage(
                        icon: "location.fill",
                        title: "Çoklu Konum",
                        description: "Farklı şehirler ekleyin ve kolayca değiştirin",
                        page: 1
                    )
                    
                    onboardingPage(
                        icon: "rectangle.3.group.fill",
                        title: "Widget Desteği",
                        description: "Ana ekranınızda hava durumunu görün",
                        page: 2
                    )
                    
                    finalPage(page: 3)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }
    
    private func onboardingPage(icon: String, title: String, description: String, page: Int) -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 100))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            Spacer()
        }
        .tag(page)
    }
    
    private func finalPage(page: Int) -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.green)
            
            VStack(spacing: 16) {
                Text("Hazır!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Hava durumunu keşfetmeye başlayın")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            
            Button {
                hasCompletedOnboarding = true
                dismiss()
            } label: {
                Text("Başla")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
            
            Spacer()
        }
        .tag(page)
    }
}

#Preview {
    OnboardingView()
}
