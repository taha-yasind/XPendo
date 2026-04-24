import Foundation

enum AppCurrency: String, CaseIterable, Identifiable {
    case turkishLira = "TRY"
    case usDollar = "USD"
    case euro = "EUR"

    var id: String { rawValue }

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

    var displayName: String {
        Locale.current.localizedString(forCurrencyCode: rawValue) ?? rawValue
    }

    static func resolved(from code: String?) -> AppCurrency {
        guard let code else {
            return .turkishLira
        }

        return AppCurrency(rawValue: code) ?? .turkishLira
    }
}

enum CurrencyConverter {
    static let baseCurrencyCode = AppCurrency.turkishLira.rawValue

    static func supportedCurrencyCode(from code: String?) -> String {
        AppCurrency.resolved(from: code).rawValue
    }

    static func convertFromTRY(_ amountInTRY: Double, to currencyCode: String) -> Double {
        let currency = AppCurrency.resolved(from: currencyCode)
        return amountInTRY / currency.tryRate
    }

    static func convertToTRY(_ amount: Double, from currencyCode: String) -> Double {
        let currency = AppCurrency.resolved(from: currencyCode)
        return amount * currency.tryRate
    }

    static func formatFromTRY(_ amountInTRY: Double, to currencyCode: String) -> String {
        let resolvedCurrencyCode = supportedCurrencyCode(from: currencyCode)
        let convertedAmount = convertFromTRY(amountInTRY, to: resolvedCurrencyCode)
        return convertedAmount.formatted(.currency(code: resolvedCurrencyCode))
    }

    static func displayAmount(fromTRY amountInTRY: Double, in currencyCode: String) -> Double {
        convertFromTRY(amountInTRY, to: currencyCode)
    }
}
