# Xpendo - UI Design Guide

## 1. Purpose
This document defines the visual design direction of Xpendo.
All future UI work should follow this guide to keep the interface visually consistent.

## 2. Design Goal
Xpendo should have a UI that feels:
- minimal
- elegant
- modern
- bright
- lively but controlled
- premium-looking
- clean and readable
- strongly iOS-friendly

The visual direction should stay close to a modern card-based personal finance app.

## 3. Core Theme
The overall interface should use:
- a very light off-white background
- white or near-white card surfaces
- teal / turquoise as the dominant accent color
- strong dark text for important values
- muted gray for secondary information
- colorful supporting accents only for categories, charts, and status indicators

The interface should feel fresh, soft, spacious, and modern.

## 4. Official Color Palette

### Primary UI Colors
- Primary Accent Teal: `#00BFA5`
- Accent Coral / Pink: `#E74C3C`
- Primary Text: `#1C1C1E`
- Secondary / Muted Text: `#8E8E93`
- Main Background Off-White: `#F8F9FA`

### Supporting Category / Chart Colors
- Housing Green: `#27AE60`
- Fresh Green: `#2ECC71`
- Soft Purple: `#9B59B6`

## 5. Color Usage Rules

### Primary Accent Teal - `#00BFA5`
Use as the main brand/accent color for:
- primary buttons
- active tab item highlights
- main add action / plus button
- important progress indicators
- key dashboard highlights
- selected states
- major chart accents when needed

This should be the most recognizable UI accent color.

### Accent Coral / Pink - `#E74C3C`
Use for:
- shopping-related categories
- budget warning accents
- selected chart segments
- attention-worthy but not destructive highlights

Do not overuse it as a global primary color.

### Primary Text - `#1C1C1E`
Use for:
- page titles
- important labels
- large financial amounts
- key headings
- major summary values

### Secondary Text - `#8E8E93`
Use for:
- dates
- notes
- helper labels
- subtitles
- secondary metadata
- supporting descriptions

### Main Background - `#F8F9FA`
Use as the main app background.
The application should feel bright and lightly softened, not pure sterile white and not gray-heavy.

### Supporting Colors
Use supporting colors mainly for:
- category icons
- chart segments
- budget bars
- small highlights
- status differentiation

They should support clarity, not overwhelm the layout.

## 6. Surface and Card Style
The UI should rely heavily on rounded white card-based sections.

Cards should have:
- medium or large corner radius
- white or near-white surfaces
- subtle shadow or very soft elevation
- clean internal spacing
- clear visual grouping
- comfortable padding

The card system should make the interface feel polished and easy to scan.

## 7. Overall Layout Style
Layouts should feel:
- open
- airy
- vertically balanced
- uncluttered
- easy to scan

Avoid dense dashboard compositions.
Avoid overly compressed spacing.
The UI should feel comfortable and modern.

## 8. Typography Feel
Typography should be:
- clean
- modern
- readable
- bold enough for financial summaries
- simple for secondary information

Important amounts should stand out clearly.
Section titles should be compact and easy to recognize.

## 9. Navigation Style
Xpendo should use:
- `TabView`
- `NavigationStack`

Main visible tabs:
- Home
- Expenses
- Budget
- Analytics

Settings must not be a separate tab.
Settings should be accessible from Home.

## 10. Main Add Action
The application should use a visually prominent add action.

The plus action should feel:
- central
- important
- easy to reach
- clearly highlighted
- visually integrated with the tab experience

Preferred direction:
- a floating or visually emphasized center add button
- using the Primary Accent Teal `#00BFA5`

Add Expense must open as a sheet, not as a separate tab.

## 11. Add Expense Sheet Style
The Add Expense sheet should visually match the rest of the app:
- bright
- clean
- spacious
- modern
- easy to read
- lightly card-based where appropriate

Primary action buttons inside this flow should use:
- Primary Accent Teal `#00BFA5`

The sheet should feel focused and practical, not visually overloaded.

## 12. Home Screen Direction
The Home screen should strongly represent the product identity.

It should visually emphasize:
- monthly spending summary
- remaining budget
- today's spending
- top categories
- recent transactions
- settings access

The screen should feel highly readable, polished, and card-driven.

## 13. Expenses Screen Direction
The Expenses screen should use:
- soft row containers or rounded cards
- clear amount hierarchy
- category color indicators
- readable transaction grouping
- a clean, uncluttered list style

## 14. Budget and Analytics Style
Budget and Analytics screens should use:
- colorful but controlled data visuals
- simple progress bars
- understandable chart sections
- clean grouping
- a clear visual hierarchy

Charts should support comprehension, not decoration.

## 15. Settings Screen Style
The Settings screen should feel:
- simple
- organized
- lightly grouped
- clean
- modern
- easy to scan

It should use subtle grouping, soft icon accents, and minimal visual noise.

## 16. What to Avoid
Avoid:
- dark and heavy default UI
- overly flashy fintech styling
- generic template-looking screens
- too many competing accent colors
- childlike illustrations
- sharp and rigid card styling
- crowded dashboards
- inconsistent spacing
- harsh shadows
- visually noisy chart sections

## 17. AI Usage Rule
When implementing UI-related work, always follow:
- `PROJECT_CONTEXT.md`
- `DEVELOPMENT_PLAN.md`
- `UI_DESIGN_GUIDE.md`

This file defines the visual source of truth for the project.
Project phase boundaries from the development plan must still be respected.
