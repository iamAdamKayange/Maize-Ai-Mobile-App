# 🌽 MaizeAI – AI-Powered Maize Disease Detector

A complete, production-ready Flutter mobile application for detecting maize plant diseases using AI. Designed with a clean green agricultural theme, matching all 17 provided UI screens.

---

## Screens Implemented

1. lib
   1.1 main.dart

   1.2 loading_screen.dart
   1.3 started_screen.dart
   1.4 onboarding_screen.dart
   1.5 dashboard_screen.dart
   1.6 scanner_screen.dart
   1.7 scan_progress_screen.dart
   1.8 scan_results_screen.dart
   1.9 my_plant_screen.dart
   1.10 other_screens.dart
   1.11 drawer_menu.dart

   1.12 widgets
       1.12.1 custom_button.dart
       1.12.2 custom_card.dart
       1.12.3 disease_card.dart
       1.12.4 plant_card.dart
       1.12.5 recent_scan_card.dart
       1.12.6 notification_tile.dart
       1.12.7 save_report_dialog.dart

   1.13 models
       1.13.1 disease_model.dart
       1.13.2 plant_model.dart
       1.13.3 scan_result_model.dart
       1.13.4 notification_model.dart

   1.14 services
       1.14.1 camera_service.dart
       1.14.2 detection_service.dart
       1.14.3 storage_service.dart
       1.14.4 notification_service.dart

   1.15 utils
       1.15.1 app_colors.dart
       1.15.2 app_strings.dart
       1.15.3 app_images.dart
       1.15.4 constants.dart
       1.15.5 routes.dart

   1.16 assets
       1.16.1 images
             1.16.1.1 logo.png
             1.16.1.2 maize.png
             1.16.1.3 onboarding1.png
             1.16.1.4 onboarding2.png
             1.16.1.5 onboarding3.png

       1.16.2 icons
             1.16.2.1 scan.png
             1.16.2.2 plant.png
             1.16.2.3 notification.png

       1.16.3 animations
             1.16.3.1 loader.json


---

##  Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter extension
- Android: minSdk 21, targetSdk 34
- iOS: Deployment target 12.0+

### Installation

```bash
# 1. Clone or unzip the project
cd maize_ai

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# 4. Build release APK
flutter build apk --release

# 5. Build iOS
flutter build ios --release
```

---

##  Project Structure

```
maize_ai/
├── lib/
│   ├── main.dart                    # App entry + routes
│   ├── theme/
│   │   └── app_theme.dart           # Colors, typography, decorations
│   ├── models/
│   │   ├── disease_model.dart       # Disease data model + samples
│   │   └── plant_model.dart         # Plant data model + samples
│   ├── screens/
│   │   ├── loading_screen.dart
│   │   ├── started_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── scanner_screen.dart
│   │   ├── scan_progress_screen.dart
│   │   ├── scan_results_screen.dart
│   │   ├── my_plant_screen.dart
│   │   └── other_screens.dart       # Notification, Settings, About, Privacy
│   └── widgets/
│       ├── bottom_nav_bar.dart      # Notched bottom nav with FAB
│       ├── drawer_menu.dart         # Side drawer navigation
│       └── common_widgets.dart      # GreenButton, EmptyState, AnimatedCard, etc.
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml  # Camera + storage permissions
│   │       └── kotlin/.../MainActivity.kt
│   ├── build.gradle
│   └── gradle.properties
├── ios/
│   └── Runner/
│       └── Info.plist               # Camera + photo library permissions
├── assets/                          # Place images here
└── pubspec.yaml                     # Dependencies
```

---

## Design System

### Colors
| Token | Hex | Usage |
|---|---|---|
| `primaryGreen` | `#2E7D32` | Primary brand color |
| `lightGreen` | `#4CAF50` | Accents, progress bars |
| `accentGreen` | `#81C784` | Subtle fills |
| `softGreen` | `#E8F5E9` | Input backgrounds |
| `darkGreen` | `#1B5E20` | Dark variants |
| `purple` | `#9C27B0` | Gradient end (hero cards) |
| `errorRed` | `#D32F2F` | Disease detected label |
| `blue` | `#1976D2` | Previous button, links |

### Typography
- **Font**: Poppins (Google Fonts)
- Titles: `700` weight
- Subtitles: `600` weight
- Body: `400` weight

### Key Components
- **`AppBottomNavBar`**: Notched bottom bar with centered FAB (scanner)
- **`DrawerMenu`**: Slide-out navigation with all 7 destinations
- **`GreenButton`**: Gradient elevated button with shadow
- **`AnimatedCard`**: Press-scale micro-interaction card
- **`ConfidenceBadge`**: Color-coded confidence indicator
- **`DiseaseTag`**: Detected / Healthy status chip

---

## Dependencies

```yaml
google_fonts: ^6.1.0           # Poppins font
smooth_page_indicator: ^1.1.0  # Onboarding dots
animated_text_kit: ^4.2.2      # Text animations
percent_indicator: ^4.2.3      # Progress bars
flutter_svg: ^2.0.9            # SVG support
image_picker: ^1.0.7           # Camera & gallery
shared_preferences: ^2.2.2     # Local storage
lottie: ^3.0.0                 # Lottie animations
provider: ^6.1.1               # State management
```

