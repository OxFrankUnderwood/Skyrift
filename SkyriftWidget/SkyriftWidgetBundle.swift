//
//  SkyriftWidgetBundle.swift
//  SkyriftWidget
//
//  Created by Emre on 26.02.2026.
//

import WidgetKit
import SwiftUI

@main
struct SkyriftWidgetBundle: WidgetBundle {
    var body: some Widget {
        SkyriftWidget()
        SkyriftWidgetControl()
        SkyriftWidgetLiveActivity()
    }
}
