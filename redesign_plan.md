# PET — Personal Expense Tracker
# Dashboard & Home Page Redesign Plan

> **Version:** 1.0 | **Methodology:** Human-Centered Design + User Journey Mapping
> **Framework Target:** Flutter 3.x | **Design System:** Material Design 3

---

## Table of Contents

1. [Design Philosophy & Objectives](#1-design-philosophy--objectives)
2. [User Research & Analysis](#2-user-research--analysis)
3. [User Journey Mapping](#3-user-journey-mapping)
4. [Architecture of the Current UI](#4-architecture-of-the-current-ui)
5. [Wireframes — Home Screen](#5-wireframes--home-screen)
6. [Wireframes — Dashboard Screen](#6-wireframes--dashboard-screen)
7. [Color Scheme](#7-color-scheme)
8. [Typography](#8-typography)
9. [Imagery & Iconography](#9-imagery--iconography)
10. [Component Library](#10-component-library)
11. [Interaction Design & Motion](#11-interaction-design--motion)
12. [Accessibility & Usability](#12-accessibility--usability)
13. [Flutter Implementation Guide](#13-flutter-implementation-guide)

---

## 1. Design Philosophy & Objectives

### 1.1 Core Design Philosophy — "Money Should Feel Calm"

Personal finance is one of the most anxiety-inducing topics in everyday life. The design philosophy for PET is:

> **"Make every rupee feel understood, not judged."**

The redesign is built on three pillars:

| Pillar | Description | Design Expression |
|--------|-------------|-------------------|
| **Clarity** | Show what matters instantly, hide what doesn't | Progressive disclosure, card hierarchy |
| **Calm** | Reduce cognitive load — no red warnings everywhere | Soft palette, rounded corners, whitespace |
| **Confidence** | Make the user feel in control of their money | Clear CTAs, predictive summaries, progress rings |

### 1.2 Objectives

1. **Reduce time-to-insight** — The user should know their financial health within 2 seconds of opening the app.
2. **Increase daily active usage** — Redesign the home as a daily ritual, not just a data dump.
3. **Differentiate on Play Store** — Move from a "utility" feel to a "lifestyle finance" feel.
4. **Preserve brand identity** — The existing dark mode, gradient elements, and Material You color system are retained and refined.
5. **Maintain Flutter feasibility** — Every component is implementable with Flutter's built-in widgets or popular pub.dev packages (`fl_chart`, `google_fonts`, `flutter_animate`).

---

## 2. User Research & Analysis

### 2.1 User Archetypes (Derived from App Features)

The app supports complex feature sets (AI Copilot, Tax Buckets, Family Mode, Spend Pause), suggesting a spectrum of users:

```
◄─────────────────────────────────────────────────────────────►
 CASUAL TRACKER          ACTIVE PLANNER         POWER USER
 ─────────────           ─────────────           ──────────────
 • Logs expenses          • Sets budgets           • Uses AI Copilot
   when he remembers      • Monitors categories    • Tax buckets
 • Relies on SMS          • Weekly planner         • Family mode
   auto-detection         • Goal tracking          • Cash flow forecast
 • Checks balance         • Alert centre           • Recurring bills
   occasionally           • Spend health score     • API integrations
```

### 2.2 Current Pain Points (Identified via Static Analysis)

From the extracted UI strings and screen structure, the following pain points are inferred:

**Pain Point 1 — Information overload on first glance**
The dashboard (`DashboardScreen`) contains: `_buildSummaryRow`, `_buildLineChart`, `_buildMonthPill`, `_buildRecentUpiSection`, `_buildBalanceSection`, `_buildMonthSelector`, `_buildCategoryCard` — all likely rendered simultaneously. This creates a wall of data.

**Pain Point 2 — Premium features cause visual clutter**
Premium CTAs (`_buildPremiumCta`) live inside the main `DashboardScreen`. Free users constantly see locked content, which is frustrating. Premium gating should be contextual, not a persistent overlay.

**Pain Point 3 — No single "pulse" metric**
Users have to calculate their own financial health. The app has a `SpendHealthScore` but it's buried in the premium hub, not surfaced on the home screen.

**Pain Point 4 — SMS detection status is invisible**
The app has a complex dual-fallback SMS system, but users have no idea if it's working. Confidence in auto-detection is low without a visible status indicator.

**Pain Point 5 — "Good Morning/Afternoon/Evening" greeting exists but leads nowhere**
The greeting function `_getGreeting@850136131` exists but is purely decorative. It's an opportunity for contextual financial nudges.

**Pain Point 6 — Empty states are text-only**
`"Add your first transaction to see"` appears as a plain text fallback. Empty states are prime real estate for onboarding and motivation.

### 2.3 Competitive Benchmarking

| Feature | PET (Current) | ET Money | Walnut | YNAB |
|---------|--------------|----------|--------|------|
| Spending ring on home | ❌ | ✅ | ❌ | ✅ |
| "Safe to spend today" | ✅ (buried) | ❌ | ❌ | ✅ |
| Category tiles on dashboard | ✅ | ✅ | ✅ | ❌ |
| AI-powered insights | ✅ (premium) | ✅ | ❌ | ❌ |
| Contextual greeting + nudge | ❌ | ❌ | ❌ | ✅ |
| Spend Health Score | ✅ (premium) | ❌ | ❌ | ❌ |
| Gesture-based add transaction | ❌ | ✅ | ✅ | ❌ |

**Key opportunity:** PET has all the raw data. The redesign focuses on surfacing it more intelligently.

---

## 3. User Journey Mapping

### 3.1 Daily Check-In Journey (Most Common Flow)

```
[Wake up] → [Open PET] → [See home screen]
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
            "How much did           "Did any SMS
            I spend today?"         transactions come in?"
                    │                       │
            [See daily spend        [Check SMS tab or
             ring on home]           pending review]
                    │
                    ▼
          [Tap line chart for
           monthly breakdown]
                    │
                    ▼
          [Done — app closed]
              (< 30 seconds)
```

**Redesign goal:** Make this entire journey completable from the Home Screen without any navigation.

### 3.2 Monthly Review Journey

```
[End of month] → [Open PET] → [Dashboard]
                                    │
                    ┌───────────────┼────────────────┐
                    ▼               ▼                ▼
             [Budget vs       [Category        [Spend Health
              Actual bars]     performance]     Score card]
                    │               │                │
                    └───────────────┴────────────────┘
                                    │
                                    ▼
                         [Decide next month's
                          budget adjustments]
```

### 3.3 Pain Point → Design Solution Mapping

| Pain Point | Current State | Redesigned Solution |
|------------|---------------|---------------------|
| Information overload | All widgets visible at once | Scrollable cards with priority hierarchy |
| Hidden spend health | Premium hub only | Compact score ring on home screen |
| SMS status invisible | No indicator | Sync status chip (already exists — promote it) |
| Greeting is decorative | Static string | Contextual spending nudge based on day's data |
| Empty states are bare | Plain text | Illustrated empty states with onboarding CTA |
| Premium clutter | CTA in dashboard | Bottom-of-screen contextual upsell |

---

## 4. Architecture of the Current UI

### 4.1 Screen Map

```
SplashScreen
    │
    ▼
GoogleSignInScreen
    │
    ▼
HomeScreen  ◄──── Bottom Nav (5 tabs)
    ├── DashboardScreen          ← Tab 1: Analytics
    ├── TransactionsScreen       ← Tab 2: All Transactions
    ├── BudgetScreen             ← Tab 3: Budgets
    ├── SmsTransactionsScreen    ← Tab 4: Auto-Detected
    └── SettingsScreen           ← Tab 5: Settings

PremiumHubScreen (accessed via HomeScreen)
    ├── AiCopilotScreen
    ├── AlertsScreen
    ├── CashflowScreen
    ├── GoalsScreen
    ├── RecurringBillsScreen
    ├── SpendPauseScreen
    ├── TaxBucketsScreen
    └── WeeklyPlannerScreen
```

### 4.2 State Management Architecture (Current)

```
MultiProvider
    ├── TransactionProvider   → TransactionRepository → SQLite + Firestore
    ├── CategoryProvider      → CategoryRepository    → SQLite + Firestore
    ├── BudgetProvider        → BudgetRepository      → SQLite + Firestore
    ├── SmsTransactionProvider→ SmsTransactionRepository → SQLite
    └── PremiumProvider       → SharedPreferences (dev toggle)
```

**Architectural observation:** The app uses a repository pattern with SQLite as local store and Firestore as cloud sync. The two stores are kept in sync by `FirestoreSyncService`. This is a solid foundation. The redesign does not require architecture changes — only UI layer changes.

---

## 5. Wireframes — Home Screen

### 5.1 Current Home Screen Structure (Inferred)

```
┌─────────────────────────────────┐
│  Good Morning, [Name]           │  ← Greeting (decorative)
│  [Sync Status Chip]             │
├─────────────────────────────────┤
│  [Enhanced Summary Card]        │  ← Total debits/credits
│  Total: ₹XX,XXX                 │
├─────────────────────────────────┤
│  [Line Chart]                   │  ← Monthly spending line
│                                 │
├─────────────────────────────────┤
│  Recent UPI Activity            │  ← Last few transactions
│  [Transaction Card]             │
│  [Transaction Card]             │
│  [Transaction Card]             │
├─────────────────────────────────┤
│  [Premium CTA]                  │  ← Unlock Premium banner
└─────────────────────────────────┘
[Home] [Txns] [Budget] [SMS] [Settings]
```

### 5.2 Redesigned Home Screen — ASCII Wireframe

```
┌─────────────────────────────────────┐
│  ≡   PET                    🔔  👤 │  ← AppBar: menu, notif, avatar
├─────────────────────────────────────┤
│                                     │
│  ╔═══════════════════════════════╗  │
│  ║  Good Morning, Arjun! ☀️      ║  │  ← Contextual greeting
│  ║  You've spent ₹842 today —    ║  │  ← AI-powered nudge
│  ║  ₹158 left in your daily      ║  │
│  ║  budget. Looking good! ✅      ║  │
│  ╚═══════════════════════════════╝  │  ← Gradient hero card
│                                     │
│  ┌─────────┐ ┌─────────┐ ┌───────┐ │
│  │   ₹842  │ │  ₹3,200 │ │  78   │ │  ← 3-metric pills
│  │ Spent   │ │ Budget  │ │Score  │ │
│  │ Today   │ │ Left    │ │ /100  │ │
│  └─────────┘ └─────────┘ └───────┘ │
│                                     │
│  ─────── This Month ──────── ›  │  ← Section header + nav
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Spending Ring              │    │  ← Donut chart: budget usage
│  │         ○                   │    │    with % in center
│  │      ○     ○                │    │
│  │    ○   67%   ○              │    │
│  │      ○     ○                │    │
│  │         ○                   │    │
│  │  ₹18,400 of ₹27,500         │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─────── Top Categories ──── ›  │
│                                     │
│  🍔 Food      ████████░░  ₹4,200   │  ← Horizontal progress bars
│  🏠 Housing   ██████████  ₹8,000   │
│  🚗 Transport ████░░░░░░  ₹1,800   │
│  📱 Bills     ██████░░░░  ₹2,800   │
│                                     │
│  ─────── Recent ─────────── ›  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🏪 Swiggy          -₹342   │    │
│  │ 12:30 PM · Food & Dining   │    │  ← Expense cards
│  ├─────────────────────────────┤    │
│  │ 💳 HDFC UPI Credit +₹5,000 │    │
│  │ 10:15 AM · Income           │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─────── AI Insight ─────────────  │
│  ┌─────────────────────────────┐    │
│  │ 🤖 "Your food spend is 15% │    │  ← Copilot teaser card
│  │ higher than last month.     │    │
│  │ [Ask Copilot →]             │    │
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│  [🏠 Home] [💸 Txns] [📊 Budget]   │  ← Bottom Nav (3 primary)
│  [📩 SMS]  [⋯ More]                │    Reduced to 5 clear icons
└─────────────────────────────────────┘
         ╔═══════╗
         ║   +   ║  ← FAB: Add Transaction (persistent)
         ╚═══════╝
```

### 5.3 Home Screen — Key Design Decisions

**Decision 1: Hero Greeting Card replaces a plain text greeting**
The gradient hero card uses the existing `_getGreeting` function but enriches it with a real data-driven nudge ("You've spent ₹842 today"). This requires one line of code change — passing `todaySpent` and `dailyBudget` into the greeting widget.

```dart
// Current (inferred):
Text(_getGreeting())

// Redesigned:
HeroGreetingCard(
  greeting: _getGreeting(),
  todaySpent: budgetProvider.todaySpent,
  dailyBudget: budgetProvider.dailyBudget,
  userName: authService.displayName,
)
```

**Decision 2: Three metric pills surface the most-checked numbers**
- "Spent Today" (quick dopamine / reality check)
- "Budget Left" (action-triggering)
- "Spend Score" (motivating — free, simplified version)

**Decision 3: Donut chart replaces line chart on home**
The existing line chart (`_buildLineChart`) is powerful for trend analysis but requires context to read. The donut shows "how full is my monthly budget" in 0.5 seconds. The line chart moves to the Dashboard screen.

**Decision 4: Inline category bars are scannable**
The `_buildCategoryCard` cards currently render as tiles. Replace with horizontal progress bars (linear indicators) — more information-dense and mobile-friendly.

**Decision 5: AI Copilot teaser as a card (not a paywall)**
Instead of a premium CTA banner, a soft "insight of the day" card from the AI Copilot acts as a feature demo. It shows one insight for free; tapping it opens the Copilot screen.

---

## 6. Wireframes — Dashboard Screen

### 6.1 Redesigned Dashboard — ASCII Wireframe

```
┌─────────────────────────────────────┐
│  ← Dashboard          [Month ▾]    │  ← Month selector persistent
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │  ₹18,400 spent              │    │  ← Summary banner
│  │  ₹9,100 remaining  ↑ 12%   │    │    vs last month
│  │  from last month            │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─── Spending Over Time ───────  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  30-day line chart          │    │  ← fl_chart LineChart
│  │    ╭──╮                     │    │    with touch tooltips
│  │   ╭╯  ╰─╮       ╭─────     │    │
│  │  ─╯     ╰───────╯          │    │
│  │  1      8     15    22  30  │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─── Category Breakdown ───────  │
│                                     │
│  ┌──────────┐ ┌──────────┐         │
│  │ 🍔 Food  │ │🏠 Housing │         │  ← 2-column category grid
│  │  ₹4,200  │ │  ₹8,000  │         │    with color-coded rings
│  │ ██████░░ │ │ ██████████│         │
│  │  Budget  │ │ OVER 🔴  │         │
│  └──────────┘ └──────────┘         │
│  ┌──────────┐ ┌──────────┐         │
│  │🚗 Travel │ │📱 Bills  │         │
│  │  ₹1,800  │ │  ₹2,800  │         │
│  │ ████░░░░ │ │ ██████░░ │         │
│  └──────────┘ └──────────┘         │
│                                     │
│  ─── Income vs Expense ─────────  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Bar chart: Credits/Debits  │    │  ← fl_chart BarChart
│  │                             │    │    Credit = green
│  │  █ ▓                        │    │    Debit = primary color
│  │  █ ▓   █ ▓   █ ▓    █ ▓    │    │
│  │ W1    W2    W3    W4        │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─── Spend Health ──────────────  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Your Score: 78/100  🟢     │    │
│  │  ────────────────────       │    │
│  │  ✅ Stayed within budget    │    │
│  │  ✅ No impulse purchases    │    │
│  │  ⚠️  Food spend 15% up      │    │
│  │  [See Full Report →]        │    │
│  └─────────────────────────────┘    │
│                                     │
│  ─── 30-Day Forecast ───────────  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  At current pace:           │    │
│  │  Est. month-end: ₹24,100   │    │  ← CashflowForecastService
│  │  Budget: ₹27,500            │    │
│  │  Margin: ₹3,400 🟢          │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

### 6.2 Dashboard Design Decisions

**Decision 1: Month selector always visible in AppBar**
Currently the month picker (`_showMonthPicker`) is likely triggered by a button. Moving it to a persistent chip in the AppBar reduces friction.

**Decision 2: Summary banner shows % change vs last month**
The delta calculation already exists in the data layer. Surfacing it in the banner adds motivation to reduce spending.

**Decision 3: Category grid with color-coded overflow states**
- Under 60%: Cool blue/teal (calm)
- 60–85%: Amber (warning, not panic)
- 85–100%: Orange (attention)
- Over 100%: Red + "OVER" badge (action required)

**Decision 4: Spend Health Score is free — just simplified**
Move the score card from `PremiumHubScreen` to `DashboardScreen` with a 3-line summary. The full breakdown remains premium. This uses the existing `SpendHealthService`.

**Decision 5: Forecast card from existing service**
The `CashflowForecastService` and `_buildForecastChart` already exist. Promote the forecast number to a summary card at the bottom of the dashboard.

---

## 7. Color Scheme

### 7.1 Proposed Palette

The existing app uses Material You theming (`AppTheme`). The redesign refines this with a finance-appropriate palette:

```
PRIMARY BRAND COLOR
─────────────────────────────────────────
  Indigo Depth      #3D5AFE   ← Primary actions, FAB, active nav
  Indigo Light      #8187FF   ← Secondary buttons, selected states
  Indigo Surface    #E8EAFF   ← Card backgrounds (light mode)

SEMANTIC COLORS
─────────────────────────────────────────
  Emerald Success   #00C853   ← Income, positive balance, on-track
  Amber Warning     #FFB300   ← 60-85% budget usage
  Coral Alert       #FF6B6B   ← Over-budget, overdue bills
  Slate Info        #607D8B   ← Neutral info, secondary text

NEUTRALS
─────────────────────────────────────────
  Background Light  #F8F9FF   ← App background (light mode)
  Background Dark   #0D0F1A   ← App background (dark mode) ← existing
  Surface Light     #FFFFFF   ← Card surface (light)
  Surface Dark      #1A1C2E   ← Card surface (dark) ← existing
  Text Primary      #1A1A2E   ← Primary text (light mode)
  Text Secondary    #6B7280   ← Subtitles, metadata
  Divider           #E5E7EB   ← Dividers, borders

GRADIENT (Hero Card)
─────────────────────────────────────────
  From: #3D5AFE (Indigo Depth)
  To:   #7C4DFF (Deep Purple)
  Direction: 135°
  → Used for: HeroGreetingCard, FAB, premium features
```

### 7.2 Dark Mode Refinements

The app already has dark mode. The refinements:

```
Dark mode hero card gradient:
  From: #1A1C3E → To: #2D1B69
  (Deeper, richer — less harsh than pure #000)

Dark mode category cards:
  Background: #1E2035 (slightly lighter than surface)
  Border: 1px #2A2D4A

Dark mode over-budget:
  Background: #2D1515 (dark red tint)
  Accent: #FF6B6B
```

### 7.3 Flutter Implementation

```dart
// lib/core/theme/app_theme.dart (UPDATED)

class PETColors {
  // Brand
  static const primary = Color(0xFF3D5AFE);
  static const primaryLight = Color(0xFF8187FF);
  static const primarySurface = Color(0xFFE8EAFF);

  // Semantic
  static const success = Color(0xFF00C853);
  static const warning = Color(0xFFFFB300);
  static const alert = Color(0xFFFF6B6B);

  // Hero gradient
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D5AFE), Color(0xFF7C4DFF)],
  );

  // Budget ring colors
  static Color budgetRingColor(double percentUsed) {
    if (percentUsed < 0.60) return success;
    if (percentUsed < 0.85) return warning;
    return alert;
  }
}
```

---

## 8. Typography

### 8.1 Type Scale

The app uses `google_fonts`. Recommended system:

```
DISPLAY / HERO
  Family:  Nunito (rounded, friendly — appropriate for finance)
  Size:    28sp (greeting name), 24sp (large amounts)
  Weight:  700 Bold
  Use:     Hero card amounts, greeting name

HEADINGS
  Family:  Nunito
  H1:      20sp, 700  → Section titles ("This Month", "Top Categories")
  H2:      17sp, 600  → Card titles ("Spending Over Time")
  H3:      15sp, 600  → Category names, transaction merchant names

BODY
  Family:  Inter (clean, highly legible on small screens)
  Body1:   14sp, 400  → Primary body text, transaction notes
  Body2:   13sp, 400  → Secondary info, dates, subtitles

NUMERIC (CRITICAL — financial amounts must be clear)
  Family:  JetBrains Mono (monospaced — aligns decimal points)
  Large:   22sp, 700  → ₹ amounts in cards (₹18,400)
  Medium:  16sp, 600  → Inline amounts in lists
  Small:   13sp, 500  → Metadata amounts, category summaries

LABELS
  Family:  Inter
  Label:   11sp, 500  → Tags, status chips, category labels
  Caption: 10sp, 400  → Timestamps, tertiary info
```

### 8.2 Flutter Implementation

```dart
// In pubspec.yaml:
// google_fonts: ^6.2.1

// Usage:
GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w700)
GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400)
GoogleFonts.jetBrainsMono(fontSize: 22, fontWeight: FontWeight.w700)
```

### 8.3 Number Formatting Conventions

```
AMOUNTS:
  ✅  ₹18,400          (Indian formatting: lakh separator)
  ✅  ₹1,84,000        (for amounts > 1L)
  ❌  ₹18400           (no separator — hard to read)
  ❌  Rs. 18400        (outdated symbol)

PERCENTAGES:
  ✅  67%              (integer when possible)
  ✅  67.4%            (one decimal when needed)

DATES:
  ✅  Today, 2:30 PM   (today)
  ✅  Mon, 12 Mar      (this week)
  ✅  12 Mar 2025      (older)
```

---

## 9. Imagery & Iconography

### 9.1 App Icon Redesign

**Current Issue:** `app_icon.jpeg` — JPEG has no transparency. On Android 8+ adaptive icon launchers, this renders with a white box background.

**Proposed:**
```
Foreground layer:  ₹ symbol in white, slightly offset
                   Inside a subtle donut ring (budget metaphor)
Background layer:  Solid #3D5AFE (brand indigo)
Shape:             Round rect (Google Play standard)

Files required:
  res/mipmap-xxxhdpi/ic_launcher.png        (192×192 foreground)
  res/mipmap-xxxhdpi/ic_launcher_bg.png     (background layer)
  res/mipmap-anydpi-v26/ic_launcher.xml     (adaptive icon XML)
```

### 9.2 Icon System

Use **Material Symbols** (Rounded variant) as the primary icon set — already included via `MaterialIcons-Regular.otf`.

```
Navigation:
  Home       → home_rounded
  Transactions → receipt_long_rounded
  Budget     → donut_large_rounded
  SMS        → mark_chat_read_rounded
  More       → apps_rounded

Actions:
  Add        → add_rounded (FAB)
  Edit       → edit_rounded
  Delete     → delete_outline_rounded
  Filter     → tune_rounded

Categories (emoji-first for color, icon as fallback):
  🍔 Food & Dining   → restaurant_rounded
  🏠 Housing         → home_work_rounded
  🚗 Transport       → directions_car_rounded
  📱 Bills           → phone_iphone_rounded
  💊 Health          → health_and_safety_rounded
  🎮 Entertainment   → sports_esports_rounded
```

### 9.3 Empty State Illustrations

Replace text-only empty states with 3-color SVG illustrations (feasible in Flutter via `flutter_svg`):

```
Empty Transactions:
  Illustration: A small receipt with a magnifying glass
  Caption: "No transactions yet"
  Sub: "Tap + to add your first one, or grant SMS access
        to auto-detect bank transactions."
  CTA Button: [Grant SMS Access] / [Add Transaction]

Empty Budget:
  Illustration: An empty jar with a coin above it
  Caption: "No budgets set"
  Sub: "Set a monthly limit for each category to track
        your spending against your goals."
  CTA Button: [Set First Budget]

Empty Goals:
  Illustration: A mountain with a flag at the top
  Caption: "No savings goals"
  Sub: "What are you saving for? Create a goal and
        track your progress month by month."
  CTA Button: [Create First Goal]
```

---

## 10. Component Library

### 10.1 HeroGreetingCard

```
┌────────────────────────────────────────┐
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│  ░  ☀️  Good Morning, Arjun!        ░  │ ← Gradient bg
│  ░  You've spent ₹842 today.        ░  │ ← Dynamic nudge
│  ░  ₹158 left before your daily     ░  │
│  ░  budget. You're on track! ✅      ░  │
│  ░                    ─────────────  ░  │
│  ░  [Sync Status: ● Live]           ░  │ ← SMS sync status
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
└────────────────────────────────────────┘
```

**Flutter:**
```dart
class HeroGreetingCard extends StatelessWidget {
  final String greeting;
  final double todaySpent;
  final double dailyBudget;
  final String userName;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: PETColors.heroGradient,
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$greeting, $userName!", style: GoogleFonts.nunito(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(_buildNudge(), style: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.9), fontSize: 14)),
        const SizedBox(height: 12),
        SyncStatusChip(), // existing widget — promoted here
      ],
    ),
  );

  String _buildNudge() {
    final remaining = dailyBudget - todaySpent;
    if (remaining > 0) {
      return "You've spent ₹${todaySpent.toInt()} today. "
             "₹${remaining.toInt()} left in your daily budget. Looking good! ✅";
    } else {
      return "You've exceeded today's daily budget by "
             "₹${(-remaining).toInt()}. Consider pausing non-essentials. 💡";
    }
  }
}
```

### 10.2 MetricPill (3-column row)

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│  ₹842    │  │  ₹3,200  │  │    78    │
│ Spent    │  │ Remaining│  │  Score   │
│ Today    │  │          │  │  /100    │
└──────────┘  └──────────┘  └──────────┘
 (Surface)     (Success bg)  (Amber bg)
```

### 10.3 CategoryProgressBar

```
🍔 Food & Dining               ₹4,200 / ₹6,000
   ████████████████░░░░░░░░    70%

🏠 Housing                     ₹8,200 / ₹8,000  OVER
   ████████████████████████    103% 🔴
```

**Flutter:**
```dart
class CategoryProgressBar extends StatelessWidget {
  final CategoryModel category;
  final BudgetModel budget;
  final double spent;

  double get _percent => spent / budget.amount;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(children: [
      Row(children: [
        Text(category.emoji ?? '📦', style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(child: Text(category.name, style: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500))),
        Text("₹${spent.toInt()} / ₹${budget.amount.toInt()}",
          style: GoogleFonts.jetBrainsMono(fontSize: 12,
            color: _percent > 1.0 ? PETColors.alert : null)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: _percent.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(
            PETColors.budgetRingColor(_percent)),
          minHeight: 8,
        ),
      ),
    ]),
  );
}
```

### 10.4 TransactionCard (Redesigned)

```
┌─────────────────────────────────────────┐
│  🏪  Swiggy                   -₹342    │
│      Food & Dining · 12:30 PM          │  ← merchant + category + time
│      ████████  SMS Auto-detected 📩   │  ← source badge
└─────────────────────────────────────────┘
```

Key changes vs current:
- Merchant name more prominent than amount (recognition first)
- Source badge: "Manual" vs "SMS Auto-detected" vs "UPI"
- Subtle swipe-to-edit gesture (left: edit, right: delete)

### 10.5 SpendHealthScoreCard (Free tier)

```
┌────────────────────────────────────────┐
│  Spend Health Score          78 / 100  │
│  ─────────────────────────────────     │
│    ██████████████████░░░░░░░░░░░  78% │
│                                        │
│  ✅  Within budget in 4 categories     │
│  ⚠️   Food & Dining up 15%             │
│  🔴  Housing over budget               │
│                                        │
│              [See Full Report →]       │  ← Premium upsell
└────────────────────────────────────────┘
```

---

## 11. Interaction Design & Motion

### 11.1 Micro-Animations (Flutter Animate package)

```dart
// Transaction added feedback
transactionCard
  .animate()
  .slideX(begin: 1.0, duration: 300.ms, curve: Curves.easeOutCubic)
  .fadeIn(duration: 250.ms)

// Budget exceeded shake
budgetBar
  .animate(trigger: isOverBudget)
  .shake(duration: 400.ms, hz: 3)

// Score counter on screen enter
scoreText
  .animate()
  .custom(
    duration: 800.ms,
    builder: (context, value, child) => Text(
      '${(value * score).toInt()}',
      ...
    ),
  )

// Hero card gradient shift on time-of-day
// Morning: blue → indigo
// Afternoon: teal → blue
// Evening: purple → deep blue
```

### 11.2 Gesture Design

| Gesture | Target | Action |
|---------|--------|--------|
| Swipe left | Transaction card | Reveal edit button |
| Swipe right | Transaction card | Reveal delete (with confirmation) |
| Long press | Category chip | Quick budget edit bottom sheet |
| Pull-to-refresh | Home screen | Trigger SMS inbox scan + Firestore sync |
| Pinch | Line chart | Zoom time range (7d / 30d / 3m) |
| Double-tap | Donut chart | Navigate to full category breakdown |

### 11.3 Add Transaction FAB Behavior

```
Normal state:        [+]  (solid, indigo)
While typing amount: FAB transforms into [Save ₹XXX] using AnimatedContainer
On success:          Brief green checkmark ✓ animation then return to [+]
```

### 11.4 Scroll Behavior

```
AppBar: Collapses on scroll down, re-appears on scroll up (SliverAppBar)
FAB: Hides on scroll down, shows on scroll up
Bottom nav: Hides on scroll down, shows on scroll up
```

This maximizes screen real estate while scrolling through transaction lists.

---

## 12. Accessibility & Usability

### 12.1 Accessibility Requirements

| Requirement | Implementation |
|-------------|---------------|
| Color contrast ≥ 4.5:1 | All text/bg combos validated against WCAG AA |
| Touch targets ≥ 48×48dp | All tappable elements padded to minimum size |
| Screen reader labels | Every icon button has `Semantics(label: ...)` |
| Font scaling support | UI tested at 1.0×, 1.3×, 1.5× text scale |
| No color-only information | Budget status uses icon + color + text |

### 12.2 Usability Heuristics Applied

1. **Visibility of system status** — Sync status chip always visible in hero card.
2. **Match between system and real world** — ₹ symbol, Indian date formats, Indian bank names.
3. **User control** — Swipe-to-undo delete, confirmation dialogs for destructive actions.
4. **Error prevention** — Amount field validates in real-time; "Enter a valid amount" appears as the user types.
5. **Recognition over recall** — Category icons + colors for instant recognition; no need to read labels.
6. **Aesthetic and minimalist design** — Progressive disclosure hides advanced features until needed.

### 12.3 One-Handed Use

The most frequent actions (add transaction, view today's spend) are reachable within the bottom 60% of the screen. The FAB is thumb-zone optimal. The hero card summary numbers are large enough to read at a glance without tapping.

---

## 13. Flutter Implementation Guide

### 13.1 Package Additions Required

```yaml
# pubspec.yaml — new/changed dependencies

dependencies:
  # Already present (keep):
  fl_chart: ^0.68.0        # Charts
  google_fonts: ^6.2.1     # Typography

  # Add:
  flutter_animate: ^4.5.0  # Micro-animations
  flutter_svg: ^2.0.10     # SVG empty state illustrations
  shimmer: ^3.0.0          # Loading skeleton screens
  gap: ^3.0.1              # Clean spacing widget

  # Consider:
  lottie: ^3.1.0           # For richer empty state animations
```

### 13.2 File Structure Changes

```
lib/
  core/
    theme/
      app_theme.dart          ← UPDATE: add PETColors class
      pet_colors.dart         ← NEW: centralized color system
    widgets/
      hero_greeting_card.dart ← NEW
      metric_pill_row.dart    ← NEW
      category_progress_bar.dart ← REPLACE existing budget_progress_bar.dart
      spend_health_card.dart  ← NEW (free tier version)
      animated_amount.dart    ← NEW (counter animation)
      empty_state.dart        ← NEW (illustrated empty states)
  screens/
    home/
      home_screen.dart        ← MAJOR UPDATE
    dashboard/
      dashboard_screen.dart   ← MAJOR UPDATE
```

### 13.3 Home Screen Rebuild Checklist

- [ ] Replace `Text(_getGreeting())` with `HeroGreetingCard`
- [ ] Promote `SyncStatusChip` into `HeroGreetingCard`
- [ ] Add `MetricPillRow` with today's spend, remaining budget, score
- [ ] Replace line chart with `BudgetDonutChart` (fl_chart PieChart)
- [ ] Replace `_buildCategoryCard` tiles with `CategoryProgressBar` list
- [ ] Add `SpendHealthScoreCard` (simplified, free version)
- [ ] Add `AICopilotTeaserCard` (replaces hardcoded premium CTA)
- [ ] Implement `SliverAppBar` + `SliverList` for collapsing header
- [ ] Add swipe gestures to `TransactionCard`
- [ ] Implement pull-to-refresh

### 13.4 Dashboard Screen Rebuild Checklist

- [ ] Move month selector to `AppBar` as persistent chip
- [ ] Add summary banner with delta vs last month
- [ ] Keep line chart (30-day) — but add pinch-to-zoom
- [ ] Replace category cards with 2-column grid + color-coded rings
- [ ] Add weekly income vs expense bar chart
- [ ] Add `SpendHealthScoreCard` (full version, premium gate on details)
- [ ] Add cashflow forecast card (uses existing `CashflowForecastService`)

---

## Appendix A — Design Token Summary

| Token | Light Value | Dark Value |
|-------|-------------|------------|
| `color.primary` | `#3D5AFE` | `#8187FF` |
| `color.background` | `#F8F9FF` | `#0D0F1A` |
| `color.surface` | `#FFFFFF` | `#1A1C2E` |
| `color.success` | `#00C853` | `#00E676` |
| `color.warning` | `#FFB300` | `#FFD740` |
| `color.alert` | `#FF6B6B` | `#FF5252` |
| `radius.card` | `16dp` | `16dp` |
| `radius.chip` | `8dp` | `8dp` |
| `elevation.card` | `2` | `0` (border instead) |
| `spacing.section` | `24dp` | `24dp` |
| `spacing.card` | `16dp` | `16dp` |

---

## Appendix B — Screens Not Redesigned (Out of Scope)

The following screens are functionally sound and do not require significant redesign in this pass:
- `AddEditTransactionScreen` — functional form, minor spacing improvements only
- `SettingsScreen` — standard settings pattern, no changes needed
- `SmsPermissionScreen` — permission flows are system-dictated
- `GoogleSignInScreen` — auth screen, brand-compliant
- All premium screens (`AiCopilotScreen`, `GoalsScreen`, etc.) — out of scope

---

*End of Redesign Plan — PET Personal Expense Tracker*
*Version 1.0 | Human-Centered Design Methodology*
