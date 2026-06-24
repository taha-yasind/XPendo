/*
 DOSYA: BudgetViewModel.swift
 AMAÇ: Budget oluşturma, update, silme ve spending calculation işlemlerini yönetir. Business rule yerine BudgetView’in layout’a odaklanmasını sağlar.
 KULLANAN: BudgetView, BudgetStatusCard, Budget, Expense ve Category modelleri tarafından kullanılır.
*/
import Foundation
import Observation
import SwiftData

// BudgetMonthData, seçili ay için toplam limit, harcama ve kategori durumlarını taşır.
struct BudgetMonthData {
    let trackedBudgetCount: Int
    let overspentCount: Int
    let totalLimit: Double
    let totalSpent: Double
    let totalRemaining: Double
    let budgetStatuses: [BudgetCategoryStatus]

    // Saklanan app data üzerinden derived value hesaplar.
    var totalProgress: Double {
        // Gerekli data eksikse erken çıkış yapar.
        guard totalLimit > 0 else {
            return 0
        }

        return totalSpent / totalLimit
    }
}

// BudgetCategoryStatus, mevcut bir Budget kaydının o ayki harcamalarla karşılaştırılmış halidir.
struct BudgetCategoryStatus: Identifiable {
    let id: UUID
    let categoryID: UUID
    let categoryName: String
    let categoryIcon: String
    let colorHex: String
    let limitAmount: Double
    let spentAmount: Double
    let remainingAmount: Double

    // Bu type için odaklı bir davranış parçasını yönetir.
    var progress: Double {
        // Gerekli data eksikse erken çıkış yapar.
        guard limitAmount > 0 else {
            return 0
        }

        return spentAmount / limitAmount
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var cappedProgress: Double {
        min(max(progress, 0), 1)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var isOverBudget: Bool {
        remainingAmount < 0
    }
}

// BudgetCategoryEntry, Budget ekranında her category satırının gösterim ve input verisini temsil eder.
struct BudgetCategoryEntry: Identifiable {
    let id: UUID
    let categoryID: UUID
    let categoryName: String
    let categoryIcon: String
    let colorHex: String
    let limitAmount: Double?
    let spentAmount: Double

    // Bu type için odaklı bir davranış parçasını yönetir.
    var hasBudget: Bool {
        limitAmount != nil
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var remainingAmount: Double? {
        // Gerekli data eksikse erken çıkış yapar.
        guard let limitAmount else {
            return nil
        }

        return limitAmount - spentAmount
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var progress: Double {
        // Gerekli data eksikse erken çıkış yapar.
        guard let limitAmount, limitAmount > 0 else {
            return 0
        }

        return spentAmount / limitAmount
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var cappedProgress: Double {
        min(max(progress, 0), 1)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var isOverBudget: Bool {
        // Gerekli data eksikse erken çıkış yapar.
        guard let remainingAmount else {
            return false
        }

        return remainingAmount < 0
    }
}

// BudgetViewModel, aylık budget state'ini, draft inputları, validation ve persistence akışını yönetir.
@Observable
// Screen state ve user actionları SwiftUI layout’tan ayrı tutar.
final class BudgetViewModel {
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = AppLocalization.locale
        return calendar
    }

    var selectedMonth: Date
    var draftAmountsByCategoryID: [UUID: String] = [:]
    var validationMessage: String?
    private(set) var validationCategoryID: UUID?

    // Bu value’yu çalışmak için ihtiyaç duyduğu data ile hazırlar.
    init(now: Date = .now) {
        self.selectedMonth = BudgetViewModel.startOfMonth(for: now)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    var selectedMonthTitle: String {
        selectedMonth.formatted(.dateTime.month(.wide).year().locale(AppLocalization.locale))
    }

    // Ekran açıldığında mevcut Budget kayıtları display currency'ye çevrilip draft alanlara yazılır.
    func prepare(categories: [Category], budgets: [Budget], displayCurrencyCode: String) {
        draftAmountsByCategoryID = Dictionary(
            uniqueKeysWithValues: categories.map { category in
                let amountText = matchingBudget(for: category.id, in: budgets)
                    .map {
                        formattedAmount(
                            CurrencyConverter.displayAmount(fromTRY: $0.limitAmount, in: displayCurrencyCode)
                        )
                    } ?? ""
                return (category.id, amountText)
            }
        )
        validationCategoryID = nil
        validationMessage = nil
    }

    // Kullanıcı ay değiştirince budget hesaplamaları start-of-month değerine göre yenilenir.
    func moveMonth(by value: Int) {
        // Gerekli data eksikse erken çıkış yapar.
        guard let movedMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) else {
            return
        }

        selectedMonth = BudgetViewModel.startOfMonth(for: movedMonth)
    }

    // Her category için limit var mı, ne kadar harcanmış ve ne kadar kalmış bilgisi üretilir.
    func makeCategoryEntries(
        categories: [Category],
        budgets: [Budget],
        expenses: [Expense]
    ) -> [BudgetCategoryEntry] {
        let monthExpenses = expenses.filter { calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month) }
        let spentByCategoryID = Dictionary(grouping: monthExpenses, by: { $0.categoryID })
            .mapValues { groupedExpenses in
                groupedExpenses.reduce(0) { partialResult, expense in
                    partialResult + expense.amount
                }
            }

        return categories.map { category in
            let existingBudget = matchingBudget(for: category.id, in: budgets)

            return BudgetCategoryEntry(
                id: category.id,
                categoryID: category.id,
                categoryName: category.name,
                categoryIcon: category.icon,
                colorHex: category.color,
                limitAmount: existingBudget?.limitAmount,
                spentAmount: spentByCategoryID[Optional(category.id)] ?? 0
            )
        }
    }

    // Overview kartında kullanılan aylık toplamlar ve over-budget sayısı burada hesaplanır.
    func makeMonthData(budgets: [Budget], expenses: [Expense]) -> BudgetMonthData {
        let monthBudgets = budgetsForSelectedMonth(from: budgets)
        let monthExpenses = expenses.filter { calendar.isDate($0.date, equalTo: selectedMonth, toGranularity: .month) }
        let spentByCategoryID = Dictionary(grouping: monthExpenses, by: { $0.categoryID })
            .mapValues { groupedExpenses in
                groupedExpenses.reduce(0) { partialResult, expense in
                    partialResult + expense.amount
                }
            }

        let budgetStatuses = monthBudgets
            .compactMap { budget -> BudgetCategoryStatus? in
                // Gerekli data eksikse erken çıkış yapar.
                guard let categoryID = budget.categoryID else {
                    return nil
                }

                let spentAmount = spentByCategoryID[Optional(categoryID)] ?? 0

                return BudgetCategoryStatus(
                    id: budget.id,
                    categoryID: categoryID,
                    categoryName: budget.categoryName,
                    categoryIcon: budget.categoryIcon,
                    colorHex: budget.categoryColor,
                    limitAmount: budget.limitAmount,
                    spentAmount: spentAmount,
                    remainingAmount: budget.limitAmount - spentAmount
                )
            }
            .sorted(by: sortBudgetStatuses)

        return BudgetMonthData(
            trackedBudgetCount: budgetStatuses.count,
            overspentCount: budgetStatuses.filter(\.isOverBudget).count,
            totalLimit: budgetStatuses.reduce(0) { $0 + $1.limitAmount },
            totalSpent: budgetStatuses.reduce(0) { $0 + $1.spentAmount },
            totalRemaining: budgetStatuses.reduce(0) { $0 + $1.remainingAmount },
            budgetStatuses: budgetStatuses
        )
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    func draftAmount(for categoryID: UUID) -> String {
        draftAmountsByCategoryID[categoryID] ?? ""
    }

    // User setting veya state değişikliğini uygular.
    func updateDraftAmount(_ text: String, for categoryID: UUID) {
        draftAmountsByCategoryID[categoryID] = text

        if validationCategoryID == categoryID {
            validationCategoryID = nil
            validationMessage = nil
        }
    }

    // Validation geçtikten sonra yeni user data kaydeder.
    func saveButtonTitle(for categoryID: UUID, budgets: [Budget]) -> String {
        matchingBudget(for: categoryID, in: budgets) == nil
            ? AppLocalization.string("common.save")
            : AppLocalization.string("common.update")
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    func isResetEnabled(for categoryID: UUID, budgets: [Budget]) -> Bool {
        if matchingBudget(for: categoryID, in: budgets) != nil {
            return true
        }

        let draftAmount = draftAmount(for: categoryID).trimmingCharacters(in: .whitespacesAndNewlines)
        return !draftAmount.isEmpty
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    func validationMessage(for categoryID: UUID) -> String? {
        // Gerekli data eksikse erken çıkış yapar.
        guard validationCategoryID == categoryID else {
            return nil
        }

        return validationMessage
    }

    // Budget save flow: input validate edilir, TRY'ye çevrilir, mevcut Budget güncellenir veya yenisi eklenir.
    func saveBudget(
        for category: Category,
        in modelContext: ModelContext,
        budgets: [Budget],
        inputCurrencyCode: String
    ) throws {
        validationMessage = nil
        validationCategoryID = nil

        // Gerekli data eksikse erken çıkış yapar.
        guard let amount = parsedAmount(from: draftAmount(for: category.id)), amount > 0 else {
            validationCategoryID = category.id
            validationMessage = AppLocalization.string("budget.validation.amountPositive")
            return
        }

        let amountInTRY = CurrencyConverter.convertToTRY(amount, from: inputCurrencyCode)

        if let existingBudget = matchingBudget(for: category.id, in: budgets) {
            // Update flow: aynı ay ve category için mevcut SwiftData kaydı güncellenir.
            existingBudget.limitAmount = amountInTRY
        } else {
            // Create flow: seçili ay/yıl ve category için yeni Budget kaydı oluşturulur.
            let newBudget = Budget(
                category: category,
                limitAmount: amountInTRY,
                month: calendar.component(.month, from: selectedMonth),
                year: calendar.component(.year, from: selectedMonth)
            )

            modelContext.insert(newBudget)
        }

        try modelContext.save()
        draftAmountsByCategoryID[category.id] = formattedAmount(amount)
    }

    // Reset flow: seçili ay/category Budget kaydı varsa silinir ve draft input temizlenir.
    func resetBudget(
        for categoryID: UUID,
        in modelContext: ModelContext,
        budgets: [Budget]
    ) throws {
        if let existingBudget = matchingBudget(for: categoryID, in: budgets) {
            modelContext.delete(existingBudget)
            try modelContext.save()
        }

        draftAmountsByCategoryID[categoryID] = ""

        if validationCategoryID == categoryID {
            validationCategoryID = nil
            validationMessage = nil
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func budgetsForSelectedMonth(from budgets: [Budget]) -> [Budget] {
        let month = calendar.component(.month, from: selectedMonth)
        let year = calendar.component(.year, from: selectedMonth)

        return budgets.filter { $0.month == month && $0.year == year }
    }

    // Budget eşleşmesi category + seçili ay/yıl üzerinden yapılır.
    private func matchingBudget(for categoryID: UUID, in budgets: [Budget]) -> Budget? {
        budgetsForSelectedMonth(from: budgets).first(where: { $0.categoryID == categoryID })
    }

    // Kullanıcı amount inputu locale formatına veya nokta/virgül yazımına göre parse edilir.
    private func parsedAmount(from text: String) -> Double? {
        let normalizedText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        return Double(normalizedText)
    }

    // Raw value değerlerini interface’te gösterim için formatlar.
    private func formattedAmount(_ amount: Double) -> String {
        BudgetViewModel.amountFormatter.string(from: NSNumber(value: amount)) ?? String(amount)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private func sortBudgetStatuses(_ lhs: BudgetCategoryStatus, _ rhs: BudgetCategoryStatus) -> Bool {
        if lhs.isOverBudget != rhs.isOverBudget {
            return lhs.isOverBudget && !rhs.isOverBudget
        }

        if lhs.progress != rhs.progress {
            return lhs.progress > rhs.progress
        }

        return lhs.categoryName < rhs.categoryName
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private static func startOfMonth(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.locale = AppLocalization.locale
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.locale = AppLocalization.locale
        return formatter
    }()
}
