import Foundation
import SwiftData

struct DemoDataOperationResult {
    let expenseCount: Int
    let budgetCount: Int
}

enum DemoDataSeeder {
    enum DemoDataError: Error {
        case existingData(expenseCount: Int, budgetCount: Int)
    }

    private static let demoTitlePrefix = "Demo • "
    private static let demoMonthCount = 6
    private static let demoWeekdaySet: Set<Int> = [1, 2, 4, 6] // Sun, Mon, Wed, Fri
    private static let demoBudgetDefinitions: [(categoryName: String, limitAmount: Double)] = [
        ("Food", 9450.17),
        ("Transport", 4120.41),
        ("Shopping", 6280.63),
        ("Bills", 5080.85),
        ("Health", 3720.25),
        ("Entertainment", 4280.55)
    ]
    private static let categoryTitlePool: [String: [String]] = [
        "Food": ["Market Run", "Lunch Break", "Coffee Stop", "Dinner Out", "Bakery Pickup"],
        "Transport": ["Ride Share", "Fuel Refill", "Metro Card", "Parking Fee", "Bus Ticket"],
        "Shopping": ["Online Order", "Clothing Item", "Household Item", "Gadget Accessory", "Pharmacy Item"],
        "Bills": ["Electricity Bill", "Water Bill", "Internet Bill", "Phone Payment", "Subscription"],
        "Health": ["Clinic Visit", "Medicine Purchase", "Vitamin Pack", "Lab Test", "Doctor Follow-Up"],
        "Entertainment": ["Cinema Night", "Concert Ticket", "Streaming Upgrade", "Game Purchase", "Weekend Activity"],
        "Education": ["Book Purchase", "Course Material", "Workshop Fee", "Study App", "Printing Service"],
        "Other": ["Gift Expense", "Emergency Spend", "Misc Purchase", "Small Repair", "Home Supply"]
    ]
    private static let categoryAmountRanges: [String: ClosedRange<Double>] = [
        "Food": 180...1450,
        "Transport": 120...980,
        "Shopping": 260...2650,
        "Bills": 320...1850,
        "Health": 200...1480,
        "Entertainment": 140...1780,
        "Education": 130...1380,
        "Other": 90...980
    ]
    private static let categoryRotation: [String] = [
        "Food", "Transport", "Shopping", "Bills", "Health", "Entertainment", "Education", "Other"
    ]

    static func loadDemoData(in modelContext: ModelContext) throws -> DemoDataOperationResult {
        try AppDataSeeder.seedIfNeeded(in: modelContext)

        let existingExpenses = try modelContext.fetch(FetchDescriptor<Expense>())
        let existingBudgets = try modelContext.fetch(FetchDescriptor<Budget>())

        guard existingExpenses.isEmpty, existingBudgets.isEmpty else {
            throw DemoDataError.existingData(
                expenseCount: existingExpenses.count,
                budgetCount: existingBudgets.count
            )
        }

        let categories = try modelContext.fetch(FetchDescriptor<Category>())
        let categoriesByName = Dictionary(uniqueKeysWithValues: categories.map { ($0.name, $0) })
        let now = Date()
        let calendar = Calendar.current

        let demoEntries = makeDemoEntries(now: now, calendar: calendar)

        var insertedExpenseCount = 0
        for entry in demoEntries {
            guard let category = categoriesByName[entry.categoryName] else {
                continue
            }

            let expense = Expense(
                title: demoTitlePrefix + entry.title,
                amount: entry.amount,
                date: entry.date,
                category: category,
                note: nil
            )
            modelContext.insert(expense)
            insertedExpenseCount += 1
        }

        var insertedBudgetCount = 0

        for monthOffset in (-(demoMonthCount - 1))...0 {
            guard let monthDate = calendar.date(byAdding: .month, value: monthOffset, to: now) else {
                continue
            }

            let month = calendar.component(.month, from: monthDate)
            let year = calendar.component(.year, from: monthDate)

            for definition in demoBudgetDefinitions {
                guard let category = categoriesByName[definition.categoryName] else {
                    continue
                }

                let budget = Budget(
                    category: category,
                    limitAmount: demoBudgetAmount(base: definition.limitAmount, monthOffset: monthOffset),
                    month: month,
                    year: year
                )
                modelContext.insert(budget)
                insertedBudgetCount += 1
            }
        }

        if modelContext.hasChanges {
            try modelContext.save()
        }

        return DemoDataOperationResult(
            expenseCount: insertedExpenseCount,
            budgetCount: insertedBudgetCount
        )
    }

    static func clearDemoData(in modelContext: ModelContext) throws -> DemoDataOperationResult {
        let expenses = try modelContext.fetch(FetchDescriptor<Expense>())
        let budgets = try modelContext.fetch(FetchDescriptor<Budget>())
        let calendar = Calendar.current
        let now = Date()
        let demoExpenses = expenses.filter { $0.title.hasPrefix(demoTitlePrefix) }
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let demoBudgetTargets = Dictionary(uniqueKeysWithValues: demoBudgetDefinitions.map { ($0.categoryName, $0.limitAmount) })
        let demoBudgets = budgets.filter { budget in
            guard
                let budgetMonthDate = calendar.date(from: DateComponents(year: budget.year, month: budget.month, day: 1)),
                let monthDelta = calendar.dateComponents([.month], from: currentMonthStart, to: budgetMonthDate).month,
                monthDelta >= -(demoMonthCount - 1),
                monthDelta <= 0
            else {
                return false
            }

            guard let baseTarget = demoBudgetTargets[budget.categoryName] else {
                return false
            }

            let expectedAmount = demoBudgetAmount(base: baseTarget, monthOffset: monthDelta)
            return abs(budget.limitAmount - expectedAmount) < 0.0001
        }

        for expense in demoExpenses {
            modelContext.delete(expense)
        }

        for budget in demoBudgets {
            modelContext.delete(budget)
        }

        if modelContext.hasChanges {
            try modelContext.save()
        }

        return DemoDataOperationResult(
            expenseCount: demoExpenses.count,
            budgetCount: demoBudgets.count
        )
    }

    private static func makeDemoEntries(now: Date, calendar: Calendar) -> [DemoEntry] {
        var entries: [DemoEntry] = []

        for monthOffset in (-(demoMonthCount - 1))...0 {
            guard let monthDate = calendar.date(byAdding: .month, value: monthOffset, to: now),
                  let dayRange = calendar.range(of: .day, in: .month, for: monthDate) else {
                continue
            }

            let monthSeed = abs(monthOffset) + 1

            for day in dayRange {
                guard let dayDate = date(
                    yearMonthFrom: monthDate,
                    day: day,
                    hour: 10,
                    minute: 0,
                    calendar: calendar
                ) else {
                    continue
                }

                let weekday = calendar.component(.weekday, from: dayDate)
                guard demoWeekdaySet.contains(weekday) else {
                    continue
                }

                let dailyEntryCount = (day + monthSeed).isMultiple(of: 2) ? 3 : 4
                for entryIndex in 0..<dailyEntryCount {
                    let categoryIndex = (monthSeed * 31 + day * 7 + entryIndex * 3) % categoryRotation.count
                    let categoryName = categoryRotation[categoryIndex]
                    let titleOptions = categoryTitlePool[categoryName] ?? ["Expense"]
                    let titleIndex = (day * 5 + monthSeed + entryIndex) % titleOptions.count
                    let title = titleOptions[titleIndex]
                    let amountRange = categoryAmountRanges[categoryName] ?? 100...600
                    let amountSeed = monthSeed * 1000 + day * 10 + entryIndex
                    let amount = amountInRange(amountRange, seed: amountSeed)

                    guard let entryDate = date(
                        yearMonthFrom: monthDate,
                        day: day,
                        hour: 9 + (entryIndex * 4),
                        minute: (entryIndex * 13) % 60,
                        calendar: calendar
                    ) else {
                        continue
                    }

                    entries.append(
                        DemoEntry(
                            title: title,
                            amount: amount,
                            date: entryDate,
                            categoryName: categoryName
                        )
                    )
                }
            }
        }

        return entries
    }

    private static func amountInRange(_ range: ClosedRange<Double>, seed: Int) -> Double {
        let normalized = Double((seed * 37) % 100) / 100
        let rawAmount = range.lowerBound + ((range.upperBound - range.lowerBound) * normalized)
        return (rawAmount * 100).rounded() / 100
    }

    private static func demoBudgetAmount(base: Double, monthOffset: Int) -> Double {
        let magnitude = abs(monthOffset)
        let adjustment = 1 + (Double(magnitude) * 0.03)
        let amount = base * adjustment
        return (amount * 100).rounded() / 100
    }

    private static func date(
        yearMonthFrom monthDate: Date,
        day: Int,
        hour: Int,
        minute: Int,
        calendar: Calendar
    ) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: monthDate)
        components.day = day
        components.hour = hour
        components.minute = minute

        return calendar.date(from: components)
    }

    private struct DemoEntry {
        let title: String
        let amount: Double
        let date: Date
        let categoryName: String
    }
}
