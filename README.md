# 🌽 MaizeAI – AI-Powered Maize Disease Detector

A complete, production-ready Flutter mobile application for detecting maize plant diseases using AI. Designed with a clean green agricultural theme, matching all 17 provided UI screens.

---

## 📱 Screens Implemented

| Screen | File | Description |
|---|---|---|
| Loading | `loading_screen.dart` | Animated ring loader on app launch |
| Get Started | `started_screen.dart` | Splash with maize plant illustration |
| Onboarding 1 | `onboarding_screen.dart` | Detect Diseases Early |
| Onboarding 2 | `onboarding_screen.dart` | Snap & Get Results |
| Onboarding 3 | `onboarding_screen.dart` | Receive Treatment Advice |
| Dashboard | `dashboard_screen.dart` | Home with banner, disease cards, recent scans |
| Scanner | `scanner_screen.dart` | Live camera overlay + detection popup |
| Scan Progress | `scan_progress_screen.dart` | Animated ring with "Please Don't Close" |
| Scan Results | `scan_results_screen.dart` | Disease info, confidence score, prevention |
| Save Report Dialog | `scan_results_screen.dart` | "Report Saved!" confirmation dialog |
| My Plant | `my_plant_screen.dart` | Plant list with expandable cards |
| Add Plant Form | `my_plant_screen.dart` | Add new plant with gallery/camera |
| Notifications | `other_screens.dart` | Recent Activity + Unread tabs |
| Settings | `other_screens.dart` | Dark mode, language, about, version |
| About Us | `other_screens.dart` | App description and mission |
| Privacy Policy | `other_screens.dart` | Full privacy policy text |
| Drawer Menu | `drawer_menu.dart` | Side navigation with all routes |

---

## 🚀 Getting Started

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

## 📂 Project Structure

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

## 🎨 Design System

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

## 📦 Dependencies

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

---

## 🔌 AI Integration (Next Steps)

To integrate a real AI model for disease detection, replace the mock logic in `scanner_screen.dart` and `scan_progress_screen.dart`:

### Option A — TensorFlow Lite (On-Device)
```dart
// Add to pubspec.yaml:
// tflite_flutter: ^0.10.4

import 'package:tflite_flutter/tflite_flutter.dart';

final interpreter = await Interpreter.fromAsset('assets/maize_model.tflite');
// Run inference on captured image
```

### Option B — REST API (Cloud)
```dart
final response = await http.post(
  Uri.parse('https://your-api.com/detect'),
  body: {'image': base64Image},
);
final result = jsonDecode(response.body);
```

### Option C — Google ML Kit
```yaml
google_mlkit_image_labeling: ^0.11.0
```

---

## 🌍 Localization (Swahili / English)

To add Swahili support (great for Tanzania!):
```yaml
# pubspec.yaml
flutter_localizations:
  sdk: flutter
intl: ^0.19.0
```

Then create `lib/l10n/app_sw.arb` and `app_en.arb`.

---

## 📸 Adding Real Images

Place your images in `assets/` folder and update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

---

## 🛠 Troubleshooting

| Issue | Solution |
|---|---|
| `flutter pub get` fails | Check Flutter SDK version `>=3.0.0` |
| Camera not working on emulator | Use a physical device |
| Google Fonts not loading | Check internet connection on first run |
| Build fails on Android | Run `cd android && ./gradlew clean` |

---

## 📄 License
MIT License – Free to use and modify for your project.

---

*Built with ❤️ for African farmers using Flutter & Dart*
