import Foundation

public enum AppLanguage: String, Codable, CaseIterable, Sendable {
    case english = "en", persian = "fa", spanish = "es", turkish = "tr", german = "de"
    public var name: String {
        switch self {
        case .english: "English"
        case .persian: "فارسی"
        case .spanish: "Español"
        case .turkish: "Türkçe"
        case .german: "Deutsch"
        }
    }
    public var isRTL: Bool { self == .persian }
    public var locale: Locale { Locale(identifier: rawValue) }
    public static func preferred(from identifiers: [String]) -> AppLanguage {
        for identifier in identifiers {
            let code = identifier.replacingOccurrences(of: "_", with: "-").split(separator: "-").first.map(String.init) ?? ""
            if let language = Self(rawValue: code) { return language }
        }
        return .english
    }
}

public struct Localization: Sendable {
    public let language: AppLanguage
    public init(language: AppLanguage) { self.language = language }
    public static let catalogs: [AppLanguage: [String: String]] = {
        Dictionary(uniqueKeysWithValues: AppLanguage.allCases.map { language in
            guard let url = Bundle.module.url(forResource: "strings.\(language.rawValue)", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let strings = try? JSONDecoder().decode([String: String].self, from: data) else {
                preconditionFailure("Missing or invalid translation catalog: \(language.rawValue)")
            }
            return (language, strings)
        })
    }()
    public func text(_ key: String, _ arguments: String...) -> String {
        let format = Self.catalogs[language]?[key] ?? key
        guard !arguments.isEmpty else { return format }
        return String(format: format, locale: language.locale, arguments: arguments)
    }
    public func number(_ value: Int) -> String {
        value.formatted(.number.locale(language.locale).grouping(.never))
    }
}
