import Foundation
import Observation
import SwiftData

@Observable
final class AddExpenseViewModel {
    private let expenseToEdit: Expense?

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
            amountText = Self.amountFormatter.string(from: NSNumber(value: expenseToEdit.amount)) ?? String(expenseToEdit.amount)
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

    func saveExpense(in modelContext: ModelContext, categories: [Category]) throws {
        validationMessage = nil

        guard !categories.isEmpty else {
            validationMessage = "At least one category is required before saving."
            return
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            validationMessage = "Please enter a title."
            return
        }

        guard let amount = parsedAmount, amount > 0 else {
            validationMessage = "Please enter a valid amount."
            return
        }

        guard let category = selectedCategory ?? categories.first else {
            validationMessage = "Please select a category."
            return
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if let expenseToEdit {
            expenseToEdit.title = trimmedTitle
            expenseToEdit.amount = amount
            expenseToEdit.date = date
            expenseToEdit.category = category
            expenseToEdit.note = trimmedNote.isEmpty ? nil : trimmedNote
        } else {
            let expense = Expense(
                title: trimmedTitle,
                amount: amount,
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
