# ArenaFlow - Tournament Management System

A Flutter application for managing sports tournaments, teams, players, and matches using Firebase, BLoC state management, and MVC architecture.

## Project Structure

```
lib/
├── core/                       # Core application files
│   ├── config/                 # App configuration
│   ├── constants/              # Constants (colors, strings, etc.)
│   │   ├── app_colors.dart     # Color palette
│   │   └── app_constants.dart  # App-wide constants
│   ├── routing/                # Navigation & routing
│   │   └── app_router.dart     # Route definitions
│   ├── theme/                  # Theme configuration
│   │   └── app_theme.dart      # App theme
│   ├── utils/                  # Utility functions
│   │   └── helpers.dart        # Helper functions
│   └── widgets/                # Reusable widgets
│
├── data/                       # Data layer (Models, Repositories, Services)
│   ├── models/                 # Data models
│   │   ├── auth/              # Auth models
│   │   │   └── user_model.dart
│   │   ├── team/              # Team models
│   │   ├── tournament/        # Tournament models
│   │   └── match/             # Match models
│   ├── repositories/          # Data repositories
│   │   ├── auth/
│   │   │   └── auth_repository.dart
│   │   ├── team/
│   │   ├── tournament/
│   │   └── match/
│   └── services/              # External services
│       └── firebase/
│           ├── firebase_service.dart
│           └── local_storage_service.dart
│
├── controllers/               # Controllers (Business Logic)
│   ├── auth/
│   ├── team/
│   ├── tournament/
│   └── match/
│
├── presentation/              # UI layer
│   ├── blocs/                # BLoC state management
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── team/
│   │   ├── tournament/
│   │   └── match/
│   ├── views/                # UI pages
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── sign_up_page.dart
│   │   ├── dashboard/
│   │   │   ├── admin_panel.dart
│   │   │   └── user_panel.dart
│   │   ├── home/
│   │   ├── team/
│   │   ├── tournament/
│   │   ├── match/
│   │   ├── profile/
│   │   └── common/
│   └── widgets/              # Reusable UI widgets
│
└── main.dart                 # App entry point
```

## Architecture

This project follows **MVC (Model-View-Controller)** architecture with **BLoC** pattern for state management:

- **Model**: Data models and business logic (`data/models/`)
- **View**: UI components (`presentation/views/`)
- **Controller**: Controllers that coordinate between models and views (`controllers/`)
- **BLoC**: State management using flutter_bloc (`presentation/blocs/`)

## Key Features Implemented

### ✅ Core Infrastructure
- Firebase integration (Auth + Firestore)
- BLoC state management setup
- Routing system with navigation
- Theme configuration
- Helper utilities
- Local storage (SharedPreferences)

### ✅ Authentication
- Login with email/password
- Sign up with role selection (Admin/User)
- Remember me functionality
- Password reset
- Auth state persistence
- Role-based navigation

### 📋 Upcoming Features
- Team management
- Player management
- Match scheduling
- Tournament management
- Live score updates
- Player statistics
- And more...

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.6          # State management
  equatable: ^2.0.5             # Value equality
  firebase_core: ^3.5.0         # Firebase core
  firebase_auth: ^5.3.1         # Firebase authentication
  cloud_firestore: ^5.4.4       # Cloud Firestore
  shared_preferences: ^2.3.2    # Local storage
  intl: ^0.19.0                 # Internationalization
```

## Firebase Setup Required

1. Create a Firebase project at https://console.firebase.google.com
2. Add Firebase to your Flutter app:
   - For Android: Download `google-services.json` → `android/app/`
   - For iOS: Download `GoogleService-Info.plist` → `ios/Runner/`
   - For Web: Add Firebase config to `web/index.html`

3. Enable Authentication:
   - Go to Firebase Console → Authentication
   - Enable Email/Password sign-in method

4. Create Firestore Database:
   - Go to Firebase Console → Firestore Database
   - Create database in production mode

## Firestore Structure

```
users/
  {uid}/
    - name: string
    - email: string
    - role: string (Admin/User)
    - createdAt: timestamp

teams/
  {teamId}/
    - name: string
    - sport: string
    - createdAt: timestamp

players/
  {playerId}/
    - teamId: string
    - name: string
    - jerseyNumber: number
    - position: string
    ...

matches/
  {matchId}/
    - team1Id: string
    - team2Id: string
    - sport: string
    - venue: string
    - scheduledTime: timestamp
    - status: string
    ...

tournaments/
  {tournamentId}/
    - name: string
    - sport: string
    - type: string
    - status: string
    - teamIds: array
    ...
```

## Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**:
   - Follow Firebase setup instructions above

3. **Run the app**:
   ```bash
   flutter run
   ```

## User Roles

- **Admin**: Full access to create/manage teams, matches, tournaments
- **User**: View matches, team rosters, tournament brackets

## Color Scheme

- Primary: Blue (#2196F3)
- Accent: Green (#4CAF50)
- Football: Light Blue (#42A5F5)
- Cricket: Orange (#FF7043)
- Basketball: Orange (#FF9800)
- Volleyball: Red (#EF5350)

## Contributing

This is a structured Flutter project following best practices:
- Clean architecture with separation of concerns
- BLoC for predictable state management
- Firebase for backend services
- Reusable components and utilities

## Next Steps

To continue development:
1. Implement team management features
2. Add match scheduling functionality
3. Create tournament bracket system
4. Add real-time score updates
5. Implement player statistics tracking

---

Built with ❤️ using Flutter + Firebase + BLoC
