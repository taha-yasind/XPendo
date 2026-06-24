# XPENDO: AN IOS-BASED PERSONAL EXPENSE TRACKING APPLICATION

## Title Page Information

| Item | Information |
|---|---|
| Project Title | XPENDO: AN IOS-BASED PERSONAL EXPENSE TRACKING APPLICATION |
| Application Name | Xpendo |
| Student Name | Taha Yasin Demirci |
| Student Number | 20212905022 |
| Advisor | Öğr. Üyesi Berc Deruni |
| Report Language | English |
| Final Submission Date | [TO BE COMPLETED] |

## Approval Page Information

| Item | Information |
|---|---|
| Advisor | Öğr. Üyesi Berc Deruni |
| Jury Member 1 | [TO BE COMPLETED] |
| Jury Member 2 | [TO BE COMPLETED] |
| Jury Member 3 | [TO BE COMPLETED] |
| Approval Date | [TO BE COMPLETED] |

## Acknowledgements

[TO BE COMPLETED]

## Abstract

Xpendo is an iOS-based personal expense tracking application developed as a graduation project. The main purpose of the application is to help individual users record, organize, monitor, and understand their daily expenses in a simple mobile interface. The application allows users to add, edit, delete, and view expenses, assign categories, manage monthly category-based budgets, view analytics, change language and theme preferences, and use an OCR-based receipt suggestion feature.

The application was developed using Swift, SwiftUI, SwiftData, Swift Charts, UserNotifications, and Vision. The project follows an MVVM-style structure where SwiftUI views are supported by ViewModels, SwiftData models, and helper services. Expense, category, budget, and app settings data are stored locally using SwiftData. The OCR feature uses Vision to read receipt text and a parser service to suggest possible expense values, but the user must review and manually save the expense. Local notification support exists for reminders and budget warnings, but real notification delivery has not yet been fully validated on a real device.

Xpendo was tested manually on Xcode Simulator and a real iPhone 13 running iOS 26.4. A small unit test suite was also added for selected business logic such as currency conversion, default categories, receipt parsing, and model initialization. The project does not include login/signup, multi-user support, bank integration, active CloudKit/iCloud synchronization, or real-time exchange rates. These limitations keep the scope suitable for a graduation project and provide clear directions for future work.

## Özet

Xpendo, mezuniyet projesi kapsamında geliştirilen iOS tabanlı bir kişisel harcama takip uygulamasıdır. Uygulamanın temel amacı, bireysel kullanıcıların günlük harcamalarını kolay bir mobil arayüz üzerinden kaydetmesine, düzenlemesine, kategorilere ayırmasına ve analiz etmesine yardımcı olmaktır. Uygulama harcama ekleme, düzenleme, silme, harcama listeleme, kategori seçimi, aylık kategori bazlı bütçe yönetimi, analiz ekranı, dil ve tema seçimi, para birimi görüntüleme ve OCR tabanlı fiş önerisi gibi özellikler sunmaktadır.

Uygulama Swift, SwiftUI, SwiftData, Swift Charts, UserNotifications ve Vision teknolojileri kullanılarak geliştirilmiştir. Projede SwiftUI ekranlarını ViewModel yapıları, SwiftData modelleri ve yardımcı servisler desteklemektedir. Harcama, kategori, bütçe ve uygulama ayarları SwiftData ile yerel olarak saklanmaktadır. OCR özelliği fiş görselinden metin okumak ve form alanları için öneri üretmek amacıyla kullanılmaktadır; ancak kullanıcı önerilen değerleri kontrol edip harcamayı manuel olarak kaydetmelidir. Yerel bildirim desteği uygulanmıştır, fakat gerçek cihazda bildirim teslimi henüz tam olarak doğrulanmamıştır.

Xpendo, Xcode Simulator ve iOS 26.4 yüklü gerçek iPhone 13 üzerinde manuel olarak test edilmiştir. Ayrıca para birimi dönüşümü, varsayılan kategoriler, fiş ayrıştırma ve model başlatma gibi temel iş mantıkları için küçük bir unit test seti eklenmiştir. Projede login/signup, çok kullanıcılı yapı, banka entegrasyonu, aktif CloudKit/iCloud senkronizasyonu veya gerçek zamanlı kur bilgisi bulunmamaktadır. Bu sınırlamalar projenin kapsamını mezuniyet projesine uygun seviyede tutmakta ve gelecekte yapılabilecek geliştirmeler için yön göstermektedir.

## Table of Contents

[TO BE COMPLETED AFTER FINAL FORMATTING IN WORD]

## List of Figures

| Figure No. | Figure Title | Source File |
|---|---|---|
| Figure 1 | Use case diagram of the Xpendo mobile application | `XPendo/Diagrams/ Use Case Flow.svg` or `XPendo/Diagrams/Xpendo App Use Case Flow-2026-06-20-093751.svg` |
| Figure 2 | MVVM-based architecture of the Xpendo iOS application | `XPendo/Diagrams/SwiftUI mvvm_architecture.svg` |
| Figure 3 | SwiftData model structure used in Xpendo | `XPendo/Diagrams/Data-Model-Diagram.svg` |
| Figure 4 | Add expense workflow in Xpendo | `XPendo/Diagrams/Add-Expense-Diagram.svg` |
| Figure 5 | OCR-based receipt suggestion workflow in Xpendo | `XPendo/Diagrams/OCR-Diagram.svg` |
| Figure 6 | Home screen | `XPendo/ScreenShots/HomeScreen.png` |
| Figure 7 | Home screen in dark mode | `XPendo/ScreenShots/HomeScreen-Dark.png` |
| Figure 8 | Add Expense screen | `XPendo/ScreenShots/Add-Expense.png` |
| Figure 9 | Expenses screen | `XPendo/ScreenShots/Expenses.png` |
| Figure 10 | Budget screen | `XPendo/ScreenShots/Budget.png` |
| Figure 11 | Analytics screen | `XPendo/ScreenShots/Analytics.png` |
| Figure 12 | Settings screen | `XPendo/ScreenShots/Settings.png` |
| Figure 13 | OCR receipt scanning screen | `XPendo/ScreenShots/OCR-Screen.png` |
| Figure 14 | Onboarding screen example | `XPendo/ScreenShots/Onboarding-1.png` |
| Figure 15 | Onboarding final screen example | `XPendo/ScreenShots/Onboarding-5.png` |

## List of Tables

| Table No. | Table Title |
|---|---|
| Table 1 | Main technologies used in the project |
| Table 2 | Main data models and purposes |
| Table 3 | Functional testing summary |
| Table 4 | Unit test summary |
| Table 5 | Project limitations and future work |

## List of Symbols / Abbreviations

| Abbreviation | Meaning |
|---|---|
| iOS | iPhone Operating System |
| UI | User Interface |
| UX | User Experience |
| MVVM | Model-View-ViewModel |
| OCR | Optical Character Recognition |
| API | Application Programming Interface |
| SDK | Software Development Kit |
| CRUD | Create, Read, Update, Delete |
| TRY | Turkish Lira |
| USD | United States Dollar |
| EUR | Euro |

# 1. INTRODUCTION

## 1.1 Overview

Personal expense tracking is an important habit for users who want to understand where their money goes and control their monthly spending. However, many people either do not track their expenses regularly or use unstructured methods such as notes, spreadsheets, or memory. This can make it difficult to review spending patterns, detect overspending, and plan a monthly budget.

Xpendo was developed as an iOS application to support simple and practical personal expense tracking. The application focuses on recording expenses, organizing them by category, comparing spending with category-based budgets, and showing visual analytics. The app also includes preferences such as theme, language, and currency selection.

## 1.2 Problem Statement

The main problem addressed by this project is the lack of a simple, local, and user-friendly way to record and review personal expenses on iOS. Users may need to add expenses quickly, review recent spending, understand category distribution, and monitor budget limits without using a complex financial application.

Xpendo solves this problem by providing a focused mobile application for manual expense tracking and local data analysis. The app does not try to become a banking platform or a multi-user finance system. Instead, it provides the essential tools needed by an individual user.

## 1.3 Aim of the Project

The aim of this project is to design and implement an iOS-based personal expense tracking application using modern Apple development tools. The application should allow users to:

* add, edit, delete, and list expenses,
* organize expenses by category,
* set category-based monthly budgets,
* view spending analytics,
* use local preferences for language, theme, and currency,
* receive local reminder support,
* use OCR as a receipt suggestion tool.

## 1.4 Scope of the Project

The project scope includes local expense management, SwiftData persistence, category management through predefined categories, budget tracking, analytics, onboarding, settings, localization, fixed-rate currency display, local notifications, and OCR-based receipt suggestions.

The project does not include login/signup, multi-user support, real bank integration, active CloudKit/iCloud synchronization, or real-time exchange rates. CloudKit/iCloud synchronization can be considered as future work, but it should not be described as an active implemented feature.

## 1.5 Target Users

The target users are individual iOS users who want to track personal expenses. The application is suitable for users who prefer a simple mobile interface, local data storage, and basic visual summaries of their spending.

# 2. BACKGROUND

## 2.1 Personal Expense Tracking

Personal expense tracking is the process of recording daily or monthly spending and reviewing it over time. It helps users become more aware of spending habits and supports better financial decisions. A mobile application is useful for this purpose because users can record expenses immediately after spending.

## 2.2 iOS Development with SwiftUI

SwiftUI is Apple's declarative framework for building user interfaces. It allows developers to describe screens using reusable views and state-driven updates. Xpendo uses SwiftUI for the main user interface, navigation, forms, cards, sheets, tab structure, and visual components.

## 2.3 Local Persistence with SwiftData

SwiftData is used in Xpendo to store application data locally. The main persisted models are `Expense`, `Category`, `Budget`, and `AppSettings`. SwiftData allows the app to keep data after restart, as long as the persistent container is created successfully.

## 2.4 MVVM Pattern

The project follows an MVVM-style structure. SwiftUI views are responsible for presentation, while ViewModels prepare data and handle logic for screens such as Home, Expenses, Budget, Analytics, Settings, Notifications, and Add Expense. Models represent persisted data.

## 2.5 OCR and Receipt Suggestion

OCR means Optical Character Recognition. In Xpendo, OCR is used to read text from receipt images. The Vision framework recognizes text, and `ReceiptParserService` tries to extract possible title, amount, date, category, or note values. This feature is only a suggestion flow. It can make mistakes, so the user must review the values before saving.

# 3. ANALYSIS

## 3.1 Functional Requirements

The main functional requirements of Xpendo are:

* The user can add a new expense.
* The user can edit an existing expense.
* The user can delete an expense.
* The user can view and filter expenses.
* The user can select a category for an expense.
* The user can set and reset monthly category budgets.
* The user can view budget status.
* The user can view analytics and charts.
* The user can change theme, language, and currency preferences.
* The user can reopen onboarding from settings.
* The user can use OCR receipt scanning as a suggestion feature.
* The user can enable local reminder settings.

## 3.2 Non-Functional Requirements

The main non-functional requirements are:

* The app should have a modern iOS interface.
* The app should support light and dark themes.
* The app should store data locally.
* The app should be simple enough for repeated daily use.
* The app should support Turkish and English localization.
* The app should not require a custom account system.
* The app should avoid unnecessary complexity for a graduation project.

## 3.3 Use Case Analysis

The main actor is the user. The user can manage expenses, budgets, analytics, preferences, OCR suggestions, and local reminders. Login/signup, cloud sync, bank integration, and multi-user support are excluded from the implemented scope.

Suggested figure: Figure 1. Use case diagram of the Xpendo mobile application.

## 3.4 Project Boundaries

Xpendo is a local personal expense tracking app. It is not a banking application, not a social or collaborative finance app, and not a cloud-based finance platform. It uses local fixed currency rates, not real-time exchange rates. CloudKit/iCloud synchronization is not active and should be listed as a limitation or future work.

# 4. DESIGN AND IMPLEMENTATION

## 4.1 System Architecture

Xpendo uses SwiftUI, MVVM-style screen organization, SwiftData models, and helper services. The user interacts with SwiftUI views. Views communicate with ViewModels. ViewModels use models and services. SwiftData stores local app data through a ModelContainer.

Suggested figure: Figure 2. MVVM-based architecture of the Xpendo iOS application.

## 4.2 Project Structure

The project is organized into data, model, feature, notification, shared, test, diagram, and screenshot folders. Feature folders include Add Expense, Analytics, Budget, Expenses, Home, Onboarding, and Settings. Shared files include theme, localization, currency conversion, and reusable UI components.

## 4.3 Data Model Design

The main data models are:

| Model | Purpose |
|---|---|
| Expense | Stores a single expense record with title, amount, date, category, note, and created date |
| Category | Stores category name, icon, color, and default status |
| Budget | Stores category-based monthly budget limit |
| AppSettings | Stores currency, theme, language, and notification preferences |

`Expense` optionally references `Category`. `Budget` also optionally references `Category`. `AppSettings` has no direct relationship with other models.

Suggested figure: Figure 3. SwiftData model structure used in Xpendo.

## 4.4 Expense Management

The Add Expense screen allows the user to enter a title, amount, date, category, and optional note. The app validates the input before saving. If the input is invalid, a validation message is shown. If the input is valid, the expense is saved to SwiftData. The Home, Expenses, Budget, and Analytics screens then update from stored data.

Suggested figure: Figure 4. Add expense workflow in Xpendo.

## 4.5 Budget Management

The Budget screen allows the user to set monthly limits for categories. It compares spending with budget limits and shows whether a category is on track or over budget. The user can update or reset budget amounts.

## 4.6 Analytics

The Analytics screen uses Swift Charts to show category breakdown and monthly trend information. It also displays simple insights such as total spending, top category, and strongest month. A donut chart is not implemented in the current project.

## 4.7 Settings and Preferences

The Settings screen includes notification preferences, theme selection, language selection, currency selection, onboarding replay, demo data utilities, and an iCloud information section. CloudKit/iCloud sync is not active. The settings screen should therefore be described as containing iCloud information or future work, not active synchronization.

## 4.8 Localization and Currency

The app supports English and Turkish localization through `Localizable.strings`. The user can switch language inside the app. Currency selection supports TRY, USD, and EUR. Conversion/display uses local fixed rates:

| Currency | Local fixed rate |
|---|---|
| TRY | 1.00 |
| USD | 45.02 |
| EUR | 52.76 |

These rates are local fixed values and not real-time exchange rates.

## 4.9 OCR Receipt Suggestion

The OCR flow allows the user to open the receipt scanner from the Add Expense screen, take a photo or select an image, and receive suggested values. The Vision framework reads text from the image. `ReceiptParserService` extracts possible values. The suggested values are applied to the form, but the user must review them before saving.

This feature should not be described as fully automatic receipt saving. It is a receipt suggestion feature and can make mistakes.

Suggested figure: Figure 5. OCR-based receipt suggestion workflow in Xpendo.

## 4.10 Navigation and UI Design

The app starts with onboarding on first launch. After onboarding, the main app contains four tabs: Home, Expenses, Budget, and Analytics. The floating add button opens the Add Expense sheet. Settings is opened from the Home screen, and the receipt scanner is opened from Add Expense.

The UI uses a modern card-based iOS style, adaptive colors, a light/dark theme system, SF Symbols, and custom reusable components such as `SurfaceCard`, `FloatingAddButton`, `ExpenseRowCard`, and `BudgetStatusCard`.

Suggested figures: Figure 6 to Figure 15 for screenshots.

# 5. TEST AND RESULTS

## 5.1 Test Environment

| Test Item | Information |
|---|---|
| Real device | iPhone 13 |
| Real device iOS version | iOS 26.4 |
| Simulator testing | Xcode Simulator |
| Simulator devices | iPhone 16, iPhone 17, iPhone 17 Pro |
| Xcode version | 26.5 |

The final report should mention simulator and real iPhone 13 testing, but it does not need to include unnecessary internal Xcode setting details unless required by the university format.

## 5.2 Manual Functional Testing

Manual testing was performed for the main user flows. The following table summarizes the main test scenarios:

| Test Case | Expected Result | Status |
|---|---|---|
| Add a new expense | Expense is saved and appears in related screens | Passed in manual testing |
| Delete an expense | Expense is removed from the list | Passed in manual testing |
| Restart app and check persistence | Saved data remains available | Passed if SwiftData persistent store is available |
| Change theme | App appearance changes according to selected theme | Passed in manual testing |
| Change language | Supported localized text changes | Passed in manual testing |
| Change currency | Amounts are displayed in selected currency using fixed local rates | Passed in manual testing |
| Set/update/reset budget | Budget entry is created, updated, or removed | Passed in manual testing |
| View analytics | Charts and summaries are displayed from saved data | Passed in manual testing |
| Open onboarding again | Onboarding can be reopened from settings | Passed in manual testing |
| OCR receipt suggestion | Suggested values are applied to the form after scanning | Passed with limitations |
| Notification behavior | Notification settings and scheduling logic exist | Implemented, but real delivery not fully validated |

## 5.3 OCR Test Result

OCR receipt scanning was tested on a real iPhone 13 using the camera. The feature works, but it is not perfect. It may detect incorrect values depending on receipt quality, lighting, text layout, and OCR result. Therefore, OCR is treated as a suggestion feature. The user must review and correct the values before saving an expense.

## 5.4 Notification Test Result

The project includes local notification logic using UserNotifications. It supports a daily reminder and a budget warning notification. However, real notification delivery has not yet been fully validated on a real device. This should be written honestly in the final report as implemented but not fully validated.

## 5.5 Automated Unit Tests

A small unit test suite was added under the `XPendoTests` target. The tests focus on accessible business logic and avoid fragile UI testing.

| Test File | Test Focus |
|---|---|
| `CurrencyConverterTests.swift` | TRY base currency, supported currencies, fixed rates, and conversion logic |
| `DefaultCategoryProviderTests.swift` | Default category list, required category names, uniqueness, and Other category |
| `ReceiptParserServiceTests.swift` | Receipt parser behavior with sample OCR text and empty input |
| `ModelInitializationTests.swift` | Basic initialization of Expense, Category, Budget, and AppSettings |

Xcode discovered the new tests and live diagnostics reported no issues in the test files. Full automated test execution could not be completed in the current environment because the local CoreSimulator service/runtime was unavailable and the Mac destination was blocked by provisioning. Therefore, the project currently relies mainly on manual functional testing, supported by limited unit tests for core logic.

## 5.6 Test Result Summary

The main user-facing features were tested manually on simulator and iPhone 13. The app is suitable for demonstration as a local personal expense tracking application. The main remaining testing gaps are full real-device notification delivery validation, broader automated UI testing, and final testing after the report screenshots are inserted.

# 6. CONCLUSION

Xpendo was developed as an iOS-based personal expense tracking application for individual users. The project successfully implements the main features required for a graduation-level mobile app: expense management, category selection, budgeting, analytics, settings, localization, theme support, fixed-rate currency display, onboarding, local notification logic, and OCR-based receipt suggestions.

The project uses modern Apple technologies such as SwiftUI, SwiftData, Swift Charts, UserNotifications, and Vision. The MVVM-style architecture keeps the user interface, business logic, models, and helper services reasonably separated. SwiftData provides local persistence for the main app data.

The project also has clear limitations. It does not implement login/signup, multi-user support, real bank integration, active CloudKit/iCloud synchronization, advanced AI analytics, or real-time exchange rates. OCR is not fully reliable and must be treated as a suggestion tool. Notification delivery still requires full real-device validation.

As future work, the app could add real CloudKit/iCloud synchronization, real-time exchange rate support, stronger automated tests, improved OCR accuracy, export features, and more advanced analytics. Overall, Xpendo meets the main goal of providing a simple and useful personal expense tracking experience on iOS.

# Bibliography

[TO BE COMPLETED]

Suggested source types to add later:

* Apple Swift documentation
* Apple SwiftUI documentation
* Apple SwiftData documentation
* Apple Swift Charts documentation
* Apple UserNotifications documentation
* Apple Vision OCR documentation
* Any academic or technical sources used in the final report

# Appendices

## Appendix A. Diagram Drafts

Diagram source material is available in `XPendo/GRADUATION_REPORT_DIAGRAMS.md`.

## Appendix B. Project Information Notes

Detailed project analysis notes are available in `XPendo/GRADUATION_REPORT_PROJECT_INFO.md`.

## Appendix C. Screenshots

Available screenshot files:

* `XPendo/ScreenShots/HomeScreen.png`
* `XPendo/ScreenShots/HomeScreen-Dark.png`
* `XPendo/ScreenShots/Add-Expense.png`
* `XPendo/ScreenShots/Expenses.png`
* `XPendo/ScreenShots/Budget.png`
* `XPendo/ScreenShots/Analytics.png`
* `XPendo/ScreenShots/Settings.png`
* `XPendo/ScreenShots/OCR-Screen.png`
* `XPendo/ScreenShots/Onboarding-1.png`
* `XPendo/ScreenShots/Onboarding-5.png`

## Appendix D. Source Code and Test Files

Important source folders:

* `XPendo/Data`
* `XPendo/Models`
* `XPendo/Features`
* `XPendo/Shared`
* `XPendo/Notifications`
* `XPendoTests`

## Appendix E. Remaining Items Before Final Submission

* Jury member names: [TO BE COMPLETED]
* Approval date: [TO BE COMPLETED]
* Final submission date: [TO BE COMPLETED]
* Acknowledgements text: [TO BE COMPLETED]
* Bibliography details: [TO BE COMPLETED]
* Final manual test notes: [TO BE COMPLETED]
* Notification real-device delivery result, if tested later: [TO BE COMPLETED]
* Any final known bugs observed before submission: [TO BE COMPLETED]
