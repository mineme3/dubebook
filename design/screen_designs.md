# Screen Designs Specification

## 1. Login & Registration Screens (`login_screen.dart`, `register_screen.dart`)
- **Purpose**: JWT account creation and authentication.
- **Layout**: Sleek form inputs (Email, Password, FullName, ShopName, Telegram Chat ID). Action buttons to toggle between Login and Registration. Include error alerts and loading overlays.

## 2. Dashboard Screen (`dashboard_screen.dart`)
- **Purpose**: Primary view showing business health and outstanding debtors.
- **Components**:
  - **AppBar**: App title, Notifications log button, Settings button.
  - **Hero Balance summary**: Displays outstanding balances, total debts, and payment totals.
  - **Customer List**: Interactive, search-queryable list of customers showing their balance, status (Active/Settled/Overdue), and phone/telegram coordinates.
  - **FAB**: Extended button for adding a new customer.

## 3. Customer Detail Screen (`customer_detail_screen.dart`)
- **Purpose**: Tabbed ledger listing customer's credits and payments.
- **Components**:
  - **Summary Card**: Displays outstanding totals and Telegram reminder status.
  - **Tab View**:
    - **Credit Items Tab**: Shows items taken on credit, unit details, total price, and deadline.
    - **Payment History Tab**: Shows payments received, payment method, before/after balances, and date.
  - **Bottom Action Bar**: Quick navigation actions to "Add Credit Item" and "Record Payment".

## 4. Add Credit Item Screen (`add_credit_item_screen.dart`)
- **Purpose**: Log a new credit entry for a customer.
- **Components**: Form inputs for Item Name, Unit Type (kg/liter/piece/etc.), Quantity, Unit Price, and Deadline (using Ethiopian Date Picker). Live balance total calculator.

## 5. Record Payment Screen (`record_payment_screen.dart`)
- **Purpose**: Record a payment against a customer's balance.
- **Components**: Form inputs for Amount, Payment Method (Cash/Mobile Money/Bank/Other), and Note. Projected balance calculator to show updated balance prior to submitting.

## 6. Notification Log Screen (`notification_log_screen.dart`)
- **Purpose**: Monitor delivery history of Telegram reminder notifications.
- **Components**: List of notification logs, type (deadline remind/payment alert), delivery status (Sent/Failed), and backend error codes if delivery fails.

## 7. Settings Screen (`settings_screen.dart`)
- **Purpose**: Account management and app configuration.
- **Components**: Owner profile detail card, language selection dropdown, connection/sync indicators, and device logout action.
