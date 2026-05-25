# Architecture Documentation

## 1. Macroarchitecture
The application utilizes a modern **Cloud-Native / Feature-First / Layered Architecture** with an emphasis on scalability, real-time synchronization, and robust state management.

The application has been migrated from local-only SQLite to a cloud-synchronized system communicating with a **Dart Frog** API backend backed by **MongoDB Atlas**.

### Layers:
1. **Presentation Layer (`features/*/screens/`, `shared/widgets/`, `utils/`)**:
   - Contains UI definitions, Themes, custom pickers, and localization logic.
   - Declarative and reactive widgets that consume and react to Riverpod providers.
2. **Domain Layer (`core/models/`)**:
   - Contains pure Dart data classes representing MongoDB Atlas collections (`Owner`, `Customer`, `CreditItem`, `PaymentRecord`).
3. **State Management Layer (`features/*/providers/`, `core/providers/`)**:
   - Built on **Riverpod** (`AsyncNotifier`, `FutureProvider`, etc.) for unidirectional data flow, caching, and dependency injection.
4. **Data/Service Layer (`features/*/repositories/`, `core/network/`, `core/storage/`)**:
   - `ApiClient` (Dio client with JWT Interceptor).
   - CRUD Repositories communicating with the Dart Frog backend.
   - `SecureStorageHelper` utilizing `flutter_secure_storage` for token and owner profile caching.

## 2. Microarchitecture Details

### 2.1 State Management (Riverpod)
- Handled declaratively with self-invalidating providers (e.g. invalidating customer state when a payment is recorded or credit item added).
- Asynchronous states are safely handled using `AsyncValue` to show loading, error, and data states elegantly.

### 2.2 Navigation (GoRouter)
- Declarative router defined in `lib/core/router/app_router.dart`.
- Dynamic path matching (e.g. `/customers/:id`) and redirection guards based on JWT validation.

### 2.3 Network Interceptors
- A custom Bearer interceptor automatically injects authorization tokens.
- Global 401 Unauthorized handling automatically logs the user out and redirects back to the `/login` screen if a token expires.

### 2.4 Error Handling
- Server errors are returned as JSON response messages and surfaced safely in the UI.
- Local configurations and variables are safely loaded with fallbacks using `flutter_dotenv`.
