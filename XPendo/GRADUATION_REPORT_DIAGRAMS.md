# Xpendo Graduation Report Diagram Drafts

This file contains simple Mermaid diagram drafts for the Xpendo graduation report and final presentation. The diagrams reflect the current project scope: local expense tracking, SwiftData persistence, local notifications, OCR-based receipt suggestions, localization, theme/currency settings, budgeting, and analytics. Login/signup, multi-user support, bank integration, and active CloudKit/iCloud sync are intentionally not shown as implemented features.

## 1. Use Case Diagram

### Purpose

This diagram summarizes the main actions that a user can perform in the Xpendo app.

```mermaid
flowchart LR
    User([User])

    subgraph Xpendo["Xpendo App Use Cases"]
        AddExpense["Add expense"]
        ViewExpenses["View expenses"]
        EditExpense["Edit expense"]
        DeleteExpense["Delete expense"]
        SelectCategory["Select category"]
        SetBudget["Set budget"]
        ViewBudget["View budget status"]
        ViewAnalytics["View analytics"]
        ChangeSettings["Change settings"]
        SelectLanguage["Select language"]
        SelectTheme["Select theme"]
        SelectCurrency["Select currency"]
        OCRSuggestion["Use OCR receipt suggestion"]
        EnableReminders["Enable local reminders"]
    end

    User --> AddExpense
    User --> ViewExpenses
    User --> EditExpense
    User --> DeleteExpense
    User --> SelectCategory
    User --> SetBudget
    User --> ViewBudget
    User --> ViewAnalytics
    User --> ChangeSettings
    User --> OCRSuggestion
    User --> EnableReminders

    ChangeSettings --> SelectLanguage
    ChangeSettings --> SelectTheme
    ChangeSettings --> SelectCurrency
    AddExpense --> SelectCategory
    AddExpense --> OCRSuggestion
```

### Short Explanation

The user can record and manage expenses, select categories, manage budgets, view analytics, change preferences, use OCR as a receipt suggestion tool, and enable local reminders. The diagram does not include login, cloud sync, bank integration, or multi-user support because these are not implemented as active app features.

### Suggested Report Placement

Requirements Analysis or System Analysis section.

### Suggested Figure Caption

Figure X. Use case diagram of the Xpendo mobile application.

## 2. MVVM Architecture Diagram

### Purpose

This diagram shows the high-level architecture of Xpendo and how SwiftUI views, ViewModels, SwiftData models, services, and iOS frameworks work together.

```mermaid
flowchart TB
    User([User])

    subgraph UI["Presentation Layer"]
        Views["SwiftUI Views<br/>Home, Expenses, Budget, Analytics,<br/>Settings, Add Expense, Onboarding"]
    end

    subgraph VM["ViewModel Layer"]
        ViewModels["ViewModels<br/>HomeViewModel, ExpensesViewModel,<br/>BudgetViewModel, AnalyticsViewModel,<br/>SettingsViewModel, AddExpenseViewModel"]
    end

    subgraph Data["Data Layer"]
        Models["SwiftData Models<br/>Expense, Category, Budget, AppSettings"]
        Container["SwiftData ModelContainer<br/>Local persistence"]
    end

    subgraph Services["Services / Managers / Helpers"]
        NotificationManager["LocalNotificationManager"]
        OCRService["ReceiptOCRService"]
        ParserService["ReceiptParserService"]
        Currency["CurrencyConverter"]
        Localization["AppLocalization"]
    end

    subgraph Frameworks["iOS Frameworks"]
        SwiftUIFW["SwiftUI"]
        SwiftDataFW["SwiftData"]
        ChartsFW["Swift Charts"]
        NotificationsFW["UserNotifications"]
        VisionFW["Vision"]
    end

    User --> Views
    Views --> ViewModels
    Views -. "display/query data" .-> Models
    ViewModels --> Models
    ViewModels --> Services
    Models --> Container
    Container --> SwiftDataFW

    Views --> SwiftUIFW
    Views --> ChartsFW
    NotificationManager --> NotificationsFW
    OCRService --> VisionFW
    ParserService --> ViewModels
    Currency --> ViewModels
    Localization --> Views
```

### Short Explanation

The user interacts with SwiftUI screens. The screens use ViewModels for business logic and SwiftData models for local data. Services support notifications, OCR, receipt parsing, currency conversion, and localization. SwiftData stores app data locally through the ModelContainer.

### Suggested Report Placement

System Design or Software Architecture section.

### Suggested Figure Caption

Figure X. MVVM-based architecture of the Xpendo iOS application.

## 3. Data Model / Class Diagram

### Purpose

This diagram shows the main persistent data models used by the app and their relationships.

```mermaid
classDiagram
    class Expense {
        UUID id
        String title
        Double amount
        Date date
        Category? category
        String? note
        Date createdAt
    }

    class Category {
        UUID id
        String name
        String icon
        String color
        Bool isDefault
    }

    class Budget {
        UUID id
        Category? category
        Double limitAmount
        Int month
        Int year
    }

    class AppSettings {
        UUID id
        String currencyCode
        String? preferredThemeCode
        String? preferredLanguageCode
        Bool notificationsEnabled
        Bool dailyReminderEnabled
        Bool budgetWarningEnabled
    }

    Expense "0..*" --> "0..1" Category : references
    Budget "0..*" --> "0..1" Category : references
```

### Short Explanation

`Expense` stores spending records and can reference a category. `Budget` stores monthly category-based limits and can also reference a category. `Category` stores predefined category information. `AppSettings` stores app preferences and notification options without direct relationships to other models.

### Suggested Report Placement

Database Design, Data Model, or Implementation section.

### Suggested Figure Caption

Figure X. SwiftData model structure used in Xpendo.

## 4. Add Expense Flow Diagram

### Purpose

This diagram explains how a new expense is manually added and saved in the app.

```mermaid
flowchart TD
    Start([User taps floating add button])
    Sheet["Add Expense sheet opens"]
    Form["User enters title, amount, date,<br/>category, and optional note"]
    Validate{"Is input valid?"}
    Error["Show validation message"]
    Save["Save Expense to SwiftData"]
    Close["Close Add Expense sheet"]
    Update["Home, Expenses, Budget,<br/>and Analytics update from stored data"]

    Start --> Sheet
    Sheet --> Form
    Form --> Validate
    Validate -- No --> Error
    Error --> Form
    Validate -- Yes --> Save
    Save --> Close
    Close --> Update
```

### Short Explanation

The user opens the Add Expense sheet, enters the required details, and the app validates the input. Invalid input shows a validation message. Valid input is saved to SwiftData, then the related screens update from the stored data.

### Suggested Report Placement

Implementation, User Flow, or Functional Design section.

### Suggested Figure Caption

Figure X. Add expense workflow in Xpendo.

## 5. OCR Receipt Suggestion Flow Diagram

### Purpose

This diagram shows how OCR helps fill the Add Expense form. It clearly shows that OCR provides suggestions only and does not automatically save an expense.

```mermaid
flowchart TD
    Start([User opens receipt scanner<br/>from Add Expense screen])
    Source{"Choose image source"}
    Camera["Take photo with camera"]
    Gallery["Select image from gallery"]
    Image["Image is selected"]
    OCR["Vision OCR reads text<br/>from the image"]
    Parser["ReceiptParserService extracts<br/>suggested title, amount, date,<br/>category, or note if possible"]
    Apply["Suggested values are applied<br/>to Add Expense form"]
    Review["User reviews suggestions<br/>because OCR can make mistakes"]
    Decision{"User accepts or edits values?"}
    Edit["User manually edits fields"]
    Save["User manually saves expense"]
    Stored["Expense is saved to SwiftData"]

    Start --> Source
    Source -- Camera --> Camera
    Source -- Gallery --> Gallery
    Camera --> Image
    Gallery --> Image
    Image --> OCR
    OCR --> Parser
    Parser --> Apply
    Apply --> Review
    Review --> Decision
    Decision -- Edit needed --> Edit
    Edit --> Save
    Decision -- Looks correct --> Save
    Save --> Stored

    Parser -. "Suggestion only<br/>no automatic save" .-> Review
```

### Short Explanation

The OCR feature reads text from a receipt image and uses parser logic to suggest possible expense values. The app does not automatically save the expense after OCR. The user must review, correct if necessary, and manually save the expense.

### Suggested Report Placement

Implementation, OCR Feature, or User Flow section.

### Suggested Figure Caption

Figure X. OCR-based receipt suggestion workflow in Xpendo.

## 6. Navigation Flow Diagram

### Purpose

This diagram describes the main navigation structure of the app.

```mermaid
flowchart TD
    Launch([App launch])
    FirstLaunch{"First launch?"}
    Onboarding["Onboarding screens"]
    Main["Main app"]

    subgraph Tabs["Main tabs"]
        Home["Home"]
        Expenses["Expenses"]
        Budget["Budget"]
        Analytics["Analytics"]
    end

    AddButton["Floating Add Button"]
    AddSheet["Add Expense sheet"]
    Settings["Settings screen"]
    ReceiptScanner["Receipt Scanner"]

    Launch --> FirstLaunch
    FirstLaunch -- Yes --> Onboarding
    Onboarding --> Main
    FirstLaunch -- No --> Main

    Main --> Home
    Main --> Expenses
    Main --> Budget
    Main --> Analytics

    Home --> Settings
    Main --> AddButton
    AddButton --> AddSheet
    AddSheet --> ReceiptScanner
```

### Short Explanation

On first launch, the user sees onboarding. After onboarding, the main app opens with four tabs: Home, Expenses, Budget, and Analytics. The floating add button opens the Add Expense sheet. Settings is opened from Home, and the receipt scanner is opened from the Add Expense screen.

### Suggested Report Placement

UI/UX Design, Navigation Design, or Implementation section.

### Suggested Figure Caption

Figure X. Main navigation flow of the Xpendo application.

## Export Instructions

1. Copy one Mermaid code block from this file.
2. Open Mermaid Live Editor.
3. Paste the copied Mermaid code into the editor.
4. Export the diagram as PNG or SVG.
5. Insert the exported diagram into the graduation report or presentation.
