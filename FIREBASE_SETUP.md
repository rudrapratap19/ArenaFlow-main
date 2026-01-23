# Firebase Setup Guide for ArenaFlow

## Step-by-Step Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Name your project: `ArenaFlow` (or any name you prefer)
4. Follow the setup wizard

### 2. Add Firebase to Your Flutter App

#### For Android:

1. In Firebase Console, click "Add app" → Select Android
2. Register your app:
   - **Package name**: `com.example.arenaflow` (or your package name from `android/app/build.gradle`)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`
5. Update `android/build.gradle`:
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
     }
   }
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   plugins {
     id 'com.google.gms.google-services'
   }
   ```

#### For iOS:

1. In Firebase Console, click "Add app" → Select iOS
2. Register your app:
   - **Bundle ID**: Found in `ios/Runner.xcodeproj`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into Runner folder

#### For Web:

1. In Firebase Console, click "Add app" → Select Web
2. Register your app
3. Copy the Firebase configuration
4. Update `web/index.html`:
   ```html
   <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js"></script>
   <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js"></script>
   <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js"></script>
   <script>
     const firebaseConfig = {
       apiKey: "YOUR_API_KEY",
       authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
       projectId: "YOUR_PROJECT_ID",
       storageBucket: "YOUR_PROJECT_ID.appspot.com",
       messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
       appId: "YOUR_APP_ID"
     };
     firebase.initializeApp(firebaseConfig);
   </script>
   ```

### 3. Enable Firebase Authentication

1. Go to Firebase Console → **Authentication**
2. Click "Get Started"
3. Select **Sign-in method** tab
4. Enable **Email/Password**
5. Click Save

### 4. Create Firestore Database

1. Go to Firebase Console → **Firestore Database**
2. Click "Create database"
3. Choose **Production mode** (or Test mode for development)
4. Select a Cloud Firestore location (choose nearest to your users)
5. Click "Enable"

### 5. Set Firestore Security Rules

Replace the default rules with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Teams collection - authenticated users can read, admins can write
    match /teams/{teamId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Admin';
    }
    
    // Players collection
    match /players/{playerId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Admin';
    }
    
    // Matches collection
    match /matches/{matchId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Admin';
    }
    
    // Tournaments collection
    match /tournaments/{tournamentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Admin';
    }
    
    // Tournament Matches collection
    match /tournamentMatches/{matchId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Admin';
    }
    
    // Performances collection
    match /performances/{performanceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Admin';
    }
  }
}
```

### 6. Run the App

```bash
# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Or run on specific platform
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

### 7. Create First Admin User

1. Run the app
2. Click "Sign Up"
3. Fill in details:
   - Name: `Admin`
   - Email: `admin@arenaflow.com`
   - Password: `admin123` (min 6 chars)
   - Role: Select **Admin**
4. Click "Sign Up"

### 8. Verify Setup

After signing up:
- Check Firebase Console → Authentication → Users (should see your user)
- Check Firebase Console → Firestore → Data (should see `users` collection)
- You should be redirected to Admin Panel

## Troubleshooting

### Error: "Firebase not initialized"
- Make sure you've added Firebase config files (`google-services.json` or `GoogleService-Info.plist`)
- Run `flutter clean` and `flutter pub get`

### Error: "No user found"
- Check Firebase Authentication is enabled
- Verify email/password sign-in method is enabled

### Error: "Permission denied"
- Check Firestore security rules
- Make sure user is authenticated

### Android Build Errors
- Update `android/build.gradle` with latest Gradle version
- Ensure `google-services` plugin is applied

## Environment Variables (Optional)

For better security, consider using environment variables:

1. Create `lib/core/config/firebase_config.dart`:
```dart
class FirebaseConfig {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  // ... other config
}
```

2. Run with:
```bash
flutter run --dart-define=FIREBASE_API_KEY=your_key
```

## Next Steps

✅ Firebase is now configured!
✅ Authentication is working!
✅ Firestore database is ready!

Now you can:
- Add more features (teams, matches, tournaments)
- Customize the UI
- Add more user roles
- Implement real-time updates

---

Need help? Check:
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase Console](https://console.firebase.google.com)
- [Flutter Documentation](https://flutter.dev)
