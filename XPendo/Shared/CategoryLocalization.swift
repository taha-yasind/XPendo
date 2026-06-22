import Foundation

// CategoryLocalization, SwiftData'da English saklanan default category adlarını UI diline çevirir.
// Böylece persistence sabit kalırken ekranda localization uygulanır.
enum CategoryLocalization {
    static func localizedName(for storedName: String) -> String {
        switch storedName {
        case "Food":
            return AppLocalization.string("category.food")
        case "Transport":
            return AppLocalization.string("category.transport")
        case "Shopping":
            return AppLocalization.string("category.shopping")
        case "Bills":
            return AppLocalization.string("category.bills")
        case "Entertainment":
            return AppLocalization.string("category.entertainment")
        case "Health":
            return AppLocalization.string("category.health")
        case "Education":
            return AppLocalization.string("category.education")
        case "Other":
            return AppLocalization.string("category.other")
        default:
            return storedName
        }
    }

    static func isOther(_ storedName: String) -> Bool {
        storedName.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare("Other") == .orderedSame
    }
}
