/*
 DOSYA: CategoryLocalization.swift
 AMAÇ: Localized category name ve helper key değerlerini sağlar. Category display text değerlerini diller arasında tutarlı tutar.
 KULLANAN: Category viewleri, seederlar ve category name gösteren UI alanları tarafından kullanılır.
*/
import Foundation

// CategoryLocalization, SwiftData'da English saklanan default category adlarını UI diline çevirir.
// Böylece persistence sabit kalırken ekranda localization uygulanır.
enum CategoryLocalization {
    // Bu type için odaklı bir davranış parçasını yönetir.
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

    // Bu type için odaklı bir davranış parçasını yönetir.
    static func isOther(_ storedName: String) -> Bool {
        storedName.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare("Other") == .orderedSame
    }
}
