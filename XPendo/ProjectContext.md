// Xpendo – Project Context

// 1. Project Title
// Xpendo

// 2. Project Overview
// Xpendo is an iOS personal expense tracking application developed as a graduation project.
// The application is designed to help individual users record, organize, review, and analyze their daily and monthly expenses in a simple and efficient way. It also supports category-based budgeting and local notification reminders to improve financial awareness and encourage regular expense tracking habits.
// Xpendo focuses on delivering a clean, practical, and user-friendly mobile experience for personal finance management.

// 3. Project Purpose
// The main purpose of Xpendo is to help users better understand and manage their spending habits.
// The application aims to:
// - make expense tracking easy and accessible
// - improve financial awareness
// - help users review where their money goes
// - support spending analysis through visual charts
// - allow users to define category-based budgets
// - help users notice overspending early
// - remind users to track expenses regularly through local notifications
// Xpendo should provide a focused and useful solution for personal financial tracking on iPhone.

// 4. Problem Statement
// Many users do not track their expenses consistently and therefore struggle to understand their spending behavior.
// Without a simple system for recording and reviewing expenses, it becomes difficult to:
// - identify spending patterns
// - control unnecessary expenses
// - stay within a budget
// - make more informed financial decisions
// Xpendo addresses this problem by offering a structured and easy-to-use mobile app for recording expenses, categorizing them, analyzing them visually, and monitoring budgets.

// 5. Target Users
// The target users of Xpendo are individual users who want to manage their personal expenses in a simple and organized way.
// Typical user expectations include:
// - adding an expense quickly
// - seeing daily and monthly spending totals
// - understanding spending by category
// - checking previous transactions
// - monitoring budget limits
// - receiving reminders to stay consistent
// Xpendo is not intended for business accounting, team finance collaboration, or enterprise-level financial systems.

// 6. Core Features
// Xpendo includes the following main features:
// - Add a new expense
// - View all expenses
// - Edit an existing expense
// - Delete an expense
// - Organize expenses by category
// - View daily and monthly summaries
// - View recent transactions
// - Analyze spending using charts
// - Set category-based budgets
// - Compare spending with budget limits
// - Show overspending indicators
// - Send local reminder notifications
// These features represent the main functional scope of the project.

// 7. Functional Scope

// 7.1 Expense Management
// Users must be able to:
// - create a new expense
// - enter title, amount, date, category, and optional note
// - view a list of recorded expenses
// - edit existing expenses
// - delete existing expenses

// 7.2 Category-Based Organization
// Users must be able to:
// - assign each expense to a category
// - review expenses according to category-based structure
// - understand how their spending is distributed across categories

// 7.3 Summaries and Tracking
// Users must be able to:
// - see daily spending information
// - see monthly spending totals
// - view recent transactions
// - identify the most significant spending areas

// 7.4 Analytics and Visualization
// Users must be able to:
// - view spending distribution by category
// - view monthly spending trends
// - interpret their spending behavior through visual charts

// 7.5 Budget Management
// Users must be able to:
// - set a budget limit for a category
// - compare current spending against that budget
// - see remaining budget
// - notice when a category budget is exceeded

// 7.6 Local Notifications
// Users must be able to:
// - receive a reminder to log expenses regularly
// - optionally receive budget-related warning reminders
// Notification support is limited to local device-based notifications.

// 8. Notification Feature
// Xpendo includes **local notifications** to support regular user engagement and budget awareness.
// Notification Goals:
// - remind users to record expenses consistently
// - help users maintain expense tracking habits
// - support budget awareness
// Planned Notification Types:
// - daily reminder notification
// - optional budget warning or reminder notification
// Notification Scope:
// - local notifications only
// - no remote push notification service
// - no server-side notification system
// This feature is intended to support usability without expanding the project into backend-dependent infrastructure.

// 9. Excluded Features
// The following features are outside the scope of the current project and should not be considered part of the main implementation unless explicitly added in the future:
// - User authentication / login / signup
// - Multi-user support
// - Cloud sync
// - Bank integration
// - Credit card integration
// - Receipt scanning
// - OCR
// - AI-based financial recommendations
// - Social features
// - Apple Watch support
// - Home screen widgets
// - Advanced exporting and reporting systems
// - Server-side backend features
// - Push notification infrastructure
// Xpendo is intentionally focused on core personal expense tracking and budgeting.

// 10. Technology Stack
// The project uses the following technologies:
// - Programming Language: Swift
// - UI Framework: SwiftUI
// - Architecture: MVVM
// - Local Persistence: SwiftData
// - Charts / Visualization: Swift Charts
// - Notification Framework: UserNotifications
// - IDE: Xcode
// - Version Control: Git / GitHub
// This stack is chosen to support modern iOS development with a clean and maintainable structure.

// 11. Architecture Overview
// Xpendo follows the MVVM (Model–View–ViewModel) architecture.

// Model
// The Model layer represents the app’s data structures and stored entities.
// Examples:
// - Expense
// - Category
// - Budget
// - AppSettings

// View
// The View layer contains SwiftUI screens and UI components that present information to the user.
// Examples:
// - Home screen
// - Expenses screen
// - Budget screen
// - Analytics screen
// - Settings screen
// - Add Expense sheet

// ViewModel
// The ViewModel layer handles:
// - business logic
// - UI state management
// - calculations
// - data transformation
// - filtering and summary logic

// Architecture Goals
// The architecture should remain:
// - simple
// - readable
// - beginner-friendly
// - modular
// - maintainable
// Xpendo should avoid unnecessary complexity and overengineering.

// 12. Application Structure
// Xpendo is structured around a few main user-facing sections.

// 12.1 Home / Dashboard
// Purpose:
// - give the user a quick overview of their financial activity
// Expected contents:
// - monthly total spending
// - today’s spending
// - top spending category
// - recent transactions
// - budget warning preview
// - access point to Settings

// 12.2 Expenses
// Purpose:
// - show all recorded expenses in a structured list
// Expected contents:
// - expense list
// - edit action
// - delete action
// - filtering support
// - empty state if no expenses exist

// 12.3 Add Expense
// Purpose:
// - allow the user to create a new expense record
// Expected contents:
// - title field
// - amount field
// - date picker
// - category selection
// - optional note field
// - validation
// - save action

// 12.4 Budget
// Purpose:
// - allow the user to define and monitor spending limits per category
// Expected contents:
// - category-based budget list
// - current spending amount
// - remaining amount
// - progress / limit usage display
// - overspending indicator

// 12.5 Analytics
// Purpose:
// - visualize expense data in an understandable way
// Expected contents:
// - category-based spending chart
// - monthly spending trend chart
// - summary insight sections

// 12.6 Settings
// Purpose:
// - provide simple app preferences and utility options
// Expected contents:
// - notification preferences
// - currency preference
// - clear data option
// - app information

// 13. Navigation Structure
// Xpendo uses a clean and simple navigation style suitable for an iPhone application.

// Main Navigation
// The main structure should use:
// - TabView
// - NavigationStack

// Main Tabs
// The main visible sections are:
// - Home
// - Expenses
// - Budget
// - Analytics

// Add Expense Presentation
// The Add Expense flow is not a separate main tab.
// It should be presented as a sheet triggered from the interface through an add action such as a plus button.

// Settings Placement
// Settings is not a separate tab.
// It should be accessed from another screen, most likely from the Home / Dashboard area.
// This navigation approach keeps the main tab bar focused and uncluttered.

// 14. Data Model Overview
// The project is centered around a small set of core data entities.

// 14.1 Expense
// Represents a single spending record.
// Suggested fields:
// - id
// - title
// - amount
// - date
// - category
// - note
// - createdAt

// 14.2 Category
// Represents an expense category.
// Suggested fields:
// - id
// - name
// - icon
// - color
// - isDefault

// 14.3 Budget
// Represents a category-based spending limit.
// Suggested fields:
// - id
// - category
// - limitAmount
// - month
// - year

// 14.4 AppSettings
// Represents lightweight app preferences.
// Suggested fields:
// - currencyCode
// - notificationsEnabled
// - dailyReminderEnabled
// - budgetWarningEnabled
// This structure is intentionally compact and suitable for a focused local iOS application.

// 15. Default Categories
// The application should start with a predefined category set to keep the initial experience simple and consistent.
// Suggested default categories:
// - Food
// - Transport
// - Shopping
// - Bills
// - Entertainment
// - Health
// - Education
// - Other
// This allows the user to begin using the app immediately without needing to build the category system manually.

// 16. UI / UX Principles
// Xpendo should follow a simple and modern design approach.

// Main UI Principles
// - clear
// - clean
// - readable
// - minimal
// - user-friendly
// - beginner-friendly
// - not visually overloaded

// UX Priorities
// - expense entry should be fast
// - important financial information should be easy to see
// - charts should be understandable
// - budget warnings should be noticeable
// - notifications should be helpful, not intrusive

// Design Direction
// The application should prioritize usability and clarity over visual complexity.

// 17. Non-Functional Expectations
// Beyond functional features, the project should also satisfy a set of quality expectations.
// Xpendo should be:
// - stable
// - organized
// - easy to navigate
// - easy to explain
// - easy to maintain
// - responsive enough for normal use
// - readable in code structure
// - appropriate for a graduation project presentation
// The project should demonstrate both practical usefulness and clean software organization.

// 18. Success Criteria
// The project will be considered successful if:
// - the app runs correctly on iPhone
// - users can add, edit, delete, and view expenses
// - expense data is stored locally and persists correctly
// - spending can be reviewed by category and time
// - charts successfully visualize expense behavior
// - budgets can be set and compared against actual spending
// - overspending can be clearly identified
// - local reminder notifications work as intended
// - the interface is simple, clear, and user-friendly
// - the implementation matches the project’s stated goals

// 19. Project Boundaries
// Xpendo is a focused mobile application for personal expense tracking.
// It is not intended to become:
// - a banking platform
// - a cloud-based finance ecosystem
// - a collaborative family finance platform
// - an AI financial advisor
// - a large-scale financial product
// Its strength should come from implementing its core functionality well, with clarity and consistency.

// 20. Final Definition
// Xpendo is a SwiftUI-based iOS graduation project that enables users to record, organize, monitor, and analyze personal expenses while also managing category-based budgets and receiving local reminder notifications.
// The project focuses on simplicity, financial awareness, clean architecture, and a practical personal finance experience for mobile users.
