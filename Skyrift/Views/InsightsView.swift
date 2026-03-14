//
//  InsightsView.swift
//  Skyrift
//

import SwiftUI

struct InsightsView: View {
    var viewModel: WeatherViewModel

    @AppStorage("uvReminderEnabled") private var uvReminderEnabled = false
    @AppStorage("rainStartingEnabled") private var rainStartingEnabled = false
    @AppStorage("dailySummaryEnabled") private var dailySummaryEnabled = false
    @AppStorage("dailySummaryHour") private var dailySummaryHour = 7
    @AppStorage("dailySummaryMinute") private var dailySummaryMinute = 30

    // Binding<Date> that maps to hour + minute AppStorage
    private var summaryTime: Binding<Date> {
        Binding(
            get: {
                var c = DateComponents()
                c.hour = dailySummaryHour
                c.minute = dailySummaryMinute
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                dailySummaryHour = c.hour ?? 7
                dailySummaryMinute = c.minute ?? 30
                rescheduleDaily()
            }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let weather = viewModel.weatherData {
                        outfitCard(weather: weather)
                        activityCard(weather: weather)
                        uvCard(weather: weather)
                    } else {
                        noDataCard
                    }
                    smartAlertsCard

                    AppleWeatherAttributionView(attribution: viewModel.weatherAttribution)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("insights_tab".localized)
        }
    }

    // MARK: - No Data

    private var noDataCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "cloud.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("outfit_no_data".localized)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Outfit Card

    private func outfitCard(weather: WeatherData) -> some View {
        let items = clothingItems(for: weather)
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label {
                    Text("outfit_title".localized).font(.headline)
                } icon: {
                    Image(systemName: "tshirt.fill").foregroundStyle(.orange)
                }
                Spacer()
                Text("\(Int(weather.current.temperature.rounded()))°")
                    .font(.headline).foregroundStyle(.secondary)
            }

            InsightsFlowLayout(spacing: 8) {
                ForEach(items, id: \.label) { item in
                    HStack(spacing: 5) {
                        Image(systemName: item.icon).font(.caption2).foregroundStyle(item.color)
                        Text(item.label).font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(item.color.opacity(0.13), in: Capsule())
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Activity Card

    private func activityCard(weather: WeatherData) -> some View {
        let all = activityItems(for: weather)
        let canDo = all.filter { $0.isRecommended }
        let avoid = all.filter { !$0.isRecommended }

        return VStack(alignment: .leading, spacing: 14) {
            Label {
                Text("activity_title".localized).font(.headline)
            } icon: {
                Image(systemName: "figure.walk").foregroundStyle(.green)
            }

            if !canDo.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("activity_can_do".localized)
                        .font(.caption).fontWeight(.medium).foregroundStyle(.secondary)
                    InsightsFlowLayout(spacing: 8) {
                        ForEach(canDo) { item in
                            activityChip(icon: item.icon, label: item.nameKey.localized, color: .green)
                        }
                    }
                }
            }

            if !avoid.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("activity_avoid".localized)
                        .font(.caption).fontWeight(.medium).foregroundStyle(.secondary)
                    InsightsFlowLayout(spacing: 8) {
                        ForEach(avoid) { item in
                            activityChip(icon: item.icon, label: item.nameKey.localized, color: .red)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func activityChip(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.caption2).foregroundStyle(color)
            Text(label).font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12), in: Capsule())
    }

    // MARK: - UV Card

    private func uvCard(weather: WeatherData) -> some View {
        let uv = weather.current.uvIndex
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text("uv_reminder_title".localized).font(.headline)
                } icon: {
                    Image(systemName: "sun.max.fill").foregroundStyle(.yellow)
                }
                Spacer()
                Text(String(format: "%.0f", uv))
                    .font(.title3.bold()).foregroundStyle(uvColor(for: uv))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            colors: [.green, .yellow, .orange, .red, .purple],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(height: 8)
                    Circle()
                        .fill(.white).frame(width: 14, height: 14)
                        .shadow(radius: 2)
                        .offset(x: min(geo.size.width - 14, max(0, (uv / 11.0) * (geo.size.width - 14))))
                }
            }
            .frame(height: 14)

            Text(uvDescriptionKey(for: uv).localized)
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Smart Alerts Card

    private var smartAlertsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("smart_alerts_title".localized)
                .font(.caption).fontWeight(.medium).foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                #if os(iOS)
                Toggle(isOn: $uvReminderEnabled) {
                    Label {
                        Text("uv_reminder_toggle".localized).font(.subheadline)
                    } icon: {
                        Image(systemName: "sun.max.trianglebadge.exclamationmark.fill")
                            .foregroundStyle(.yellow)
                    }
                }
                .padding()
                .onChange(of: uvReminderEnabled) { _, newValue in
                    if newValue {
                        NotificationManager.shared.requestPermission { granted in
                            if !granted { uvReminderEnabled = false }
                        }
                    }
                }

                Divider().padding(.leading, 52)

                Toggle(isOn: $rainStartingEnabled) {
                    Label {
                        Text("rain_starting_toggle".localized).font(.subheadline)
                    } icon: {
                        Image(systemName: "cloud.rain.fill")
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .onChange(of: rainStartingEnabled) { _, newValue in
                    if newValue {
                        NotificationManager.shared.requestPermission { granted in
                            if !granted { rainStartingEnabled = false }
                        }
                    }
                }

                Divider().padding(.leading, 52)

                Toggle(isOn: $dailySummaryEnabled) {
                    Label {
                        Text("daily_summary_toggle".localized).font(.subheadline)
                    } icon: {
                        Image(systemName: "sun.horizon.fill").foregroundStyle(.orange)
                    }
                }
                .padding()
                .onChange(of: dailySummaryEnabled) { _, newValue in
                    if newValue {
                        NotificationManager.shared.requestPermission { granted in
                            if granted {
                                rescheduleDaily()
                            } else {
                                dailySummaryEnabled = false
                            }
                        }
                    } else {
                        NotificationManager.shared.cancelDailySummary()
                    }
                }

                if dailySummaryEnabled {
                    Divider().padding(.leading, 52)
                    HStack {
                        Text("daily_summary_time".localized)
                            .font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                        DatePicker("", selection: summaryTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .padding()
                }
                #endif
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Helpers

    private func rescheduleDaily() {
        guard dailySummaryEnabled,
              let weather = viewModel.weatherData,
              let location = viewModel.selectedLocation else { return }
        NotificationManager.shared.scheduleDailySummary(
            hour: dailySummaryHour,
            minute: dailySummaryMinute,
            cityName: location.cityName,
            weather: weather
        )
    }

    private func uvColor(for uv: Double) -> Color {
        switch uv {
        case 0..<3:  return .green
        case 3..<6:  return .yellow
        case 6..<8:  return .orange
        case 8..<11: return .red
        default:     return .purple
        }
    }

    private func uvDescriptionKey(for uv: Double) -> String {
        switch uv {
        case 0..<3:  return "uv_desc_low"
        case 3..<6:  return "uv_desc_moderate"
        case 6..<8:  return "uv_desc_high"
        case 8..<11: return "uv_desc_very_high"
        default:     return "uv_desc_extreme"
        }
    }

    // MARK: - Outfit Logic

    private struct ClothingItem {
        let icon: String
        let label: String
        let color: Color
    }

    private func clothingItems(for weather: WeatherData) -> [ClothingItem] {
        let temp = weather.current.temperature
        let code = weather.current.weatherCode
        let wind = weather.current.windSpeed
        let uv   = weather.current.uvIndex
        var items: [ClothingItem] = []

        switch temp {
        case ...0:
            items.append(.init(icon: "thermometer.snowflake",  label: "outfit_heavy_coat".localized, color: .blue))
            items.append(.init(icon: "snowflake",              label: "outfit_gloves".localized,     color: .indigo))
        case 1...10:
            items.append(.init(icon: "thermometer.medium",    label: "outfit_coat".localized,       color: .teal))
        case 11...18:
            items.append(.init(icon: "thermometer.medium",    label: "outfit_jacket".localized,     color: .mint))
        case 19...24:
            items.append(.init(icon: "tshirt.fill",           label: "outfit_tshirt".localized,     color: .orange))
        default:
            items.append(.init(icon: "tshirt.fill",           label: "outfit_light".localized,      color: .yellow))
        }

        let rainCodes = [51,53,55,56,57,61,63,65,66,67,80,81,82,95,96,99]
        let icyCodes  = [56,57,66,67,71,73,75,77,85,86]

        if rainCodes.contains(code) {
            items.append(.init(icon: "umbrella.fill", label: "outfit_umbrella".localized, color: .blue))
        }
        if icyCodes.contains(code) {
            items.append(.init(icon: "snowflake",     label: "outfit_boots".localized,    color: .cyan))
        }
        if wind > 30 {
            items.append(.init(icon: "wind",          label: "outfit_windbreaker".localized, color: .gray))
        }
        if uv >= 6 {
            items.append(.init(icon: "sunglasses",    label: "outfit_sunglasses".localized, color: .yellow))
            items.append(.init(icon: "sun.max.fill",  label: "outfit_sunscreen".localized,  color: .orange))
        } else if temp >= 25 {
            items.append(.init(icon: "sunglasses",    label: "outfit_sunglasses".localized, color: .cyan))
        }

        return items
    }

    // MARK: - Activity Logic

    private struct ActivityItem: Identifiable {
        let id = UUID()
        let icon: String
        let nameKey: String
        let isRecommended: Bool
    }

    private func activityItems(for weather: WeatherData) -> [ActivityItem] {
        let temp = weather.current.temperature
        let code = weather.current.weatherCode
        let wind = weather.current.windSpeed

        let isRain    = [51,53,55,56,57,61,63,65,66,67,80,81,82].contains(code)
        let isSnow    = [71,73,75,77,85,86].contains(code)
        let isThunder = [95,96,99].contains(code)
        let isFog     = [45,48].contains(code)
        let isHighWind = wind > 35
        let isHot     = temp > 33
        let isCold    = temp < -2
        let isSkiable = isSnow || temp < 3

        return [
            ActivityItem(icon: "figure.run",             nameKey: "activity_running",
                         isRecommended: !isThunder && !isHot && !isCold && !isSnow),
            ActivityItem(icon: "bicycle",                nameKey: "activity_cycling",
                         isRecommended: !isRain && !isSnow && !isThunder && !isHighWind),
            ActivityItem(icon: "figure.hiking",          nameKey: "activity_hiking",
                         isRecommended: !isThunder && !isRain && !isSnow && !isCold && !isFog),
            ActivityItem(icon: "figure.skiing.downhill", nameKey: "activity_skiing",
                         isRecommended: isSkiable && !isThunder),
            ActivityItem(icon: "beach.umbrella",         nameKey: "activity_beach",
                         isRecommended: !isRain && !isSnow && !isThunder && temp > 23 && !isHighWind),
            ActivityItem(icon: "camera.fill",            nameKey: "activity_photography",
                         isRecommended: !isThunder && !isFog),
            ActivityItem(icon: "fork.knife",             nameKey: "activity_picnic",
                         isRecommended: !isRain && !isSnow && !isThunder && temp > 15 && temp < 33),
        ]
    }
}

// MARK: - Flow Layout (wrapping HStack)

struct InsightsFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let rows = makeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { row in
            row.map { subviews[$0].sizeThatFits(.unspecified).height }.max() ?? 0
        }.reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(0, height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var y = bounds.minY
        for row in makeRows(proposal: proposal, subviews: subviews) {
            var x = bounds.minX
            let rowH = row.map { subviews[$0].sizeThatFits(.unspecified).height }.max() ?? 0
            for idx in row {
                let sz = subviews[idx].sizeThatFits(.unspecified)
                subviews[idx].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(sz))
                x += sz.width + spacing
            }
            y += rowH + spacing
        }
    }

    private func makeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[Int]] {
        let maxW = proposal.width ?? 0
        var rows: [[Int]] = [[]]
        var rowW: CGFloat = 0
        for (i, sv) in subviews.enumerated() {
            let w = sv.sizeThatFits(.unspecified).width
            if rowW + w > maxW, !rows[rows.count - 1].isEmpty {
                rows.append([])
                rowW = 0
            }
            rows[rows.count - 1].append(i)
            rowW += w + spacing
        }
        return rows
    }
}
