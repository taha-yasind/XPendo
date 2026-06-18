# Xpendo - Project Context

## 1. Project Title

Xpendo

---

## 2. Project Overview

Xpendo is an iOS personal expense tracking application developed as a graduation project.

The application is designed to help individual users record, organize, review, and analyze their daily and monthly expenses in a simple and efficient way. It also supports category-based budgeting, local notification reminders, and iCloud-based data synchronization to improve financial awareness, encourage regular expense tracking habits, and reduce the risk of data loss when the app is deleted or reinstalled.

Xpendo focuses on delivering a clean, practical, user-friendly, and iOS-native mobile experience for personal finance management.

---

## 3. Project Purpose

The main purpose of Xpendo is to help users better understand and manage their spending habits.

The application aims to:

* make expense tracking easy and accessible
* improve financial awareness
* help users review where their money goes
* support spending analysis through visual charts
* allow users to define category-based budgets
* help users notice overspending early
* remind users to track expenses regularly through local notifications
* preserve user data more reliably by supporting iCloud / CloudKit synchronization
* allow users to recover their expense data after reinstalling the app, as long as they use the same Apple ID and iCloud account

Xpendo should provide a focused and useful solution for personal financial tracking on iPhone.

---

## 4. Problem Statement

Many users do not track their expenses consistently and therefore struggle to understand their spending behavior.

Without a simple system for recording and reviewing expenses, it becomes difficult to:

* identify spending patterns
* control unnecessary expenses
* stay within a budget
* make more informed financial decisions

Additionally, if an expense tracking app stores all data only in a local database, the user may lose all recorded expenses when the application is deleted or reinstalled. This creates a serious usability and reliability problem because expense records are personal and long-term data.

Xpendo addresses these problems by offering a structured and easy-to-use mobile app for recording expenses, categorizing them, analyzing them visually, monitoring budgets, and syncing user data through iCloud / CloudKit to reduce data loss risk.

---

## 5. Target Users

The target users of Xpendo are individual users who want to manage their personal expenses in a simple and organized way.

Typical user expectations include:

* adding an expense quickly
* seeing daily and monthly spending totals
* understanding spending by category
* checking previous transactions
* monitoring budget limits
* receiving reminders to stay consistent
* keeping their data safe after app reinstall
* accessing their data again when using the same Apple ID and iCloud account

Xpendo is not intended for business accounting, team finance collaboration, or enterprise-level financial systems.

---

## 6. Core Features

Xpendo includes the following main features:

* Add a new expense
* View all expenses
* Edit an existing expense
* Delete an expense
* Organize expenses by category
* View daily and monthly summaries
* View recent transactions
* Analyze spending using charts
* Set category-based budgets
* Compare spending with budget limits
* Show overspending indicators
* Send local reminder notifications
* Store data locally using SwiftData
* Synchronize user data with iCloud using CloudKit

These features represent the main functional scope of the project.

---

## 7. Functional Scope

### 7.1 Expense Management

Users must be able to:

* create a new expense
* enter title, amount, date, category, and optional note
* view a list of recorded expenses
* edit existing expenses
* delete existing expenses

### 7.2 Category-Based Organization

Users must be able to:

* assign each expense to a category
* review expenses according to category-based structure
* understand how their spending is distributed across categories

### 7.3 Summaries and Tracking

Users must be able to:

* see daily spending information
* see monthly spending totals
* view recent transactions
* identify the most significant spending areas

### 7.4 Analytics and Visualization

Users must be able to:

* view spending distribution by category
* view monthly spending trends
* interpret their spending behavior through visual charts

### 7.5 Budget Management

Users must be able to:

* set a budget limit for a category
* compare current spending against that budget
* see remaining budget
* notice when a category budget is exceeded

### 7.6 Local Notifications

Users must be able to:

* receive a reminder to log expenses regularly
* optionally receive budget-related warning reminders

Notification support is limited to local device-based notifications.

### 7.7 iCloud / CloudKit Synchronization

Users should be able to:

* keep their expense data available after app reinstall when signed into the same Apple ID
* synchronize personal expense data through the user's private iCloud database
* use the app without creating a separate Xpendo account
* continue using local data storage even when internet access is temporarily unavailable
* benefit from automatic sync behavior where supported by SwiftData and CloudKit

The iCloud sync feature should remain user-focused and simple. It should not introduce a custom backend, custom login system, or multi-user collaboration.

---

## 8. Notification Feature

Xpendo includes local notifications to support regular user engagement and budget awareness.

### Notification Goals

* remind users to record expenses consistently
* help users maintain expense tracking habits
* support budget awareness

### Planned Notification Types

* daily reminder notification
* optional budget warning or reminder notification

### Notification Scope

* local notifications only
* no remote push notification service
* no server-side notification system

This feature is intended to support usability without expanding the project into backend-dependent infrastructure.

---

## 9. iCloud / CloudKit Sync Feature

Xpendo includes iCloud / CloudKit synchronization to reduce data loss risk and improve continuity for users.

### Sync Goals

* prevent permanent data loss when the app is deleted and reinstalled
* allow user data to be restored through the same Apple ID and iCloud account
* keep the app aligned with native iOS ecosystem features
* avoid building a separate authentication system
* avoid introducing a custom backend service

### Sync Scope

The sync feature should cover the app's main user-generated data:

* expenses
* budgets
* categories if stored as user-modifiable records
* app settings where technically appropriate

### Sync Model

The preferred sync model is:

* SwiftData for local persistence
* CloudKit / iCloud for private user data synchronization
* local-first usage, meaning the app should remain usable even when offline
* automatic synchronization where supported by SwiftData and CloudKit

### Important Boundaries

The sync feature is not intended to become:

* a custom backend system
* a Firebase-based system
* a Supabase-based system
* a REST API system
* a multi-user sharing system
* a collaborative budgeting system
* a social finance system
* a bank account integration system

### User Account Policy

Xpendo should not implement its own login, signup, password, or user account system.

The user's Apple ID / iCloud account should be the only account layer involved in synchronization.

### Expected User Experience

The user should not need to manually manage technical sync details.

The Settings screen may show a simple iCloud Sync section, such as:

* iCloud Sync information
* sync availability message
* simple explanation that data can be restored when using the same Apple ID
* optional troubleshooting message if iCloud is unavailable

The app should avoid complex cloud status screens.

---

## 10. Excluded Features

The following features are outside the scope of the current project and should not be considered part of the main implementation unless explicitly added in the future:

* Custom user authentication / login / signup
* Email and password accounts
* Multi-user support
* Shared family budgets
* Collaborative budgeting
* Bank integration
* Credit card integration
* Receipt scanning
* OCR
* AI-based financial recommendations
* Social features
* Apple Watch support
* Home screen widgets
* Advanced exporting and reporting systems
* Server-side backend features
* Push notification infrastructure
* Firebase backend
* Supabase backend
* Custom REST API backend

Important clarification:

* iCloud / CloudKit synchronization is included in the project scope.
* Custom cloud backend systems are excluded from the project scope.

---

## 11. Technology Stack

The project uses the following technologies:

* Programming Language: Swift
* UI Framework: SwiftUI
* Architecture: MVVM
* Local Persistence: SwiftData
* Cloud Synchronization: CloudKit / iCloud
* Charts / Visualization: Swift Charts
* Notification Framework: UserNotifications
* IDE: Xcode
* Version Control: Git / GitHub

This stack is chosen to support modern iOS development with a clean and maintainable structure.

---

## 12. Architecture Overview

Xpendo follows the MVVM architecture.

### Model

The Model layer represents the app's data structures and stored entities.

Examples:

* Expense
* Category
* Budget
* AppSettings

Models should remain simple, readable, and compatible with SwiftData persistence.

Because iCloud / CloudKit synchronization is part of the project scope, model design should also avoid unnecessary complexity and should remain suitable for SwiftData + CloudKit usage.

### View

The View layer contains SwiftUI screens and UI components that present information to the user.

Examples:

* Home screen
* Expenses screen
* Budget screen
* Analytics screen
* Settings screen
* Add Expense sheet

### ViewModel

The ViewModel layer handles:

* business logic
* UI state management
* calculations
* data transformation
* filtering and summary logic
* sync-related user-facing state if needed

The ViewModel layer should not become overloaded with direct CloudKit implementation details unless necessary.

### Persistence Layer

The persistence layer should be based on:

* SwiftData local storage
* CloudKit-backed synchronization where supported
* a simple app-level ModelContainer configuration

The persistence setup should remain beginner-friendly and explainable for a graduation project presentation.

### Architecture Goals

The architecture should remain:

* simple
* readable
* beginner-friendly
* modular
* maintainable
* local-first
* iOS-native

Xpendo should avoid unnecessary complexity and overengineering.

---

## 13. Application Structure

Xpendo is structured around a few main user-facing sections.

### 13.1 Home / Dashboard

Purpose:

* give the user a quick overview of their financial activity

Expected contents:

* monthly total spending
* today's spending
* top spending category
* recent transactions
* budget warning preview
* access point to Settings

### 13.2 Expenses

Purpose:

* show all recorded expenses in a structured list

Expected contents:

* expense list
* edit action
* delete action
* filtering support
* empty state if no expenses exist

### 13.3 Add Expense

Purpose:

* allow the user to create a new expense record

Expected contents:

* title field
* amount field
* date picker
* category selection
* optional note field
* validation
* save action

### 13.4 Budget

Purpose:

* allow the user to define and monitor spending limits per category

Expected contents:

* category-based budget list
* current spending amount
* remaining amount
* progress / limit usage display
* overspending indicator

### 13.5 Analytics

Purpose:

* visualize expense data in an understandable way

Expected contents:

* category-based spending chart
* monthly spending trend chart
* summary insight sections

### 13.6 Settings

Purpose:

* provide simple app preferences and utility options

Expected contents:

* notification preferences
* currency preference
* theme preference if implemented
* language preference if implemented
* iCloud Sync information
* clear/reset data option
* app information

Settings should remain simple and supportive. It should not become a full account management screen.

---

## 14. Navigation Structure

Xpendo uses a clean and simple navigation style suitable for an iPhone application.

### Main Navigation

The main structure should use:

* TabView
* NavigationStack

### Main Tabs

The main visible sections are:

* Home
* Expenses
* Budget
* Analytics

### Add Expense Presentation

The Add Expense flow is not a separate main tab.

It should be presented as a sheet triggered from the interface through an add action such as a plus button.

### Settings Placement

Settings is not a separate tab.

It should be accessed from another screen, most likely from the Home / Dashboard area.

This navigation approach keeps the main tab bar focused and uncluttered.

---

## 15. Data Model Overview

The project is centered around a small set of core data entities.

### 15.1 Expense

Represents a single spending record.

Suggested fields:

* id
* title
* amount
* date
* category
* note
* createdAt

CloudKit-related note:

* Expense should be designed in a SwiftData-friendly and CloudKit-compatible way.
* Avoid unnecessary uniqueness constraints or complex relationships unless technically verified.
* Fields should have safe defaults where needed.
* Optional values should be used carefully and intentionally.

### 15.2 Category

Represents an expense category.

Suggested fields:

* id
* name
* icon
* color
* isDefault

CloudKit-related note:

* Default categories should not be duplicated repeatedly after sync or reinstall.
* Default category seeding should be controlled with a safe one-time initialization strategy.
* If categories are user-editable, they may need to be persisted and synced.
* If categories are fixed, they may be treated as app-defined reference data.

### 15.3 Budget

Represents a category-based spending limit.

Suggested fields:

* id
* category
* limitAmount
* month
* year

CloudKit-related note:

* Budget records should sync with user data where technically appropriate.
* Budget identity and category association should be kept simple and reliable.

### 15.4 AppSettings

Represents lightweight app preferences.

Suggested fields:

* currencyCode
* notificationsEnabled
* dailyReminderEnabled
* budgetWarningEnabled
* selectedTheme
* selectedLanguage
* iCloudSyncInfoAcknowledged if needed

CloudKit-related note:

* Not every setting must be synced.
* Device-specific preferences may remain local.
* User financial data should be prioritized over purely visual settings.

---

## 16. Default Categories

The application should start with a predefined category set to keep the initial experience simple and consistent.

Suggested default categories:

* Food
* Transport
* Shopping
* Bills
* Entertainment
* Health
* Education
* Other

This allows the user to begin using the app immediately without needing to build the category system manually.

Default category seeding must be handled carefully so that:

* categories are not duplicated on every launch
* deleted categories do not unexpectedly reappear unless intentionally restored
* sync or reinstall does not create repeated default records
* the Other category remains available and should usually appear last in category lists

---

## 17. UI / UX Principles

Xpendo should follow a simple and modern design approach.

### Main UI Principles

* clear
* clean
* readable
* minimal
* user-friendly
* beginner-friendly
* not visually overloaded

### UX Priorities

* expense entry should be fast
* important financial information should be easy to see
* charts should be understandable
* budget warnings should be noticeable
* notifications should be helpful, not intrusive
* iCloud sync should be understandable but not distracting

### Design Direction

The application should prioritize usability and clarity over visual complexity.

Cloud sync should be presented as a reliability improvement, not as the main product identity.

---

## 18. Non-Functional Expectations

Beyond functional features, the project should also satisfy a set of quality expectations.

Xpendo should be:

* stable
* organized
* easy to navigate
* easy to explain
* easy to maintain
* responsive enough for normal use
* readable in code structure
* appropriate for a graduation project presentation
* reliable in data persistence
* resilient against app reinstall data loss when iCloud sync is available

The project should demonstrate both practical usefulness and clean software organization.

---

## 19. Success Criteria

The project will be considered successful if:

* the app runs correctly on iPhone
* users can add, edit, delete, and view expenses
* expense data is stored locally and persists correctly
* expense data can sync through iCloud / CloudKit when configured and available
* users can recover their data after reinstall when using the same Apple ID and iCloud account
* spending can be reviewed by category and time
* charts successfully visualize expense behavior
* budgets can be set and compared against actual spending
* overspending can be clearly identified
* local reminder notifications work as intended
* the interface is simple, clear, and user-friendly
* the implementation matches the project's stated goals

---

## 20. Project Boundaries

Xpendo is a focused mobile application for personal expense tracking.

It is not intended to become:

* a banking platform
* a cloud-based finance ecosystem
* a collaborative family finance platform
* an AI financial advisor
* a large-scale financial product
* a social finance platform

The app may use iCloud / CloudKit to protect and synchronize personal user data, but this should not expand the project into a custom backend product.

Its strength should come from implementing its core functionality well, with clarity and consistency.

---

## 21. Final Definition

Xpendo is a SwiftUI-based iOS graduation project that enables users to record, organize, monitor, and analyze personal expenses while also managing category-based budgets, receiving local reminder notifications, and preserving user data through iCloud / CloudKit synchronization.

The project focuses on simplicity, financial awareness, clean architecture, iOS-native data persistence, and a practical personal finance experience for mobile users.
