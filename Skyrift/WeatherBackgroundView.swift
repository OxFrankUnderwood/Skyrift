//
//  WeatherBackgroundView.swift
//  Skyrift
//
//  Animasyonlu hava durumu arka planları
//

import SwiftUI

struct WeatherBackgroundView: View {
    let weatherCode: Int
    let isDay: Bool
    
    var body: some View {
        ZStack {
            // Base gradient
            baseGradient
            
            // Animated weather effects
            weatherEffect
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Base Gradient
    
    private var baseGradient: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var gradientColors: [Color] {
        switch weatherCode {
        case 0, 1: // Açık
            return isDay
                ? [Color(red: 0.4, green: 0.7, blue: 1.0), Color(red: 0.6, green: 0.85, blue: 1.0)]
                : [Color(red: 0.05, green: 0.05, blue: 0.2), Color(red: 0.1, green: 0.1, blue: 0.3)]
        case 2, 3: // Bulutlu
            return [Color(red: 0.5, green: 0.6, blue: 0.7), Color(red: 0.6, green: 0.7, blue: 0.8)]
        case 45, 48: // Sisli
            return [Color(red: 0.7, green: 0.75, blue: 0.8), Color(red: 0.8, green: 0.85, blue: 0.9)]
        case 51...67: // Yağmurlu
            return [Color(red: 0.3, green: 0.4, blue: 0.6), Color(red: 0.4, green: 0.5, blue: 0.7)]
        case 71...86: // Karlı
            return [Color(red: 0.7, green: 0.8, blue: 0.95), Color(red: 0.85, green: 0.9, blue: 1.0)]
        case 95...99: // Fırtınalı
            return [Color(red: 0.2, green: 0.2, blue: 0.3), Color(red: 0.3, green: 0.3, blue: 0.4)]
        default:
            return [Color.blue, Color.cyan]
        }
    }
    
    // MARK: - Weather Effects
    
    @ViewBuilder
    private var weatherEffect: some View {
        switch weatherCode {
        case 0, 1: // Açık - Güneş ışınları veya yıldızlar
            if isDay {
                SunRaysView()
            } else {
                StarsView()
            }
            
        case 2, 3: // Bulutlu
            CloudsView()
            
        case 45, 48: // Sisli
            FogView()
            
        case 51...67: // Yağmurlu
            RainView()
            
        case 71...86: // Karlı
            SnowView()
            
        case 95...99: // Fırtınalı
            ThunderstormView()
            
        default:
            CloudsView()
        }
    }
}

// MARK: - Sun Rays

struct SunRaysView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.yellow.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 200, height: 4)
                    .offset(x: 100)
                    .rotationEffect(.degrees(Double(index) * 45 + rotation))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Stars

struct StarsView: View {
    @State private var twinkle = false
    let stars = (0..<50).map { _ in
        (x: Double.random(in: 0...1), y: Double.random(in: 0...0.5), size: Double.random(in: 1...3))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(stars.indices, id: \.self) { index in
                Circle()
                    .fill(.white)
                    .frame(width: stars[index].size, height: stars[index].size)
                    .position(
                        x: geometry.size.width * stars[index].x,
                        y: geometry.size.height * stars[index].y
                    )
                    .opacity(twinkle ? 0.3 : 1.0)
                    .animation(
                        .easeInOut(duration: Double.random(in: 1...2))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...1)),
                        value: twinkle
                    )
            }
        }
        .onAppear {
            twinkle = true
        }
    }
}

// MARK: - Clouds

struct CloudsView: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<5) { index in
                Image(systemName: "cloud.fill")
                    .font(.system(size: 80 + CGFloat(index) * 20))
                    .foregroundStyle(.white.opacity(0.3))
                    .offset(x: offset + CGFloat(index) * 150 - 200, y: CGFloat(index) * 80)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                offset = UIScreen.main.bounds.width + 500
            }
        }
    }
}

// MARK: - Fog

struct FogView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { layer in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.1), .white.opacity(0.3), .white.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: phase + CGFloat(layer) * 150)
                    .blur(radius: 30)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                phase = UIScreen.main.bounds.width
            }
        }
    }
}

// MARK: - Rain

struct RainView: View {
    @State private var drops: [RainDrop] = []
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    struct RainDrop: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let speed: CGFloat
        let length: CGFloat
    }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(drops) { drop in
                Capsule()
                    .fill(.blue.opacity(0.6))
                    .frame(width: 2, height: drop.length)
                    .position(x: drop.x, y: drop.y)
            }
        }
        .onReceive(timer) { _ in
            // Add new drops
            if drops.count < 100 {
                let newDrop = RainDrop(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -10,
                    speed: CGFloat.random(in: 10...20),
                    length: CGFloat.random(in: 15...30)
                )
                drops.append(newDrop)
            }
            
            // Update positions
            drops = drops.compactMap { drop in
                var newDrop = drop
                newDrop.y += drop.speed
                return newDrop.y < UIScreen.main.bounds.height + 50 ? newDrop : nil
            }
        }
    }
}

// MARK: - Snow

struct SnowView: View {
    @State private var flakes: [Snowflake] = []
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    struct Snowflake: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let speed: CGFloat
        let size: CGFloat
        var wobble: CGFloat
    }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(flakes) { flake in
                Circle()
                    .fill(.white.opacity(0.8))
                    .frame(width: flake.size, height: flake.size)
                    .position(x: flake.x + sin(flake.wobble) * 20, y: flake.y)
            }
        }
        .onReceive(timer) { _ in
            // Add new flakes
            if flakes.count < 80 {
                let newFlake = Snowflake(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -10,
                    speed: CGFloat.random(in: 2...5),
                    size: CGFloat.random(in: 4...10),
                    wobble: 0
                )
                flakes.append(newFlake)
            }
            
            // Update positions
            flakes = flakes.compactMap { flake in
                var newFlake = flake
                newFlake.y += flake.speed
                newFlake.wobble += 0.1
                return newFlake.y < UIScreen.main.bounds.height + 50 ? newFlake : nil
            }
        }
    }
}

// MARK: - Thunderstorm

struct ThunderstormView: View {
    @State private var lightning = false
    
    var body: some View {
        ZStack {
            RainView()
            
            // Lightning flash
            Rectangle()
                .fill(.white)
                .opacity(lightning ? 0.7 : 0)
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true).delay(Double.random(in: 2...5))) {
                lightning.toggle()
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        WeatherBackgroundView(weatherCode: 61, isDay: true)
            .frame(height: 200)
        
        WeatherBackgroundView(weatherCode: 71, isDay: true)
            .frame(height: 200)
        
        WeatherBackgroundView(weatherCode: 95, isDay: false)
            .frame(height: 200)
    }
}
