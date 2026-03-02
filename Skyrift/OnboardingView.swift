//
//  OnboardingView.swift
//  Skyrift
//
//  Onboarding ekranı - İlk açılışta gösterilir
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingCompleted: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "cloud.sun.rain.fill",
            title: L10n.onboardingTitle1.localized,
            description: L10n.onboardingDesc1.localized,
            color: .blue
        ),
        OnboardingPage(
            icon: "location.fill",
            title: L10n.onboardingTitle2.localized,
            description: L10n.onboardingDesc2.localized,
            color: .green
        ),
        OnboardingPage(
            icon: "bell.fill",
            title: L10n.onboardingTitle3.localized,
            description: L10n.onboardingDesc3.localized,
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            // Gradient arka plan
            LinearGradient(
                colors: [pages[currentPage].color.opacity(0.3), pages[currentPage].color.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 40) {
                // Sayfa göstergesi
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? pages[currentPage].color : Color.gray.opacity(0.3))
                            .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // İçerik
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Butonlar
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Son sayfada "Başla" butonu
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isOnboardingCompleted = true
                                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            }
                        } label: {
                            Text(L10n.onboardingStart.localized)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(pages[currentPage].color)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 32)
                    } else {
                        // İlk sayfalarda "İleri" ve "Atla" butonları
                        HStack {
                            Button(L10n.onboardingSkip.localized) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    isOnboardingCompleted = true
                                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                                }
                            }
                            .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    currentPage += 1
                                }
                            } label: {
                                HStack {
                                    Text(L10n.onboardingNext.localized)
                                    Image(systemName: "arrow.right")
                                }
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(pages[currentPage].color)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundStyle(page.color)
                .symbolEffect(.bounce, options: .repeating.speed(0.5))
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var isCompleted = false
    OnboardingView(isOnboardingCompleted: $isCompleted)
}
