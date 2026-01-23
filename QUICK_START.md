# ArenaFlow - Quick Start Guide

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.0)
- Firebase project configured
- Android Studio / VS Code
- Git

### Installation

1. **Clone and Setup:**
   ```bash
   cd c:\Users\rudra\Downloads\arenaflow\arenaflow
   flutter pub get
   ```

2. **Firebase Configuration:**
   - Follow instructions in `FIREBASE_SETUP.md`
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place files in correct directories

3. **Run the App:**
   ```bash
   flutter run
   ```

## 📱 User Guide

### First Time Setup

#### 1. **Create Admin Account**
- Open app → Tap "Sign Up"
- Enter name, email, password
- Select "Admin" role
- Tap "Sign Up"

#### 2. **Login**
- Enter credentials
- Check "Remember Me" (optional)
- Tap "Login"

### Admin Workflow

#### **Step 1: Create Teams**
1. From Admin Panel → Tap "Manage Teams"
2. Tap "+" (Add Team)
3. Select sport (Football/Cricket/Basketball/Volleyball)
4. Enter team name
5. Tap "Create Team"

#### **Step 2: Add Players**
1. Teams List → Tap on a team
2. Tap "+" (Add Player)
3. Enter player details:
   - Name, Jersey Number, Position
   - Age, Phone, Email
   - Height, Weight, Experience
4. Tap "Add Player"
5. Repeat for all players

#### **Step 3: Create Tournament**
1. Admin Panel → "Create Tournament"
2. Fill tournament details:
   - Tournament Name
   - Select Sport
   - Choose Type (Single Elimination/Double Elimination/Round Robin)
   - Set Start Date
   - Select Teams (minimum 2)
3. Tap "Create Tournament"
4. Bracket is automatically generated!

#### **Step 4: View & Manage**
- **View Tournaments:** Admin Panel → "All Tournaments"
- **View Matches:** Admin Panel → "All Matches"
  - Switch tabs: All / Live / Scheduled
- **Manage Teams:** Admin Panel → "Manage Teams"

## 🎮 Feature Overview

### Sports Supported
- ⚽ **Football**
- 🏏 **Cricket**
- 🏀 **Basketball**
- 🏐 **Volleyball**

### Tournament Types
1. **Single Elimination:**
   - One loss = out
   - Winner advances
   - Automatic bracket with byes

2. **Double Elimination:**
   - Two losses = out
   - Winner & Loser brackets
   - (Structure ready, full implementation pending)

3. **Round Robin:**
   - Every team plays every other team
   - Points: Win=3, Draw=1, Loss=0
   - Standings with goal difference

### Match Status
- 🟠 **Scheduled** - Upcoming matches
- 🟢 **Live** - Currently playing
- ⚪ **Completed** - Finished matches
- 🔴 **Cancelled** - Cancelled matches

## 🎨 UI Features

### Animations
- Smooth page transitions (slide + fade)
- Animated sport selection
- Card animations in lists
- Loading indicators

### Color Coding
- Each sport has unique gradient
- Status-based colors
- Role-based themes

### Responsive Design
- Works on phones and tablets
- Adaptive layouts
- Touch-friendly buttons

## 🔧 Admin Features

### Dashboard Quick Actions
1. **All Matches** - View/manage all matches
2. **Manage Teams** - CRUD operations on teams
3. **All Tournaments** - Browse tournaments
4. **Create Tournament** - Launch tournament wizard

### Team Management
- Create teams for any sport
- Edit team details
- Delete teams (with confirmation)
- View player count
- Cascade deletion (deletes players too)

### Player Management
- Add players with full profile
- Edit player information
- Delete players
- View player roster
- Track statistics

### Tournament Management
- Create tournaments
- Select participating teams
- Auto-generate brackets
- Track tournament status
- View standings

### Match Management
- View all matches
- Filter by status (All/Live/Scheduled)
- View match details
- Track scores
- See winner/loser

## 👤 User Features (Current)

### User Dashboard
- View upcoming matches
- See live matches
- Browse tournaments
- Check team information

## 📊 Data Flow

```
User Action
    ↓
View (UI)
    ↓
Bloc Event
    ↓
Bloc (Business Logic)
    ↓
Repository
    ↓
Firebase (Firestore)
    ↓
Stream Updates
    ↓
Bloc State
    ↓
View Updates
```

## 🎯 Common Tasks

### Create a Football Tournament
1. Create at least 2 football teams
2. Add players to each team
3. Go to Create Tournament
4. Select Football sport
5. Choose Single Elimination
6. Select teams
7. Set start date
8. Create!

### View Team Roster
1. Admin Panel → Manage Teams
2. Filter by sport (if needed)
3. Tap on team card
4. See all players with jersey numbers

### Check Match Schedule
1. Admin Panel → All Matches
2. Switch to "Scheduled" tab
3. View upcoming matches with dates

## 🐛 Troubleshooting

### Firebase Connection Issues
- Check `FIREBASE_SETUP.md`
- Verify config files are in place
- Ensure Firebase project is active

### App Not Building
```bash
flutter clean
flutter pub get
flutter run
```

### Login Not Working
- Verify Firebase Auth is enabled
- Check email/password in Firebase Console
- Ensure user collection rules allow read/write

## 📋 TODO Features

### Coming Soon:
- ⏳ Player profile page
- ⏳ Tournament bracket view
- ⏳ Standings page
- ⏳ Match score entry
- ⏳ Live match tracking
- ⏳ Player statistics
- ⏳ Team statistics
- ⏳ Search functionality
- ⏳ Notifications
- ⏳ User favorites

## 💡 Tips

1. **Always create teams before tournaments**
2. **Add players to teams for accurate roster**
3. **Use descriptive tournament names**
4. **Select correct sport for teams/tournaments**
5. **Check team count before creating tournament**
6. **Use Remember Me for quick access**

## 🔐 Security

- Role-based access control
- Firebase Authentication
- Secure password handling
- Session persistence
- Auto-logout option

## 📱 Screen Flow

```
Login/SignUp
    ↓
Admin Panel / User Panel
    ↓
├── Manage Teams → Teams List → Add Team / Team Roster → Add Player
├── Create Tournament → Tournament Wizard
├── All Tournaments → Tournaments List → Tournament Details
└── All Matches → Matches List → Match Details
```

## 🎓 Learning Resources

- **Flutter Bloc:** https://bloclibrary.dev/
- **Firebase:** https://firebase.google.com/docs
- **Material Design 3:** https://m3.material.io/

---

**Need Help?** Check `PROJECT_STRUCTURE.md` for architecture details or `PROJECT_STATUS.md` for implementation status.
