# MuscleMax - Fitness & Workout Accountability App

A comprehensive mobile workout application built with Flutter that helps users stay accountable with their fitness journey.

 Features (Phase 1 - MVP)

### ✅ Completed
- **Splash Screen** - Branded welcome screen with MUSCLEMAX logo
- **Onboarding Carousel** - 3 engaging screens explaining app benefits
- **Authentication Flow**
  - Login with email/password
  - Registration with full profile
  - Forgot Password
  - OTP Verification
  - Social OAuth placeholders (Google/Facebook)
- **Navigation** - GoRouter-based navigation system
- **Theme** - Dark theme with brand colors (#00ADB5 teal accent)

### 🚧 Coming Soon (Phase 2)
- User profile setup (height, weight, goals)
- Home dashboard with workout metrics
- Workout tracking by muscle groups
- Progress charts and analytics
- Exercise library with animations

## 🎨 Design

Design system based on Figma prototype with:
- **Primary Color**: Teal `#00ADB5`
- **Accent Colors**: Orange gradients, Red accents
- **Dark Background**: `#1D1E2C`, `#222831`
- **Fonts**: Bebas Neue, Montserrat, DM Sans

## 📦 Dependencies

```yaml
dependencies:
  flutter_svg: ^2.0.9           # SVG image support
  provider: ^6.1.1              # State management
  go_router: ^13.0.0            # Navigation
  shared_preferences: ^2.2.2    # Local storage
  email_validator: ^2.1.17      # Form validation
  smooth_page_indicator: ^1.1.0 # Carousel indicators
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS emulator or physical device

### Installation

1. **Clone or navigate to project**
   ```powershell
   cd "c:\Users\Acer\Documents\Programs\MuscleMax"
   ```

2. **Install dependencies**
   ```powershell
   flutter pub get
   ```

3. **Download Required Fonts** (Important!)
   
   The app uses custom fonts. Download and place them in `assets/fonts/`:
   
   - **Bebas Neue**: [Download](https://fonts.google.com/specimen/Bebas+Neue)
     - `BebasNeue-Regular.ttf`
   
   - **Montserrat**: [Download](https://fonts.google.com/specimen/Montserrat)
     - `Montserrat-Regular.ttf`
     - `Montserrat-Medium.ttf`
     - `Montserrat-SemiBold.ttf`
     - `Montserrat-Bold.ttf`
   
   - **DM Sans**: [Download](https://fonts.google.com/specimen/DM+Sans)
     - `DMSans-Regular.ttf`
     - `DMSans-Medium.ttf`
     - `DMSans-Bold.ttf`

4. **Run the app**
   ```powershell
   flutter run
   ```

## 📱 App Flow

```
Splash Screen (2s)
    ↓
Onboarding (3 screens with skip/next)
    ↓
Login Screen
    ├─→ Register Screen
    ├─→ Forgot Password → OTP Verification
    └─→ [Home Dashboard - Phase 2]
```

## 🗂️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # All screen widgets
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── forgot_password_screen.dart
│   └── otp_verification_screen.dart
├── widgets/                  # Reusable components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── social_button.dart
└── utils/                    # Utilities & config
    ├── app_colors.dart
    ├── app_theme.dart
    └── routes.dart

assets/
├── images/                   # SVG images from Figma
│   ├── logo_light.svg
│   ├── onboarding_fitness.svg
│   ├── onboarding_progress.svg
│   └── onboarding_goals.svg
└── fonts/                    # Custom fonts (download separately)
```

## 🎯 Testing

### Manual Testing Checklist
- [ ] Splash screen appears for 2 seconds
- [ ] Onboarding carousel swipes left/right
- [ ] Skip button navigates to login
- [ ] Email validation works on login/register
- [ ] Password visibility toggle works
- [ ] Forgot password navigates to OTP screen
- [ ] OTP auto-focuses next field
- [ ] All navigation routes work correctly

## 🔧 Development Commands

```powershell
# Get dependencies
flutter pub get

# Run app
flutter run

# Run on specific device
flutter run -d <device_id>

# Build APK
flutter build apk

# Run tests (when added)
flutter test

# Check for outdated packages
flutter pub outdated

# Clean build
flutter clean
```

## 🐛 Known Issues

1. **Fonts not loading** - Make sure all font files are placed in `assets/fonts/` directory
2. **SVG images not showing** - Check that `flutter_svg` package is installed
3. **Navigation errors** - Ensure all routes are registered in `routes.dart`

## 📝 TODO (Next Phase)

- [ ] Add user profile setup screens (height, weight)
- [ ] Implement home dashboard UI
- [ ] Create workout tracking system
- [ ] Add exercise library
- [ ] Implement data persistence (local DB)
- [ ] Add backend API integration
- [ ] Create user authentication service
- [ ] Add progress charts and analytics

## 🤝 Contributing

This is a private project. For issues or suggestions, contact the development team.

## 📄 License

Proprietary - All rights reserved

---

**Built with ❤️ using Flutter**
