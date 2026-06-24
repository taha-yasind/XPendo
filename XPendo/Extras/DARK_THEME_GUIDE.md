# Xpendo - Dark Theme Guide

## 1. Purpose
This document defines the dark theme visual direction of Xpendo.
It should be used together with `UI_DESIGN_GUIDE.md` to keep both Light Mode and Dark Mode visually consistent across the app.

## 2. Design Goal
Xpendo Dark Mode should feel:
- premium
- modern
- minimal
- elegant
- focused
- high-contrast but controlled
- strongly iOS-friendly
- visually rich without becoming noisy

The dark theme should preserve the same product identity as the light theme, while offering a more immersive and refined appearance.

## 3. Core Theme
The overall dark interface should use:
- a deep near-black background
- slightly elevated dark surface cards
- teal as the primary accent color
- strong white text for important values
- muted gray for secondary information
- colorful supporting accents only for categories, charts, and status indicators
- subtle glassmorphism-inspired highlights where appropriate

The interface should feel sleek, readable, and polished.

## 4. Official Color Palette

### Primary UI Colors
- Main Background: `#0A0E12`
- Surface / Card Background: `#1A1F24`
- Primary Accent Teal: `#25B0B9`
- Primary Text: `#FFFFFF`
- Secondary / Muted Text: `#8E8E93`

### Supporting Accent Colors
- Soft Red / Warning: `#FF5C5C`
- Soft Purple: `#D65CF5`
- Success Green: `#4CD964`

### Optional Supporting UI Colors
- Divider / Border: `rgba(255, 255, 255, 0.08)`
- Input Background: `#13181D`
- Pressed / Selected Surface: `#222831`
- Tab Inactive: `#6E6E73`

## 5. Color Usage Rules

### Main Background - `#0A0E12`
Use as the primary app background.
This should define the overall dark identity of the application.

Use for:
- app background
- full-screen page backgrounds
- tab bar background if a darker integrated look is preferred

### Surface / Card Background - `#1A1F24`
Use for elevated content areas.

Use for:
- summary cards
- list cards
- section containers
- charts containers
- grouped settings sections
- modal sheet content surfaces

Cards should feel distinct from the main background, but still soft and premium.

### Primary Accent Teal - `#25B0B9`
Use as the main interactive and brand color.

Use for:
- primary buttons
- active tab icons
- selected states
- progress bars
- key chart accents
- save/add actions
- theme highlights
- important interactive focus states

This is the main recognizable brand color in Dark Mode.

### Primary Text - `#FFFFFF`
Use for:
- page titles
- major headings
- important labels
- balance values
- primary amounts
- button labels on dark surfaces

### Secondary / Muted Text - `#8E8E93`
Use for:
- helper text
- dates
- notes
- subtitles
- secondary amounts
- category metadata
- chart supporting labels

### Soft Red / Warning - `#FF5C5C`
Use for:
- overspending indicators
- destructive actions
- negative change indicators
- attention-worthy warnings

Do not overuse it outside alerts and status emphasis.

### Soft Purple - `#D65CF5`
Use for:
- supporting category visuals
- chart segments
- selected secondary highlights
- accent variation where visual grouping is needed

### Success Green - `#4CD964`
Use for:
- positive status
- remaining budget indicators
- successful progress
- positive chart accents

## 6. Surface and Card Style
The dark theme should rely on rounded card-based surfaces just like the light theme.

Cards should have:
- medium or large corner radius
- dark elevated surfaces
- subtle separation from background
- very soft shadow or layered depth
- optional faint border for clarity
- comfortable internal spacing

Cards should feel polished, not heavy.

## 7. Glassmorphism Usage
Dark Mode may use light glassmorphism-inspired accents, but only subtly.

Allowed usage:
- soft translucent highlights
- light blur overlays for floating elements
- subtle glow or layered tint for highlighted cards

Avoid:
- extreme transparency
- overly frosted surfaces
- blurred UI that reduces readability
- decorative effects that distract from content

Glassmorphism should support elegance, not visual noise.

## 8. Overall Layout Style
Layouts should remain:
- open
- balanced
- spacious
- easy to scan
- visually calm

Avoid:
- overcrowded dark screens
- too many glowing elements
- excessive chart saturation
- overly compressed cards
- harsh visual contrast between sections

Dark Mode should feel refined and comfortable.

## 9. Typography Feel
Typography should be:
- crisp
- modern
- readable
- bold enough for financial values
- clean for labels and metadata

Important amounts should stand out strongly against the dark background.

## 10. Navigation Style
Xpendo should continue using:
- `TabView`
- `NavigationStack`

Main visible tabs remain:
- Home
- Expenses
- Budget
- Analytics

Settings must still not be a separate tab.

### Dark Mode Navigation Guidance
- active tab item: use Primary Accent Teal `#25B0B9`
- inactive tab item: use `#6E6E73` or muted gray
- tab bar should visually blend with the dark base while keeping enough contrast

## 11. Main Add Action
The main add action should remain visually prominent in Dark Mode.

Preferred direction:
- teal floating or emphasized center add button
- strong contrast against dark navigation background
- rounded and highly tappable appearance
- subtle glow or elevation if needed

Use:
- Primary Accent Teal `#25B0B9`

## 12. Add Expense Sheet Style
The Add Expense sheet in Dark Mode should feel:
- focused
- clean
- readable
- premium
- softly elevated above the app background

Use:
- dark sheet background or elevated card surface
- bright input contrast
- teal primary action button
- muted supporting text
- strong white labels for key input areas

The sheet should not feel too dense or overly glossy.

## 13. Home Screen Direction
The Home screen should strongly express the dark premium identity of the product.

It should visually emphasize:
- total monthly spending
- remaining budget
- today’s spending
- top categories
- recent transactions
- settings access

Recommended style:
- one strong hero summary card
- supporting metric cards
- colorful but controlled category chips
- clean recent transaction blocks
- teal as the main highlight color

The screen should feel dashboard-like, but still minimal.

## 14. Expenses Screen Direction
The Expenses screen should use:
- dark rounded transaction cards
- strong amount hierarchy
- subtle icon containers
- category color indicators
- muted metadata
- clean grouping by date if needed

The list should remain highly readable in dark environments.

## 15. Budget and Analytics Style
Budget and Analytics screens should use:
- colorful but controlled chart sections
- clear progress visualization
- readable legends
- strong category separation
- simple chart grouping
- dark premium containers with clear contrast

Recommended chart usage:
- teal for primary trends
- red for warnings / overspending
- purple and green as supporting chart colors

Charts must prioritize understanding, not decoration.

## 16. Settings Screen Style
The Settings screen in Dark Mode should feel:
- premium
- organized
- simple
- softly grouped
- easy to scan

Use:
- grouped dark cards
- subtle icon accents
- muted dividers
- clear typography
- teal highlight for selected settings or active preferences

The screen should feel like a polished iOS settings experience, not a generic template.

## 17. Theme Consistency Rules
Dark Mode should preserve the same structural design language as Light Mode.

That means:
- same navigation logic
- same component hierarchy
- same spacing logic
- same card philosophy
- same interaction priorities

Only the visual treatment should change.
The app should still feel like the same product in both themes.

## 18. New Component Rule
Any newly added UI element in the future must define:
- background behavior in Dark Mode
- text colors in Dark Mode
- selected state color
- disabled state appearance
- border or divider behavior if needed
- icon color behavior
- interaction highlight color

New buttons, charts, cards, toggles, and inputs must visually match this guide.

## 19. What to Avoid
Avoid:
- pure black flat screens with no depth
- overly neon fintech styling
- too many glowing accents
- harsh contrast blocks without spacing
- unreadable chart colors
- too many competing accent colors
- childlike illustrations
- inconsistent surface tones
- bright gradients used everywhere
- blurry glass effects that reduce clarity

## 20. AI Usage Rule
When implementing Dark Mode or preferred theme support, always follow:
- `PROJECT_CONTEXT.md`
- `DEVELOPMENT_PLAN.md`
- `UI_DESIGN_GUIDE.md`
- `DARK_THEME_GUIDE.md`

This file defines the dark visual source of truth for the project.
All future dark theme work should remain consistent with this guide.
