# 🏆 ArenaFlow - Sports Tournament Management System

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-blue.svg" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Firebase-Enabled-orange.svg" alt="Firebase">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
</div>

<div align="center">
  <h3>⚽ 🏏 🏀 🏐</h3>
  <p><em>A comprehensive sports management application built with Flutter for organizing tournaments, managing teams, and tracking live matches across multiple sports.</em></p>
</div>

---

## 📱 Features

### 🏆 Tournament Management
- **Multi-Sport Support**: Football, Cricket, Basketball, Volleyball, and more
- **Tournament Types**: Single Elimination, Double Elimination, Round Robin
- **Real-time Tournament Brackets**: Interactive bracket visualization
- **Live Standings**: Dynamic leaderboards with real-time updates
- **Match Scheduling**: Automated and manual match scheduling

### 👥 Team & Player Management
- **Team Registration**: Easy team creation and management
- **Player Profiles**: Detailed player information with statistics
- **Team Rosters**: Comprehensive team member management
- **Player Statistics**: Track individual performance metrics
- **Position Management**: Role-based player categorization

### 📊 Live Match Tracking
- **Real-time Score Updates**: Live match scoring system
- **Match Status Tracking**: Scheduled, In Progress, Completed states
- **User Dashboard**: Dedicated panels for different user types
- **Match Details**: Comprehensive match information and history

### 🎨 Modern UI/UX
- **Gradient Themes**: Beautiful modern interface design
- **Smooth Animations**: Engaging transitions and micro-interactions
- **Responsive Design**: Optimized for all screen sizes
- **Glass-morphism Effects**: Contemporary visual elements
- **Dark/Light Theme Support**: Adaptive color schemes

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile development |
| **Dart** | Programming language |
| **Firebase Firestore** | Real-time database |
| **Firebase Auth** | Authentication system |
| **Cloud Functions** | Serverless backend logic |
| **Custom Animations** | Enhanced user experience |


---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (2.17+)
- Firebase project setup
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
git clone https://github.com/rudrapratap19/ArenaFlow-main.git
cd ArenaFlow-main

2. **Install dependencies**
flutter pub get

3. **Firebase Setup**
- Create a new Firebase project
- Add your `google-services.json` (Android) 
- Enable Firestore Database and Authentication

4. **Run the application**
flutter run

---

## 🎯 Key Functionality

### Tournament Creation
// Create tournament with multiple formats
Tournament tournament = Tournament(
name: "Summer Championship",
sport: "Football",
type: TournamentType.singleElimination,
teams: selectedTeams,
startDate: DateTime.now(),
);

### Real-time Match Updates
// Stream live match data
StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
.collection('matches')
.where('status', isEqualTo: 'in_progress')
.snapshots(),
builder: (context, snapshot) {
// Build live match cards
},
);


### Player Management
// Add player with detailed information
Player player = Player(
name: "John Doe",
jerseyNumber: 10,
position: "Striker",
age: 25,
statistics: playerStats,
);


---

## 📸 Screenshots

<div align="center">
  <table>
    <tr>
      <td><img src="screenshots/home.png" width="200"/></td>
      <td><img src="screenshots/tournaments.png" width="200"/></td>
      <td><img src="screenshots/teams.png" width="200"/></td>
      <td><img src="screenshots/live-matches.png" width="200"/></td>
    </tr>
    <tr>
      <td align="center"><em>Home Screen</em></td>
      <td align="center"><em>Tournaments</em></td>
      <td align="center"><em>Team Management</em></td>
      <td align="center"><em>Live Matches</em></td>
    </tr>
  </table>
</div>

---

## 🎨 UI Components

### Enhanced Pages
- **Tournament List**: Modern card-based tournament display
- **Team Management**: Professional team creation and editing
- **Player Profiles**: Comprehensive player information system
- **Live Matches**: Real-time match tracking interface
- **Tournament Brackets**: Interactive bracket visualization
- **Standings**: Dynamic leaderboard with animations

### Design Features
- **Gradient Backgrounds**: Consistent blue theme across pages
- **Glass-morphism**: Semi-transparent containers with blur effects
- **Smooth Animations**: Staggered entrance and transition animations
- **Professional Cards**: Elevated cards with proper shadows
- **Responsive Layout**: Keyboard-friendly and adaptive design

---


---

## 🎮 Sports Supported

| Sport | Features | Tournament Types |
|-------|----------|------------------|
| ⚽ **Football** | 11v11, Positions, Statistics | All formats |
| 🏏 **Cricket** | Batsmen, Bowlers, All-rounders | Round Robin, Knockout |
| 🏀 **Basketball** | 5v5, Position-specific stats | All formats |
| 🏐 **Volleyball** | 6v6, Specialized positions | All formats |
| 🏈 **American Football** | Full roster support | All formats |


---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style Guidelines
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Add comments for complex logic
- Write unit tests for new features

---
