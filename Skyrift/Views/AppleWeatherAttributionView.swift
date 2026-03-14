//
//  AppleWeatherAttributionView.swift
//  Skyrift
//

import SwiftUI
import WeatherKit

struct AppleWeatherAttributionView: View {
    let attribution: WeatherAttribution?

    @Environment(\.colorScheme) private var colorScheme

    private let legalURL = URL(string: "https://weatherkit.apple.com/legal-attribution.html")!

    var body: some View {
        VStack(spacing: 8) {
            if let attribution {
                let markURL = colorScheme == .dark
                    ? attribution.combinedMarkDarkURL
                    : attribution.combinedMarkLightURL
                Link(destination: attribution.legalPageURL) {
                    AsyncImage(url: markURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        appleWeatherFallbackMark
                    }
                    .frame(height: 20)
                }
            } else {
                Link(destination: legalURL) {
                    appleWeatherFallbackMark
                }
            }

            Link(destination: legalURL) {
                Text("weather_legal_attribution".localized)
                    .font(.caption2)
                    .foregroundStyle(.blue)
                    .underline()
            }

            Link(destination: legalURL) {
                Text(legalURL.absoluteString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .underline()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private var appleWeatherFallbackMark: some View {
        HStack(spacing: 4) {
            Image(systemName: "apple.logo")
                .font(.footnote)
            Text("Weather")
                .font(.footnote)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.secondary)
    }
}
