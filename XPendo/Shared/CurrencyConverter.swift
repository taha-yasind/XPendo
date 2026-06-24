/*
 DOSYA: CurrencyConverter.swift
 AMAÇ: Money value değerlerini formatlar ve desteklenen currencyler arasında conversion yapar. Currency display davranışını app genelinde tutarlı tutar.
 KULLANAN: HomeViewModel, AnalyticsViewModel, BudgetViewModel, settings ve currency testleri tarafından kullanılır.
*/
import Foundation

// AppCurrency, XPendo'nun desteklediği currency seçeneklerini ve TRY bazlı dönüşüm oranlarını tutar.
enum AppCurrency: String, CaseIterable, Identifiable {
    case turkishLira = "TRY"
    case usDollar = "USD"
    case euro = "EUR"

    var id: String { rawValue }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var tryRate: Double {
        switch self {
        case .turkishLira:
            return 1.00
        case .usDollar:
            return 45.02
        case .euro:
            return 52.76
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var displayName: String {
        Locale.current.localizedString(forCurrencyCode: rawValue) ?? rawValue
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    static func resolved(from code: String?) -> AppCurrency {
        // Gerekli data eksikse erken çıkış yapar.
        guard let code else {
            return .turkishLira
        }

        return AppCurrency(rawValue: code) ?? .turkishLira
    }
}

// CurrencyConverter, uygulamanın base currency olarak TRY saklayıp farklı currency'lerde göstermesini sağlar.
// Persistence TRY üzerinden kalır; Settings sadece display/input currency tercihini değiştirir.
enum CurrencyConverter {
    static let baseCurrencyCode = AppCurrency.turkishLira.rawValue

    // Bu type için odaklı bir davranış parçasını yönetir.
    static func supportedCurrencyCode(from code: String?) -> String {
        AppCurrency.resolved(from: code).rawValue
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    static func convertFromTRY(_ amountInTRY: Double, to currencyCode: String) -> Double {
        let currency = AppCurrency.resolved(from: currencyCode)
        return amountInTRY / currency.tryRate
    }

    // Kullanıcı inputu kaydedilmeden önce base currency olan TRY'ye çevrilir.
    static func convertToTRY(_ amount: Double, from currencyCode: String) -> Double {
        let currency = AppCurrency.resolved(from: currencyCode)
        return amount * currency.tryRate
    }

    // Ekranlarda saklanan TRY tutarı seçili currency formatıyla gösterilir.
    static func formatFromTRY(_ amountInTRY: Double, to currencyCode: String) -> String {
        let resolvedCurrencyCode = supportedCurrencyCode(from: currencyCode)
        let convertedAmount = convertFromTRY(amountInTRY, to: resolvedCurrencyCode)
        return convertedAmount.formatted(.currency(code: resolvedCurrencyCode))
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    static func displayAmount(fromTRY amountInTRY: Double, in currencyCode: String) -> Double {
        convertFromTRY(amountInTRY, to: currencyCode)
    }
}
