# Component Library

## 1. Atoms
- **Colors**: Premium Slate Dark Theme (see `colors.md`).
- **Typography**: Outfit/Roboto based (see `typography.md`).
- **Icons**: Material Rounded Icons, tinted `AppTheme.textSecondary` unless active.

## 2. Molecules
- **Primary Action Button**: Custom `ElevatedButton`. Gradient blue background, 16px radius, heavy bold uppercase text.
- **Input Fields**: Modern styled, outlined fields with floating labels and dynamic validation states.
- **Status Badges**: Small rounded cards with custom backgrounds denoting status (Settled: Green, Active: Blue, Overdue: Red).

## 3. Organisms (Shared Widgets)
- **Customer Card** (`CustomerCard`):
  - Row layout displaying Avatar Block, Name, phone, telegram, outstanding balance, and status badge.
- **Credit Item Card** (`CreditItemCard`):
  - Card displaying item name, quantity, unit price, total price, and localized Ethiopian Calendar deadline.
- **Payment Card** (`PaymentCard`):
  - Displays recorded cash/mobile/bank payment amount, before/after customer balances, and transaction timestamps.
- **Balance Summary Widget** (`BalanceSummaryWidget`):
  - Dashboard container summarizing business metrics (total balance, debts, paid).
- **Ethiopian Date Picker Dialog**:
  - Custom grid picker supporting the 13 months (including Pagume) of the Ethiopian Calendar.

## 4. Templates
- **Standard Page View**:
  - `Scaffold` -> Midnight background.
  - `AppBar` -> Zero elevation, uppercase title, back buttons.
  - `Body` -> Column containing details cards and scrollable lists with pull-to-refresh.
