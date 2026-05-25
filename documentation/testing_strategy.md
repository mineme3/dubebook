# Testing Strategy

## 1. Overview
The testing strategy for DubeBook prioritizes backend REST endpoint functionality, Riverpod provider states, secure authentication lifecycle, localized Ethiopian calendar operations, and integration test coverage.

## 2. Unit Testing Strategy
- **Models**: Validate serialization/deserialization on JSON fields for cloud models: `Owner`, `Customer`, `CreditItem`, and `PaymentRecord`.
- **Date Utility Operations**:
  - Test Ethiopian calendar conversions to guarantee leap years and special 13th month (Pagume) lengths are formatted correctly.
- **State Logic**: Test provider states and Dio REST exceptions fallback behaviors.

## 3. Integration Testing Strategy
- **Backend API Integration**:
  - Verify endpoint behaviors on `/auth`, `/customers`, `/items`, and `/payments`.
  - Validate Bearer JWT token injection and auto-refresh middleware.
- **Flutter Integration Tests (`integration_test/app_test.dart`)**:
  - Mock and intercept MethodChannels (e.g. notifications plugin).
  - Simulate user flow creating a customer, logging items, and viewing transaction entries.

## 4. UI / Widget Testing Strategy
- **Screen Flow Validation**: Verify routing redirects unauthenticated clients to `/login`.
- **Localization delegates**: Ensure that English, Amharic, and Afan Oromo fall back to English on unsupported material widgets without crashing.
