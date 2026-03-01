//
//  String+Localization.swift
//  Skyrift
//

import Foundation

extension String {
    /// Localize a string key
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Localize a string key with arguments
    func localized(_ arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}
