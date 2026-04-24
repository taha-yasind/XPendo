import Foundation
import Observation
import SwiftData

@Observable
final class AddExpenseViewModel {
    private let expenseToEdit: Expense?
    private var didConfigureDisplayAmount = false

    var title = ""
    var amountText = ""
    var date = Date()
    var selectedCategory: Category?
    var note = ""
    var validationMessage: String?

    init(expenseToEdit: Expense? = nil) {
        self.expenseToEdit = expenseToEdit

        if let expenseToEdit {
            title = expenseToEdit.title
            date = expenseToEdit.date
            selectedCategory = expenseToEdit.category
            note = expenseToEdit.note ?? ""
        }
    }

    func ensureSelectedCategory(from categories: [Category]) {
        guard !categories.isEmpty else {
            selectedCategory = nil
            return
        }

        if selectedCategory == nil || !categories.contains(where: { $0.id == selectedCategory?.id }) {
            selectedCategory = categories.first
        }
    }

    func prepareForm(categories: [Category], displayCurrencyCode: String) {
        ensureSelectedCategory(from: categories)

        guard let expenseToEdit, !didConfigureDisplayAmount else {
            return
        }

        let displayAmount = CurrencyConverter.displayAmount(fromTRY: expenseToEdit.amount, in: displayCurrencyCode)
        amountText = Self.amountFormatter.string(from: NSNumber(value: displayAmount)) ?? String(displayAmount)
        didConfigureDisplayAmount = true
    }

    func saveExpense(
        in modelContext: ModelContext,
        categories: [Category],
        inputCurrencyCode: String
    ) throws {
        validationMessage = nil

        guard !categories.isEmpty else {
            validationMessage = "At least one category is required before saving."
            return
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            validationMessage = "Enter a short title for this expense."
            return
        }

        guard let amount = parsedAmount, amount > 0 else {
            validationMessage = "Enter an amount greater than zero."
            return
        }

        let amountInTRY = CurrencyConverter.convertToTRY(amount, from: inputCurrencyCode)

        guard let category = selectedCategory ?? categories.first else {
            validationMessage = "Please select a category."
            return
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if let expenseToEdit {
            expenseToEdit.title = trimmedTitle
            expenseToEdit.amount = amountInTRY
            expenseToEdit.date = date
            expenseToEdit.category = category
            expenseToEdit.note = trimmedNote.isEmpty ? nil : trimmedNote
        } else {
            let expense = Expense(
                title: trimmedTitle,
                amount: amountInTRY,
                date: date,
                category: category,
                note: trimmedNote.isEmpty ? nil : trimmedNote
            )

            modelContext.insert(expense)

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

    var saveButtonTitle: String {
        expenseToEdit == nil ? "Save Expense" : "Update Expense"
    }

    var screenTitle: String {
        expenseToEdit == nil ? "Add Expense" : "Edit Expense"
    }

    var screenSubtitle: String {
        if expenseToEdit == nil {
            return "Create a new personal expense with a clear title, amount, date, category, and optional note."
        }

        return "Update the selected expense and save the latest details."
    }

    private var parsedAmount: Double? {
        let trimmedAmount = amountText.trimmingCharacters(in: .whitespacesAndNewlines)

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
