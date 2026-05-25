# Product Overview: DubeBook

## 1. Product Overview
DubeBook is a modern mobile and desktop application built with Flutter, tailored for managing informal shop credit systems (locally known as "Dube"). Operating with a secure cloud-native architecture powered by a **Dart Frog API** and **MongoDB Atlas**, it provides local merchants with a digital replacement for manual ledger books. DubeBook supports multiple local languages (Amharic, Oromo, English) and utilizes native Ethiopian Calendar systems to perfectly fit the temporal context of its target audience.

## 2. Project Objectives
- Transition manual, paper-based ledger systems to a secure and resilient cloud-synchronized solution.
- Enhance the accuracy of debt calculations and transaction histories with automated backend operations.
- Support local customs, languages, and calendar systems (Ethiopian Calendar) inherently.
- Connect shop owners and customers using Telegram notifications.

## 3. Business Goals
- Improve credit recovery rates for local business owners by providing automated Telegram payment deadline reminders.
- Provide structured repayment tracking and easy tracking of total customer debt.
- Maintain transparent transaction history for accountability.

## 4. User Personas
**1. The Local Merchant (Shop Owner)**
- **Needs**: Fast entry, clear visibility of total outstanding debts, reminder of overdues, and cross-device sync.
- **Pain Points**: Losing physical ledgers, calculating accumulated debt manually, translating Gregorian dates to local Ethiopian dates.

## 5. User Journey Map
1. **Authentication**: User logs in securely or registers a new owner account (FullName, ShopName, Telegram Chat ID, Email, Password).
2. **Dashboard**: User sees the total outstanding money (Hero Card) and a list of all customers with pending debts, categorized by status (Active, Settled, Overdue).
3. **Adding a Customer**: User registers a new customer setting a name, address, phone number, and telegram username.
4. **Logging Credit Items**: User logs new items taken on credit, specifying quantity, unit price, and an Ethiopian Calendar deadline.
5. **Recording Payments**: User records payments (Cash, Mobile Money, Bank Transfer) which immediately decrement the customer's outstanding balance.
6. **Notification Logs**: User monitors successfully scheduled/delivered automated reminders.

## 6. Information Architecture
```
[ App Root ]
 ├── Login / Register Screen
 ├── Dashboard (Unpaid Customers + Hero Stats)
 │    ├── Customer Details (Credit Items List & Payment History Tabs)
 │    │    ├── Add Credit Item (Ethiopian Calendar Deadline picker)
 │    │    └── Record Payment (Projected balance after payment indicator)
 │    ├── Settings (Language, Dark Theme, Owner Profile Card, Logout)
 │    └── Notifications Log (Logs for telegram deliveries)
```

## 7. UX Decisions and Rationale
- **Cloud-Native Integration**: Ensures data integrity, preventing data loss if a device is stolen, broken, or replaced.
- **Simplicity prioritized**: Driven by simplicity first—the shop owner can register a customer or log a credit item with minimal taps.
- **Ethiopian Date Picker**: Completely custom-built calendar picker addressing a significant localization requirement that standard libraries fail to meet.
- **Automatic Telegram Notifications**: Backend sweep runs daily, dispatching reminders directly to customers' Telegram accounts.
- **JWT Auth Protection**: Ensures that owner ledger details are accessible only via authorized devices.
