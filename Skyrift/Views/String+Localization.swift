//
//  String+Localization.swift
//  Skyrift
//

import Foundation

extension String {
    /// Localize a string key
    var localized: String {
        let bundle = LanguageManager.shared.currentBundle
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    
    /// Localize a string key with arguments
    func localized(_ arguments: CVarArg...) -> String {
        let bundle = LanguageManager.shared.currentBundle
        return String(format: NSLocalizedString(self, bundle: bundle, comment: ""), arguments: arguments)
    }
}
