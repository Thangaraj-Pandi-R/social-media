# SocialSpace - Developer Social Media Application

A clean, responsive social media application built using Flutter. This project strictly follows Feature-Based Clean Architecture (Clean MVVM) with Provider for state management, offering an automated local Mock Mode and full Firebase connectivity.

---

## 📐 Architecture Explanation

The application follows **Feature-Based Clean Architecture** (Feature-first structure). Each product module is self-contained and divided internally into three layers:

```text
lib/
├── main.dart                      # App initialization & provider setup
├── app_config.dart                # Dependency injection & Firebase detection
├── core/                          # Shared themes, utilities, and generic widgets
└── features/                      # Modular features (auth, comment, feed, post, profile)
    └── [feature]/
        ├── domain/                # Enterprise & Business Logic (framework-independent)
        │   ├── entities/          # Pure business data objects
        │   ├── repositories/      # Repository interface contracts
        │   └── usecases/          # Single-responsibility interactors (e.g. login, create post)
        ├── data/                  # Infrastructure & data access mapping
        │   ├── models/            # JSON/Firestore serialization
        │   └── repositories/      # Concrete repository implementations
        └── presentation/          # Views and ViewModels
            ├── providers/         # ViewModels / ChangeNotifier controllers
            └── views/             # Screen and widget UI definitions
```

### Key Principles
- **Domain Layer**: Contains pure business logic and contracts with zero external dependencies (no Flutter or Firebase imports).
- **Data Layer**: Concrete data mapping and external API/database communication (coordinates Firestore reads/writes, translates raw data to domain entities).
- **Presentation Layer**: Connects UI widgets to the state controllers (ChangeNotifiers). The widgets are stateless/stateful UI components, observing state changes via Provider.

---

## 🚀 Setup & Installation

### 📋 System Requirements
- **Flutter SDK**: `^3.44.1`
- **Android Studio**: `^2026.1`
- **Xcode** (for iOS/macOS build): `^26.0`

The project uses a dual-repository pattern that auto-detects Firebase configuration. If Firebase config files are missing, it transparently launches in **Mock Mode** using in-memory databases preloaded with demo data.

### Option A: Local Testing (Mock Mode - Quickest)
1. Ensure the system requirements are met.
2. Run package resolution:
   ```bash
   flutter pub get
   ```
3. Run the application directly:
   - **For Web**: `flutter run -d chrome`
   - **For macOS**: `flutter run -d macos`
   - **For Mobile**: `flutter run`

### Option B: Firebase Integration
1. Create a project in the [Firebase Console](https://console.firebase.google.com).
2. Enable **Email/Password** authentication, **Cloud Firestore**, and **Firebase Storage**.
3. Apply standard Firestore rules allowing read/write for authenticated users:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
4. Download and place the target configuration files in the platform directory paths:
   - **Android**: `android/app/google-services.json`
   - **iOS / macOS**: `GoogleService-Info.plist` (registered inside Runner projects via Xcode)
   - **Web**: Run `flutterfire configure` to generate `lib/firebase_options.dart`.
5. Run `flutter run` to start the app in Firebase Mode.

---

## 🛠️ Assumptions & Trade-offs

1. **Denormalization (Read Optimization)**
   - *Assumption*: Feeds are read-heavy operations. Fetching post authors' usernames or profile picture URLs via sequential Firestore joins is inefficient.
   - *Trade-off*: Author names and avatars are denormalized inside the `Post` and `Comment` documents. Updates to profile details propagate asynchronously. This speeds up feed fetch queries to $O(1)$ complexity.

2. **Client-Side Feed Filtering**
   - *Assumption*: Firestore `whereIn` arrays are limited to 30 items. If a user follows more than 30 accounts, simple in-queries will crash.
   - *Trade-off*: We query posts chronologically and perform client-side matching. For a highly scaled production application, a fan-out timeline database approach would be implemented instead.

3. **In-Memory Mock Database Lifecycle**
   - *Assumption*: Mock databases must match normal database behaviors during evaluation.
   - *Trade-off*: Mock data resides in an in-memory repository instance. Changes persist during the active session but reset on app restart.
