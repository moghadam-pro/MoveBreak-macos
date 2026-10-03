import Testing
import Foundation
@testable import MoveBreakCore

@Test func translationsCoverEveryKeyAndKeepFormatArguments() {
    let english = Localization.catalogs[.english]!
    for language in AppLanguage.allCases {
        let catalog = Localization.catalogs[language]!
        #expect(Set(catalog.keys) == Set(english.keys))
        for (key, source) in english {
            let target = catalog[key]!
            #expect(!target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(source.components(separatedBy: "%@").count == target.components(separatedBy: "%@").count)
        }
    }
}
@Test func persianDirectionAndLanguageSelection() {
    #expect(AppLanguage.persian.isRTL)
    #expect(AppLanguage.allCases.filter(\.isRTL) == [.persian])
    #expect(AppLanguage.preferred(from: ["fr-FR", "de-DE"]) == .german)
    #expect(AppLanguage.preferred(from: ["fa_IR"]) == .persian)
    #expect(AppLanguage.preferred(from: ["ja-JP"]) == .english)
}
@Test func localizedFormatUsesSuppliedNumbers() {
    let persian = Localization(language: .persian)
    let text = persian.text("Movement reminder: %@ minutes", persian.number(45))
    #expect(text.contains(persian.number(45)))
    #expect(!text.contains("%@"))
    #expect(Localization(language: .german).text("Home") == "Start")
}
