<p align="center">
  <img src="assets/images/app_icon_foreground.png" alt="Dube Note Logo" width="120" />
</p>

<h1 align="center">Dube Note</h1>

<p align="center">
  <strong>Offline-first credit management system for small retail businesses</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-blue?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/Framework-Flutter-02569B?style=flat-square&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Database-SQLite-003B57?style=flat-square&logo=sqlite" alt="SQLite" />
  <img src="https://img.shields.io/badge/Version-1.0.0-green?style=flat-square" alt="Version" />
  <img src="https://img.shields.io/badge/License-Private-lightgrey?style=flat-square" alt="License" />
</p>

---

## Overview

**Dube Note** is a production-grade mobile application purpose-built for small retail shop owners who extend informal credit to their customers. It replaces the traditional paper-based "dube" (credit notebook) with a secure, fast, and reliable digital system that works entirely offline.

The application handles the complete credit lifecycle — from registering customers and recording individual item-level transactions, to calculating outstanding balances in real-time, settling debts, and maintaining a full payment history.

---

## Key Features

### Customer & Credit Management
- **Customer Registry** — Register customers with optional payment deadlines; view all active debtors sorted by outstanding balance.
- **Item-Level Transactions** — Record each credit entry with item name, quantity, and unit price. Totals are computed automatically.
- **Real-Time Debt Calculation** — Outstanding balances are derived dynamically from unpaid transactions, eliminating desync errors inherent in manual bookkeeping.
- **One-Tap Settlement** — Settle a customer's full balance in a single action; all unpaid transactions transition to the paid history archive.

### Security & Privacy
- **100% Offline Architecture** — Zero network dependencies. No external APIs, no cloud sync, no telemetry. All data resides exclusively on the device.
- **Password-Protected Access** — The application is secured behind a SHA-256 hashed master password, set on first launch.
- **Security Question Recovery** — Forgot-password flow via two user-defined security questions (city of birth & year shop opened), with answers stored locally.
- **Automatic Session Lock** — Idle sessions are terminated after 5 minutes of inactivity, automatically returning to the login screen.

### Notifications & Backups
- **Deadline Reminders** — Local push notifications alert the shop owner one day before and on the day of a customer's payment deadline. Fully configured for both **Android** (exact alarms) and **iOS** (alert, badge, and sound permissions requested at runtime via `DarwinInitializationSettings`).
- **Database Export** — One-tap backup exports the raw SQLite `.db` file via the native share sheet — send it to email, Google Drive, or any storage medium.

---

## Architecture

Dube Note follows a clean, layered architecture designed for maintainability and simplicity without over-engineering.

```
lib/
├── main.dart                   # App entry point, session management
├── database/
│   └── database_helper.dart    # SQLite schema, CRUD operations, queries
├── models/
│   ├── customer.dart           # Customer entity (name, note, deadline)
│   ├── app_transaction.dart    # Transaction entity (item, qty, price, status)
│   └── user.dart               # User entity (password hash, security answers)
├── services/
│   ├── auth_service.dart       # Password hashing, login, setup, recovery
│   ├── backup_service.dart     # Database file export via share sheet
│   └── notification_service.dart # Scheduled local notifications (timezone-aware)
├── screens/
│   ├── splash_setup_screen.dart  # First-launch onboarding & password setup
│   ├── login_screen.dart         # Authentication & password recovery
│   ├── dashboard_screen.dart     # Main view: total debt, customer list
│   ├── customer_detail_screen.dart # Per-customer balance & transaction list
│   ├── add_transaction_screen.dart # New credit entry form
│   ├── history_screen.dart       # Paid transaction archive
│   └── settings_screen.dart      # Backup export & app info
└── utils/
    └── theme.dart              # Design system: colors, typography, components
```

### Tech Stack

| Layer              | Technology                                                                 |
|--------------------|---------------------------------------------------------------------------|
| **Framework**      | [Flutter](https://flutter.dev/) (Dart)                                    |
| **Local Database** | [sqflite](https://pub.dev/packages/sqflite) / sqflite_common_ffi          |
| **Authentication** | SHA-256 hashing via [crypto](https://pub.dev/packages/crypto)             |
| **Notifications**  | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) — Android (exact alarms, channels) + iOS (Darwin alerts, badge, sound) + timezone scheduling |
| **Backup/Share**   | [share_plus](https://pub.dev/packages/share_plus)                         |
| **State Mgmt**     | `StatefulWidget` + `FutureBuilder` (deliberately minimal, no external state libraries) |

---

## Application Flow

```
[ Start ]
           │
           ▼
  ┌─────────────────┐           ┌─────────────────┐           ┌─────────────────┐
  │  FIRST LAUNCH   │           │  SETUP SCREEN   │           │    DASHBOARD    │
  │  (Auth Check)   │ ────────▶ │ (Password + SQ) │ ────────▶ │ (Customer List) │
  └─────────────────┘           └─────────────────┘           └────────┬────────┘
           │                                                           │
           │ (If account exists)                                       │
           ▼                                                           │
  ┌─────────────────┐                                  ┌───────────────┼───────────────┐
  │  LOGIN SCREEN   │                                  ▼               ▼               ▼
  │   (Password)    │ ────────▶                ┌───────────────┐ ┌───────────┐   ┌──────────┐
  └─────────────────┘                          │ CUSTOMER INFO │ │  HISTORY  │   │ SETTINGS │
                                               └───────┬───────┘ └───────────┘   └──────────┘
                                                       │
                                                       ▼
                                               ┌───────────────┐
                                               │ ADD TRANSAC.  │
                                               └───────────────┘
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.11.5+)
- Android Studio or VS Code with Flutter/Dart plugins
- A physical device or emulator (Android/iOS)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd dubebook

# Install dependencies
flutter pub get

# Run on Android
flutter run

# Run on iOS (requires macOS with Xcode)
cd ios && pod install && cd ..
flutter run --device-id <ios-device-or-simulator>
```

### First Launch

1. **Set a master password** — minimum 4 characters.
2. **Answer two security questions** — city of birth and the Ethiopian calendar year your shop opened.
3. **Start managing credit** — you'll be taken directly to the dashboard.

> Your data never leaves the device. There is no account creation, no sign-up, and no internet requirement.

---

## Data Model

```
┌──────────┐       ┌──────────────┐       ┌──────────────┐
│  users   │       │  customers   │       │ transactions │
├──────────┤       ├──────────────┤       ├──────────────┤
│ id (PK)  │       │ id (PK)      │◄──────│ id (PK)      │
│ password │       │ name         │  1:N  │ customer_id  │
│ _hash    │       │ note         │       │ item_name    │
│ security │       │ deadline     │       │ quantity     │
│ _q1      │       │ created_at   │       │ price        │
│ _q2      │       │              │       │ total        │
└──────────┘       └──────────────┘       │ status (0/1) │
                                          │ date         │
                                          └──────────────┘
                                          0 = Unpaid
                                          1 = Paid
```

---

## Currency

Dube Note uses **Ethiopian Birr (ETB)** as the default currency, reflecting its target market of small Ethiopian retail shops. The Ethiopian calendar is also used for the security question during setup.

---

## Backup & Recovery

Navigate to **Settings → Export Local Backup** to share the SQLite database file via:
- Email attachment
- Google Drive / cloud storage
- Local file transfer

The exported `.db` file contains all customer records, transactions, and authentication data.

---

## Design Philosophy

- **Minimal Taps** — Core actions (add customer, add credit, settle debt) require the fewest possible interactions.
- **High Contrast Light Theme** — Optimized for outdoor readability and quick scanning in a shop environment.
- **Information Hierarchy** — Outstanding totals and customer names are typographically prominent; secondary data is subdued.
- **Animated Transitions** — Smooth fade and slide animations provide spatial context without sacrificing speed.

---

## Cross-Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Android** | ✅ Fully supported | Primary target. Exact alarm notifications, adaptive icons configured. |
| **iOS** | ✅ Fully supported | Darwin notification permissions (alert, badge, sound) requested at runtime. SafeArea handles notch/Dynamic Island. |
| **Linux** | ⚠️ Partial | Runs via `sqflite_common_ffi`. Notifications fallback to immediate display (no scheduled support). |
| **Windows** | ⚠️ Partial | Runs via `sqflite_common_ffi`. Notification scheduling not supported. |
| **macOS** | ⚠️ Partial | Builds but not primary target. |

---

## Team

Developed by **WECAN TEAM**

---

<p align="center">
  <sub>Dube Note — Digitizing trust, one transaction at a time.</sub>
</p>
