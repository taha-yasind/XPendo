/*
 DOSYA: AddExpenseViewModel.swift
 AMAÇ: Expense oluşturma veya güncelleme için form state ve validation logic saklar. Expense save kurallarını SwiftUI view dışında tutar.
 KULLANAN: AddExpenseView, ReceiptScannerView ve SwiftData expense/category modelleri tarafından kullanılır.
*/
import Foundation
import Observation
import SwiftData

// AddExpenseViewModel, Add Expense ekranındaki form state'ini ve validation akışını yönetir.
// Yeni kayıt oluşturma ve mevcut Expense'i edit etme mantığı aynı ViewModel içinde toplanır.
@Observable
// Screen state ve user actionları SwiftUI layout’tan ayrı tutar.
final class AddExpenseViewModel {
    private let expenseToEdit: Expense?
    private var didConfigureDisplayAmount = false

    var title = ""
    var amountText = ""
    var date = Date()
    var selectedCategory: Category?
    var note = ""
    var validationMessage: String?
    var receiptScanMessage: String?

    // expenseToEdit doluysa form edit modunda açılır ve mevcut değerlerle başlatılır.
    init(expenseToEdit: Expense? = nil) {
        self.expenseToEdit = expenseToEdit

        if let expenseToEdit {
            title = expenseToEdit.title
            date = expenseToEdit.date
            selectedCategory = expenseToEdit.category
            note = expenseToEdit.note ?? ""
        }
    }

    // Category listesi seed veya SwiftData sorgusu sonrası değişirse seçili category güvenli hale getirilir.
    func ensureSelectedCategory(from categories: [Category]) {
        // Gerekli data eksikse erken çıkış yapar.
        guard !categories.isEmpty else {
            selectedCategory = nil
            return
        }

        if selectedCategory == nil || !categories.contains(where: { $0.id == selectedCategory?.id }) {
            selectedCategory = categories.first
        }
    }

    // Edit modunda saklanan TRY tutarı, kullanıcının seçtiği display currency'ye çevrilerek forma yazılır.
    func prepareForm(categories: [Category], displayCurrencyCode: String) {
        ensureSelectedCategory(from: categories)

        // Gerekli data eksikse erken çıkış yapar.
        guard let expenseToEdit, !didConfigureDisplayAmount else {
            return
        }

        let displayAmount = CurrencyConverter.displayAmount(fromTRY: expenseToEdit.amount, in: displayCurrencyCode)
        amountText = Self.amountFormatter.string(from: NSNumber(value: displayAmount)) ?? String(displayAmount)
        didConfigureDisplayAmount = true
    }

    // Form validation burada yapılır; geçerliyse Expense SwiftData ModelContext içine kaydedilir.
    func saveExpense(
        in modelContext: ModelContext,
        categories: [Category],
        inputCurrencyCode: String
    ) throws {
        validationMessage = nil

        // Gerekli data eksikse erken çıkış yapar.
        guard !categories.isEmpty else {
            validationMessage = AppLocalization.string("addExpense.validation.categoryRequired")
            return
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        // Gerekli data eksikse erken çıkış yapar.
        guard !trimmedTitle.isEmpty else {
            validationMessage = AppLocalization.string("addExpense.validation.titleRequired")
            return
        }

        // Gerekli data eksikse erken çıkış yapar.
        guard let amount = parsedAmount, amount > 0 else {
            validationMessage = AppLocalization.string("addExpense.validation.amountPositive")
            return
        }

        let amountInTRY = CurrencyConverter.convertToTRY(amount, from: inputCurrencyCode)

        // Gerekli data eksikse erken çıkış yapar.
        guard let category = selectedCategory ?? categories.first else {
            validationMessage = AppLocalization.string("addExpense.validation.selectCategory")
            return
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if let expenseToEdit {
            // Edit flow: yeni kayıt oluşturmak yerine mevcut SwiftData modelinin alanları güncellenir.
            expenseToEdit.title = trimmedTitle
            expenseToEdit.amount = amountInTRY
            expenseToEdit.date = date
            expenseToEdit.category = category
            expenseToEdit.note = trimmedNote.isEmpty ? nil : trimmedNote
        } else {
            // Add flow: kullanıcı inputları TRY taban para birimine çevrilerek yeni Expense kaydı oluşturulur.
            let expense = Expense(
                title: trimmedTitle,
                amount: amountInTRY,
                date: date,
                category: category,
                note: trimmedNote.isEmpty ? nil : trimmedNote
            )

            modelContext.insert(expense)

            // Error fırlatabilecek işi başlatır.
            do {
                try modelContext.save()
            } catch {
                modelContext.delete(expense)
                throw error
            }

            return
        }

        try modelContext.save()
    }

    // OCR sonucu doğrudan kaydedilmez; form alanlarına öneri olarak uygulanır ve kullanıcı onayı beklenir.
    func applyReceiptScanResult(
        _ result: ReceiptScanResult,
        categories: [Category]
    ) {
        if let scannedTitle = result.title?.trimmingCharacters(in: .whitespacesAndNewlines),
           !scannedTitle.isEmpty {
            title = scannedTitle
        }

        if let amount = result.amount, amount > 0 {
            amountText = Self.amountFormatter.string(from: NSNumber(value: amount)) ?? String(amount)
        }

        if let scannedDate = result.date {
            date = scannedDate
        }

        if let categoryName = result.categoryName,
           let matchedCategory = categories.first(where: { $0.name.localizedCaseInsensitiveCompare(categoryName) == .orderedSame }) {
            selectedCategory = matchedCategory
        } else if let otherCategory = categories.first(where: { CategoryLocalization.isOther($0.name) }) {
            selectedCategory = otherCategory
        }

        if let scannedNote = result.note, !scannedNote.isEmpty, note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            note = scannedNote
        }

        receiptScanMessage = AppLocalization.string("receiptScan.reviewWarning")
        validationMessage = nil
    }

    // Validation geçtikten sonra yeni user data kaydeder.
    var saveButtonTitle: String {
        expenseToEdit == nil
            ? AppLocalization.string("addExpense.button.save")
            : AppLocalization.string("addExpense.button.update")
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var screenTitle: String {
        expenseToEdit == nil
            ? AppLocalization.string("addExpense.title.add")
            : AppLocalization.string("addExpense.title.edit")
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var screenSubtitle: String {
        if expenseToEdit == nil {
            return AppLocalization.string("addExpense.subtitle.add")
        }

        return AppLocalization.string("addExpense.subtitle.edit")
    }

    // Amount parser, hem locale decimal formatını hem de nokta/virgül yazımını destekler.
    private var parsedAmount: Double? {
        let trimmedAmount = amountText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Gerekli data eksikse erken çıkış yapar.
        guard !trimmedAmount.isEmpty else {
            return nil
        }

        if let localizedNumber = Self.numberFormatter.number(from: trimmedAmount) {
            return localizedNumber.doubleValue
        }

        let normalizedAmount = trimmedAmount.replacingOccurrences(of: ",", with: ".")
        return Double(normalizedAmount)
    }

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.generatesDecimalNumbers = false
        return formatter
    }()

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.locale = .current
        return formatter
    }()
}
