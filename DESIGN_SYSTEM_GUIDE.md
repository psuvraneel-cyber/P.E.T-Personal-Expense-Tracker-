# P.E.T Design System — Migration Guide & Checklist

> Gradient-colored UI/UX background integration  
> Flutter 3.x+ · Material 3 · Mobile-first

---

## 1. Design Asset Analysis

### Color Palette (extracted)

| Token | Hex | Usage |
|-------|-----|-------|
| `gradientStart` | `#1A0533` | Deep indigo — hero gradient start |
| `gradientMid` | `#4A1A8A` | Rich violet — hero gradient mid |
| `gradientEnd` | `#8B5CF6` | Electric purple — hero gradient end |
| `warmStart` | `#E040A0` | Magenta — warm CTA accent |
| `warmEnd` | `#F97316` | Coral — warm accent end |
| `coolAccent` | `#06B6D4` | Cyan — cool accent |
| `coolSecondary` | `#14B8A6` | Teal — secondary |
| `income` | `#10B981` | Semantic green |
| `expense` | `#EF4444` | Semantic red |
| `warning` | `#F59E0B` | Semantic yellow |

### Gradient Implementation Recommendation

**Flutter `LinearGradient` (chosen)** — preferred over SVG because:
- Native hardware-accelerated rendering on all platforms
- Animatable (alignment, colors, stops) for polish
- Consistent with existing codebase patterns
- No extra asset bundling or SVG parser dependency

SVG background vectors from the pack are **not bundled** — the gradient color
stops and directions have been translated into `ColorTokens` Dart constants.

### Font Analysis

| Asset Recommendation | Existing App | Decision |
|---|---|---|
| Open Sans (Steve Matteson) | Poppins (bundled in `google_fonts/`) | **Keep Poppins** — geometrically similar, wider weight range, already bundled |

If you later want Open Sans as secondary body typeface, drop `.ttf` files into
`google_fonts/` and reference via `GoogleFonts.openSans(...)`.

---

## 2. New Files Created

```
lib/core/theme/
├── app_theme.dart          ← UPDATED (imports ColorTokens, adds new gradients)
├── color_tokens.dart       ← NEW — all colors, gradient presets, helpers
├── spacing.dart            ← NEW — 4px-grid spacing constants
└── typography.dart         ← NEW — typed text styles (domain-specific too)

lib/core/widgets/
├── gradient_background.dart   ← NEW — animated gradient wrapper
├── expense_card.dart          ← NEW — modern transaction card
├── enhanced_summary_card.dart ← NEW — gradient-accented summary card
├── category_chip.dart         ← NEW — pill-shaped category selector
├── summary_card.dart          ← UNCHANGED (backward compat)
├── transaction_tile.dart      ← UNCHANGED (backward compat)
└── budget_progress_bar.dart   ← UNCHANGED
```

## 3. Screens Updated

| Screen | Changes |
|--------|---------|
| `dashboard_screen.dart` | `GradientBackground` wrapper, `EnhancedSummaryCard` row, `ExpenseCard` for recent transactions |
| `transactions_screen.dart` | `GradientBackground`, `ExpenseCard` replaces `TransactionTile` |
| `add_edit_transaction_screen.dart` | `GradientBackground`, `CategoryChip` replaces inline category grid, gradient save button |

---

## 4. Migration Steps (for other screens)

### Step 1 — Add gradient background to any screen

```dart
import 'package:pet/core/widgets/gradient_background.dart';

// Wrap the screen body:
body: GradientBackground(
  child: SafeArea(
    child: YourContent(),
  ),
),
```

### Step 2 — Replace hardcoded colors with tokens

```dart
// Before:
color: const Color(0xFF0D0B1E),

// After:
import 'package:pet/core/theme/color_tokens.dart';
color: ColorTokens.darkBg,
```

### Step 3 — Replace magic-number spacing

```dart
// Before:
padding: const EdgeInsets.all(16),

// After:
import 'package:pet/core/theme/spacing.dart';
padding: const EdgeInsets.all(Spacing.base),
```

### Step 4 — Use typed text styles

```dart
// Before:
style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),

// After:
import 'package:pet/core/theme/typography.dart';
style: AppTypography.heroBalance(color: Colors.white),
```

### Step 5 — Use reusable widgets

```dart
// CategoryChip — category selector
CategoryChip(
  label: cat.name,
  icon: cat.icon,
  color: cat.color,
  isSelected: selected,
  onTap: () => select(cat),
)

// ExpenseCard — transaction row
ExpenseCard(
  transaction: txn,
  category: cat,
  compact: true,
  onTap: () => edit(txn),
)

// EnhancedSummaryCard — KPI card
EnhancedSummaryCard(
  title: 'Income',
  amount: 42500,
  icon: Icons.arrow_downward_rounded,
  color: ColorTokens.income,
  gradient: ColorTokens.incomeGradient,
)
```

---

## 5. pubspec.yaml — No Changes Required

The existing `pubspec.yaml` already includes:
- `google_fonts: ^6.2.1` (Poppins bundled in `google_fonts/`)
- `fl_chart: ^0.70.2` (dashboard charts)
- `assets: - assets/` (asset directory)

No new dependencies or assets are needed. The gradient design is implemented
entirely in Dart code.

---

## 6. Accessibility Best Practices

| Practice | Implementation |
|----------|---------------|
| Color contrast | All text colors meet WCAG AA (4.5:1) against both dark and light backgrounds |
| Semantic colors | Income=green, Expense=red independently convey meaning; icons act as secondary cue |
| Touch targets | All tappable widgets ≥ 48x48 dp |
| Screen reader | Widget tree uses standard `Text`, `Icon`, `Semantics` — compatible with TalkBack/VoiceOver |
| Reduced motion | `GradientBackground(animate: false)` disables animation; check `MediaQuery.disableAnimations` for system preference |

### Reduced-motion pattern

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;
GradientBackground(
  animate: !reduceMotion,
  child: ...
)
```

---

## 7. Responsiveness Best Practices

| Technique | Used in |
|-----------|---------|
| `LayoutBuilder` + breakpoint | `_buildSummaryRow()` — 2-col vs 3-col |
| `Spacing` constants (not magic numbers) | All screens |
| `Expanded` / `Flexible` | Card layouts |
| `MediaQuery.of(context).size` | Available for custom breakpoints |
| `SafeArea` | All screens |
| `Spacing.navBarClearance` | Dashboard bottom padding |

### Recommended breakpoints

```dart
final width = MediaQuery.of(context).size.width;
final isCompact = width < 360;   // Small phones
final isMedium  = width < 600;   // Standard phones
final isWide    = width >= 600;  // Tablets / landscape
```

---

## 8. Performance Best Practices

| Practice | Detail |
|----------|--------|
| `const` constructors | All token classes use `static const` — zero allocation |
| Cached formatters | `NumberFormat` and `DateFormat` are `static final` — one instance per widget class |
| `AnimatedBuilder` | Gradient animation uses single `AnimationController` — no rebuild of child tree |
| Gradient vs SVG | Native Flutter gradients avoid SVG parsing overhead |
| `IndexedStack` | Home screen caches tab screens |
| `RepaintBoundary` | Consider adding around `GradientBackground` if profiling shows excessive repaints |
| Runtime font fetch disabled | `GoogleFonts.config.allowRuntimeFetching = false` — already set in `main.dart` |

---

## 9. Design-to-Code Translation Checklist

### Colors & Gradients
- [x] Extracted all gradient stops from asset pack
- [x] Mapped gradient colors to `ColorTokens` constants
- [x] Created dark-mode screen gradient
- [x] Created light-mode screen gradient
- [x] Maintained existing semantic colors (income/expense/warning)
- [x] `AppTheme` colors aliased to `ColorTokens` for backward compatibility

### Typography
- [x] Poppins retained as primary typeface (matches geometric style of Open Sans)
- [x] Created `AppTypography` with Material 3 scale + domain extensions
- [x] Hero balance, currency, caption styles defined

### Spacing
- [x] 4px base grid established
- [x] Semantic spacing aliases (screen, card, section, chip, input, sheet)
- [x] All new code uses `Spacing.*` constants

### Widgets
- [x] `GradientBackground` — full-screen animated gradient
- [x] `ExpenseCard` — modern transaction card with gradient card background
- [x] `EnhancedSummaryCard` — KPI card with gradient accent strip
- [x] `CategoryChip` — pill-shaped selector with gradient selected state

### Screens
- [x] Dashboard: gradient background, summary row, ExpenseCard
- [x] Transaction list: gradient background, ExpenseCard
- [x] Add/Edit form: gradient background, CategoryChip, gradient save button

### Backward Compatibility
- [x] `AppTheme.*` color constants unchanged (aliased to `ColorTokens`)
- [x] `AppTheme.*Gradient` constants unchanged
- [x] `SummaryCard` widget untouched (still importable)
- [x] `TransactionTile` widget untouched (still importable)
- [x] `BudgetProgressBar` untouched
- [x] No changes to data models, providers, or services
- [x] No new dependencies in `pubspec.yaml`

### Accessibility
- [x] WCAG AA color contrast verified
- [x] 48dp minimum touch targets
- [x] Reduced-motion support via `animate` parameter
- [x] Screen-reader compatible widget tree

### Performance
- [x] Static const tokens — zero allocation
- [x] Cached formatters per widget
- [x] Single AnimationController for gradient
- [x] No SVG parsing overhead

### Final Verification
- [x] `flutter analyze` — 0 errors, 0 warnings (only pre-existing info notices)
- [ ] Visual QA on device/emulator (manual step)
- [ ] Dark mode toggle test (manual step)
- [ ] Responsive test at 320px / 375px / 414px widths (manual step)

---

## 10. Premium Product Strategy (Roadmap + Pricing)

This section defines the premium roadmap for the P.E.T consumer finance app.
Pricing is fixed at: Monthly: Rs 50, Yearly: Rs 450, Family add-on: Rs 25.

### 10.1 Prioritized Premium Features

#### A. MUST-HAVE (high conversion + high daily value)

1. **Smart Auto-Categorization + Merchant Normalization**
  - Problem: Users spend time fixing noisy SMS and merchant labels.
  - Value: Clean, auto-organized spending with near-zero manual work.
  - Monetization: Clear time-savings and immediate value in first session.
  - Impact: Retention +12 to +18%, engagement +10 to +15%.
  - Effort: Medium.
  - Dependencies: Merchant database, rules engine, feedback UX.

2. **Bill + Subscription Detection and Upcoming Payments**
  - Problem: Users miss recurring dues and get surprised by debits.
  - Value: Forecasted obligations and a next-due view.
  - Monetization: Peace-of-mind; avoids late fees.
  - Impact: Retention +10 to +15%, upgrade +5 to +8%.
  - Effort: Medium.
  - Dependencies: Recurrence detection, notification parsing, calendar UX.

3. **Spending Limits + Real-Time Alerts**
  - Problem: Users overspend before noticing.
  - Value: Instant threshold alerts and monthly guardrails.
  - Monetization: High perceived control and savings.
  - Impact: Engagement +15 to +20%, upgrade +6 to +10%.
  - Effort: Low to Medium.
  - Dependencies: Budget engine, alert system, permission handling.

4. **Cash Flow Forecast (Next 30 Days)**
  - Problem: Users cannot predict short-term liquidity.
  - Value: Simple runway and safe-to-spend estimate.
  - Monetization: Automation plus intelligence.
  - Impact: Retention +8 to +12%, upgrade +4 to +7%.
  - Effort: Medium.
  - Dependencies: Income detection, recurring patterns, clarity-focused UX.

5. **Multi-Account SMS Import + Conflict Resolution**
  - Problem: Multiple banks and wallets fragment visibility.
  - Value: Unified timeline and consolidated insights.
  - Monetization: Strong power-user appeal.
  - Impact: Conversion +7 to +12%, retention +8 to +10%.
  - Effort: Medium.
  - Dependencies: SMS normalization, dedupe logic, identity rules.

#### B. NICE-TO-HAVE (differentiation and retention)

1. **Automated Savings Goals + Round-up Insights**
  - Problem: Users want to save but do not know how much is feasible.
  - Value: Goal progress based on real behavior.
  - Monetization: Aspirational and progress-driven.
  - Impact: Retention +6 to +10%.
  - Effort: Medium.
  - Dependencies: Goal engine, insight UI.

2. **Shared Family View + Household Budgets**
  - Problem: Families cannot coordinate spending.
  - Value: Shared budgets and visibility.
  - Monetization: Family add-on appeal.
  - Impact: Retention +5 to +8%, ARPU +10 to +15%.
  - Effort: High.
  - Dependencies: Multi-user, permissions, sync.

3. **Category-Level Anomaly Alerts**
  - Problem: Users miss unusual spikes until month-end.
  - Value: Fast alerts like "2.4x higher than usual".
  - Monetization: Intelligence and control.
  - Impact: Engagement +8 to +12%.
  - Effort: Medium.
  - Dependencies: Baselines, analytics.

4. **Tax-Ready Expense Buckets (freelancers)**
  - Problem: Expense sorting for tax time is painful.
  - Value: Auto-tagging for deductible categories.
  - Monetization: Strong for freelancer segment.
  - Impact: Conversion +4 to +7% for that segment.
  - Effort: Medium.
  - Dependencies: Category mapping, export.

#### C. EXPERIMENTAL / INNOVATION (future moat and delight)

1. **Personal Finance Co-Pilot (explainable AI)**
  - Problem: Users want actionable guidance, not just charts.
  - Value: Suggestions with clear, transparent rationale.
  - Monetization: Premium intelligence when trusted.
  - Impact: Engagement +10 to +15% if trusted.
  - Effort: High.
  - Dependencies: AI model, guardrails, explainability UX.

2. **Predictive Income Variability Shield**
  - Problem: Variable income users struggle with volatility.
  - Value: Dynamic budgets adjusted to income confidence.
  - Monetization: Unique to gig and freelancer segment.
  - Impact: Retention +8 to +12% for that segment.
  - Effort: High.
  - Dependencies: Income modeling, risk scoring.

3. **Goal-Linked "Pause Spend" Mode**
  - Problem: Users fail short-term saving goals.
  - Value: Temporary spend-freeze nudges and reminders.
  - Monetization: Behavioral change and goal success.
  - Impact: Engagement +6 to +10%.
  - Effort: Medium.
  - Dependencies: Notifications, behavior engine.

### 10.2 Target User Assumptions

- **Primary segments**: Students, salaried professionals, freelancers or gig workers, families.
- **Pain points by segment**:
  - Students: low awareness, overspending, impulse categories.
  - Salaried: subscription creep, surprise bills, multi-bank fragmentation.
  - Freelancers: irregular income, tax readiness, cash flow stress.
  - Families: hidden spending, no shared visibility, trust gaps.
- **Mobile vs web**: 90%+ mobile; web optional for exports and audits.
- **Geography**: India and UPI-heavy ecosystems; SMS and notification parsing are core.
- **Integration**: Premium features build on SMS parsing, notification detection, and budgeting.

### 10.3 Feature Impact and Pricing Strategy (MUST-HAVE)

Pricing tiers (fixed): Monthly: Rs 50, Yearly: Rs 450, Family add-on: Rs 25.

- **Smart Auto-Categorization**
  - Impact: +12% D30 retention, +7% upgrade.
  - Value tier: Automation.
  - Pricing: Premium subscription, trial unlock.

- **Bill + Subscription Detection**
  - Impact: +10% D30 retention, +6% upgrade.
  - Value tier: Peace-of-mind.
  - Pricing: Premium subscription.

- **Spending Limits + Alerts**
  - Impact: +15% engagement, +8% upgrade.
  - Value tier: Utility.
  - Pricing: Premium subscription, allow one free category.

- **Cash Flow Forecast**
  - Impact: +8% retention, +5% upgrade.
  - Value tier: Intelligence.
  - Pricing: Premium subscription.

- **Multi-Account Consolidation**
  - Impact: +10% conversion, +8% D30 retention.
  - Value tier: Utility.
  - Pricing: Premium subscription, one account free.

### 10.4 Phased Rollout Plan

**Phase 1: MVP Premium Launch**
- Features: Auto-categorization, bill detection, budgets and alerts.
- Success metrics: D7 retention, budget adoption, upgrade rate.
- Tech risks: SMS variability, false recurrence detection.
- UX risks: Over-alerting and too many settings.
- Performance: Rule engine efficiency on device.
- Compliance and privacy: Clear SMS consent and data minimization.

**Phase 2: Expansion and Differentiation**
- Features: Cash flow forecast, multi-account, anomaly alerts.
- Success metrics: D30 retention, ARPU, depth of feature use.
- Tech risks: Forecast accuracy, dedupe issues.
- UX risks: Trust in forecast accuracy.
- Performance: Caching and batch processing.
- Compliance and privacy: PII handling, opt-out clarity.

**Phase 3: Long-tail and AI-Powered**
- Features: AI co-pilot, dynamic budgets, family view.
- Success metrics: D90 retention, referrals, power-user stickiness.
- Tech risks: AI hallucinations, model cost.
- UX risks: Over-automation and cognitive overload.
- Performance: On-device vs server inference balance.
- Compliance and privacy: Explainability and data minimization.

### 10.5 Success Metrics and Growth Model

- **Activation rate**: First 7-day budget or insight use.
- **Free to paid conversion**: Upgrade within 14 days.
- **Feature adoption**: Users who use 2+ premium features.
- **Retention**: D7, D30, D90 trends.
- **ARPU**: Lifted by family add-on and multi-account.
- **Churn rate**: Reduced by accuracy, trust, and simple UX.
- **LTV:CAC**: Driven by retention and conversion improvements.
- **Engagement frequency**: Daily alerts and weekly summaries.

Feature support mapping:
- Auto-categorization and alerts improve activation and D7 retention.
- Bill detection and cash flow forecast improve conversion and D30 retention.
- Multi-account and family view improve ARPU and D90 retention.

### 10.6 Onboarding and Monetization UX

**Onboarding messaging**
- "We auto-organize your spending so you do not have to."
- "Get notified before bills hit."

**Contextual upgrade prompts**
- "Want this alert for every category?"
- "Enable smart bill tracking to avoid surprises."

**Free trial activation triggers**
- After 10+ transactions parsed or first recurring bill detected.

**Behavior-based nudges**
- "You are 85% through your dining budget. Unlock real-time alerts."

**Trust-building privacy messaging**
- "Your data stays on your device unless you enable cloud backup."
- "We only read financial details you approve."

### 10.7 Trial and Activation Strategies

- Trial duration: 7 days aligned with weekly spend cycles.
- Event triggers: first recurring bill or second overspend event.
- Paywall timing: after 2 to 3 insights are delivered.
- Behavioral offers: "You just avoided a bill surprise. Unlock full alerts."
- Avoid friction: keep one premium feature visible in free tier.

### 10.8 Risks and Pitfalls

- Trust risks: misclassified transactions or incorrect bill alerts.
- Monetization risks: paywalls before value is shown.
- Privacy pitfalls: unclear consent or over-collection.
- Performance risks: heavy analytics on device without caching.
- Over-feature risk: too many settings causing overload.
