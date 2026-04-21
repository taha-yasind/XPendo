# Xpendo – Development Plan

## 1. Purpose of This Document
This document defines the implementation order of the Xpendo project.

Its purpose is to ensure that the project is developed:
- in the correct sequence
- in manageable phases
- with clear boundaries
- with efficient AI-assisted prompting
- without unnecessary scope drift

This file should be used together with `PROJECT_CONTEXT.md`.

### Document Roles
- `PROJECT_CONTEXT.md` explains **what the project is**
- `DEVELOPMENT_PLAN.md` explains **how the project should be developed**

---

## 2. Development Strategy
Xpendo should be developed **phase by phase**, not by random feature additions and not by extremely small micro-steps.

The implementation should follow a structured order so that:
- the foundation is stable before advanced features are added
- data models exist before feature screens depend on them
- core expense flows are completed before analytics and budgeting
- the app remains clean, understandable, and maintainable

The goal is to balance:
- implementation control
- development speed
- token efficiency when using AI coding assistants
- beginner-friendly progress

---

## 3. AI Collaboration Rules
When using Codex or Claude during development, the assistant must follow these rules:

- Always follow `PROJECT_CONTEXT.md`
- Always follow `DEVELOPMENT_PLAN.md`
- Implement only the currently requested phase
- Do not move to the next phase without approval
- Do not add out-of-scope features
- Keep the code simple and beginner-friendly
- Keep architecture consistent with MVVM
- Keep file changes focused and relevant
- Prefer small, meaningful implementation batches
- Summarize all file changes after each completed phase
- Ask only when a major product or architecture decision is required

---

## 4. Approval Strategy
Development should proceed with **phase-level approval**, not approval after every tiny action.

### Rules
- The AI assistant may complete all tasks inside the current phase without stopping after every minor step
- The AI assistant must stop at the end of the current phase
- The AI assistant must wait for approval before starting the next phase
- The AI assistant should interrupt only if a major blocking decision is needed

### Reason
This approach is used to:
- reduce unnecessary token usage
- avoid fragmented conversations
- keep implementation efficient
- maintain enough control over project direction

---

## 5. Phase Overview
The project is divided into **10 main phases**:

1. Project Foundation
2. Core Data Models and Persistence Setup
3. Add Expense Flow
4. Expenses List and Management
5. Home / Dashboard
6. Analytics
7. Budget Management
8. Local Notifications
9. Settings
10. Final Polish and Stabilization

This order should be preserved unless a strong technical reason requires adjustment.

---

## 6. Phase 1 – Project Foundation

### Goal
Transform the default Xcode template into a clean app skeleton that matches the structure of the Xpendo project.

### Scope
This phase includes:
- cleaning the default template
- creating the base app structure
- creating the initial screen skeleton
- setting up the main navigation structure
- preparing the project for future phases

### Main Tasks
- Replace the default Hello World style screen
- Set up a clean app entry structure
- Create the initial folder/group structure if needed
- Set up `TabView`
- Set up `NavigationStack`
- Create placeholder screens for:
  - Home
  - Expenses
  - Budget
  - Analytics
- Add an entry point for presenting the Add Expense flow as a **sheet**
- Add a clear access point for Settings from Home
- Keep everything simple and placeholder-based for now

### Exclusions
This phase should **not** include:
- business logic
- persistence logic
- real expense handling
- analytics calculations
- budgeting logic
- notifications logic

### Exit Criteria
This phase is complete when:
- the app opens into a clean tab-based structure
- all main placeholder sections are reachable
- Add Expense is conceptually prepared as a sheet entry point
- Settings is not a separate tab
- the project feels like a structured app skeleton rather than a default template

---

## 7. Phase 2 – Core Data Models and Persistence Setup

### Goal
Create the core data layer of the application and prepare local persistence.

### Scope
This phase includes:
- defining the main models
- preparing local data persistence
- preparing app-level settings storage
- establishing the data foundation for future features

### Main Tasks
- Create the `Expense` model
- Create the `Category` model
- Create the `Budget` model
- Create the `AppSettings` model if needed
- Configure SwiftData for the project
- Prepare the default category set
- Keep model design simple and readable
- Ensure the models match project scope

### Exclusions
This phase should **not** include:
- full UI flows
- add expense form UI
- analytics charts
- budget comparison screens
- notification UI

### Exit Criteria
This phase is complete when:
- the main data models exist
- SwiftData is integrated at a usable basic level
- the project has a clear local persistence foundation
- default categories are defined or prepared
- future phases can safely depend on the data layer

---

## 8. Phase 3 – Add Expense Flow

### Goal
Allow the user to create and save an expense through the Add Expense sheet.

### Scope
This phase includes:
- building the Add Expense user interface
- validating user input
- saving the created expense
- dismissing the sheet correctly

### Main Tasks
- Create the Add Expense sheet view
- Add a title input field
- Add an amount input field
- Add a date picker
- Add a category selector
- Add an optional note field
- Add validation for invalid or missing input
- Save the expense using the data layer
- Dismiss the sheet after successful save
- Ensure the app is ready to reflect the new data

### Exclusions
This phase should **not** include:
- full expense editing
- advanced filtering
- analytics logic
- budget calculations
- notification settings

### Exit Criteria
This phase is complete when:
- the Add Expense sheet opens correctly
- the user can enter valid expense data
- invalid input is handled properly
- a valid expense can be saved locally
- the save flow works cleanly from the UI perspective

---

## 9. Phase 4 – Expenses List and Management

### Goal
Allow the user to view and manage saved expenses.

### Scope
This phase includes:
- listing expenses
- showing them in a clear structure
- enabling edit and delete actions
- supporting a basic filtering experience

### Main Tasks
- Create the Expenses list screen
- Display all saved expenses
- Create an expense row/card structure
- Add delete functionality
- Add edit functionality
- Add an empty state when no data exists
- Add basic filtering support
- Keep the list readable and organized

### Exclusions
This phase should **not** include:
- dashboard summaries
- analytics charts
- budget progress logic
- notification preference management

### Exit Criteria
This phase is complete when:
- saved expenses can be viewed in a list
- expenses can be deleted
- expenses can be edited
- the screen handles empty data gracefully
- the user has basic control over recorded expense data

---

## 10. Phase 5 – Home / Dashboard

### Goal
Provide a quick overview of the user’s spending situation.

### Scope
This phase includes:
- summary information
- recent activity display
- quick financial insight at app launch

### Main Tasks
- Show today’s total spending
- Show current monthly total spending
- Show recent expenses
- Show top spending category
- Show a small budget preview or warning section
- Provide Settings access from Home
- Keep the dashboard simple and informative

### Exclusions
This phase should **not** include:
- detailed analytics charts beyond summary visuals if not needed
- full budgeting interface
- notification settings panel

### Exit Criteria
This phase is complete when:
- the Home screen gives meaningful summary information
- users can quickly understand current spending status
- recent transactions are visible
- Settings access exists from the dashboard area

---

## 11. Phase 6 – Analytics

### Goal
Visualize expense behavior using charts and summaries.

### Scope
This phase includes:
- expense aggregation
- chart preparation
- category-based and time-based visual analysis

### Main Tasks
- Calculate spending totals by category
- Calculate monthly trend totals
- Build a category-based spending chart
- Build a monthly spending trend chart
- Add a summary insights section if useful
- Keep charts clear and easy to read
- Ensure the analytics reflect actual stored expense data

### Exclusions
This phase should **not** include:
- budget creation UI
- notification reminders
- advanced reporting systems

### Exit Criteria
This phase is complete when:
- expense data is grouped correctly
- category spending can be visualized
- monthly spending trends can be visualized
- the analytics screen adds real value to the app

---

## 12. Phase 7 – Budget Management

### Goal
Allow users to define category-based budgets and compare real spending against them.

### Scope
This phase includes:
- creating budgets
- showing current usage against budget limits
- warning the user about overspending

### Main Tasks
- Create the Budget screen structure
- Allow users to define a budget per category
- Show current spending for each budgeted category
- Show remaining budget
- Show budget usage progress
- Show overspending indicators
- Keep the budgeting system month-oriented and simple

### Exclusions
This phase should **not** include:
- cloud-based syncing
- advanced financial planning
- collaborative budgeting

### Exit Criteria
This phase is complete when:
- users can create or define category budgets
- actual spending is compared against limits
- remaining amount is shown
- overspending is clearly indicated
- the core budgeting feature is functional

---

## 13. Phase 8 – Local Notifications

### Goal
Add reminder functionality to support regular app usage and budget awareness.

### Scope
This phase includes:
- notification permission flow
- daily reminder setup
- optional budget-related reminder logic
- basic notification preference handling

### Main Tasks
- Integrate local notification permission request
- Add support for a daily reminder notification
- Add optional budget reminder or warning logic if appropriate
- Connect notification settings to app preferences where needed
- Keep the notification system local-only and simple

### Exclusions
This phase should **not** include:
- remote push notifications
- backend services
- cloud-triggered notifications

### Exit Criteria
This phase is complete when:
- the app can request notification permission
- a daily reminder flow is supported
- notification behavior matches project scope
- no backend dependency is introduced

---

## 14. Phase 9 – Settings

### Goal
Provide a simple place for app preferences and utility actions.

### Scope
This phase includes:
- preference controls
- notification toggles
- currency configuration
- data reset utilities
- basic app information

### Main Tasks
- Create the Settings screen
- Add notification-related preferences
- Add a currency preference
- Add a clear/reset data option
- Add app information/about section
- Keep the screen simple and supportive

### Exclusions
This phase should **not** include:
- account settings
- login settings
- cloud account preferences

### Exit Criteria
This phase is complete when:
- settings are accessible through the intended UI
- core user preferences can be managed
- notification preferences exist
- reset/utility actions are available
- Settings supports the rest of the app without becoming too large

---

## 15. Phase 10 – Final Polish and Stabilization

### Goal
Prepare the application for final presentation quality.

### Scope
This phase includes:
- cleaning visual inconsistencies
- improving user experience details
- resolving remaining issues
- preparing the app for demo and review

### Main Tasks
- Improve spacing and visual consistency
- Improve empty states
- Improve validation messages
- Remove obvious placeholder issues
- Refine reusable components if needed
- Fix compile/runtime issues
- Improve app stability
- Prepare sample/demo-ready experience if appropriate

### Exclusions
This phase should **not** include:
- new major features
- large architectural rewrites
- scope expansion beyond the agreed project

### Exit Criteria
This phase is complete when:
- the app is stable enough for presentation
- the UI feels consistent
- the main user flows work correctly
- the project reflects the planned graduation project scope

---

## 16. Phase Dependencies
Each phase depends on previous foundations.

### Dependency Logic
- Phase 1 must exist before all others
- Phase 2 must be completed before real data-driven features
- Phase 3 depends on Phase 2
- Phase 4 depends on Phases 2 and 3
- Phase 5 depends on expense data existing
- Phase 6 depends on expense data existing
- Phase 7 depends on expense and category data existing
- Phase 8 depends on app structure and settings foundation
- Phase 9 can be partially prepared earlier but should be finalized after notifications and preferences are clear
- Phase 10 depends on all core features being present

These dependencies should be respected whenever possible.

---

## 17. Prompt Usage Guidelines
When prompting Codex or Claude, prompts should explicitly reference this file and the project context file.

### Recommended Prompt Pattern
Use prompts that say things like:
- Follow `PROJECT_CONTEXT.md` and `DEVELOPMENT_PLAN.md`
- We are currently in Phase X
- Implement only the current phase
- Do not move to the next phase
- Keep the code beginner-friendly and consistent with MVVM
- Summarize all file changes after implementation
- Ask only if a major product or architecture decision is required

### Avoid
Avoid prompts such as:
- “Build the whole app”
- “Do everything”
- “Add whatever is needed”
- “Improve the project generally”

These broad prompts increase token waste and reduce project control.

---

## 18. Token Efficiency Policy
This plan is designed to support efficient AI usage.

### Efficiency Rules
- Work phase by phase
- Avoid approval after every tiny action
- Approve after meaningful implementation batches
- Use one prompt per phase whenever practical
- Use follow-up prompts only for fixes, clarifications, or refinements
- Avoid repeating the entire project description in every prompt if the md files already exist in the project

### Practical Meaning
The AI assistant should be allowed to complete a whole phase in one controlled batch, then stop for review.

This keeps development:
- systematic
- efficient
- less repetitive
- less token-expensive

---

## 19. Plan Boundaries
This document is an implementation roadmap, not a full technical specification.

It defines:
- the order of work
- the scope of each phase
- phase completion criteria
- collaboration rules with AI assistants

It does **not** define:
- the full final code
- exact visual design details for every screen
- exact prompt wording for every future task
- every minor code-level decision in advance

Those details should be handled during implementation while still respecting this roadmap.

---

## 20. Final Note
The Xpendo project should be built in a calm, structured, and controlled way.

The priority is not to implement everything as fast as possible.  
The priority is to build the app in the correct order, with a clean foundation, a stable core, and manageable progress.

A correct and systematic implementation process will produce a stronger graduation project than a rushed and inconsistent one.
