# Pinterest Flutter 📌

A native, high-performance, responsive cross-platform Pinterest application built with Flutter & Dart. Features the signature Pinterest masonry waterfall feed, live discovery & search, boards collection management with 3-image collage previews, photo upload studio, interactive comments, and seamless light/dark mode theming.

---

## 🌟 Key Features

### 1. 🖼️ Home Waterfall Feed
* **Masonry Grid**: Fluid waterfall layout powered by `flutter_staggered_grid_view` with zero Cumulative Layout Shift (CLS) through aspect-ratio reservation and dominant-color skeleton placeholders.
* **Category Pill Bar**: Horizontal capsule filter bar (Architecture, Interior, Tech, Coffee, Photography, Travel, Art) with instant reactive filtering.
* **Optimistic Interactions**: Instant quick-save pill and heart animations with persistent local storage.
* **Pull-to-Refresh**: Refresh feed state and sync cached pins on demand.

### 2. 🔍 Visual Discovery & Live Search
* **Dual Pipeline Search**:
  1. Instant client-side filtering matching keywords and tags across local pins.
  2. Live external image search via the Openverse API with Wikipedia API fallback for instant exploration.
* **Search History**: Persistent chip-based recent search history with one-tap removal.
* **"Ideas for You"**: Pinterest-style visual category discovery cards.

### 3. 📌 Pin Details & Social Engagement
* **Hero Transitions**: Smooth image morphing from feed card to full-screen view.
* **Pinch-to-Zoom**: Fluid zoom and pan with bounds checking using `InteractiveViewer`.
* **Save to Board Sheet**: Modal bottom-sheet to save pins into any existing board or create a new board inline with privacy controls.
* **Interactive Comments**: Real-time comment submission and display with local persistence.
* **"More Like This"**: Contextual recommendations based on matching category and tags.

### 4. 🗂️ Boards & Collections Management
* **3-Image Collage Previews**: Signature Pinterest board cards with a 2/3 main cover image and 1/3 dual stacked thumbnails.
* **Board Details View**: Filtered masonry grid displaying all pins assigned to the board.
* **Secret Boards**: Support for private boards with lock icons and privacy flags.
* **Board Management**: Modal editing dialog to change name, description, privacy, or delete boards with cascading pin reassignment.

### 5. ➕ Create Pin Studio
* **Media Input**:
  - Device Photo Library via `image_picker`
  - Device Camera capture
  - Direct Image URL input
  - Curated aesthetic sample photos
* **Aspect Ratio Detection**: Automatically decodes image dimensions to calculate aspect ratios and prevent layout shift.
* **Form & Metadata**: Title, description, destination link, board selection, category dropdown, and comma-separated tags.
* **AppImage Component**: Universal image renderer automatically handling both remote HTTP/HTTPS network URLs and local device files.

### 6. 👤 Profile Hub
* **User Overview**: Avatar, handle, follower/following statistics, and profile management.
* **Segmented Tabs**:
  - **Created**: Pins authored by the user with quick-start zero-state triggers.
  - **Saved**: Pins saved to user collections.
  - **Boards**: Embedded board collection grid with "+ Create Board" modal action.

---

## 🏗️ Architecture & Project Structure

The project follows a modular, feature-first clean architecture (matching the reference project structure):

```
lib/
├── app.dart                             # MaterialApp.router with light & dark themes
├── main.dart                            # App initialization and Riverpod ProviderScope
├── core/
│   └── services/
│       ├── api_service.dart             # Openverse & Wikipedia image search APIs
│       └── storage_service.dart         # SharedPreferences local persistence
├── data/
│   ├── board_repository.dart           # Board data caching & persistence
│   ├── pin_repository.dart             # Pin data caching & persistence
│   └── seed_data.dart                  # Initial seed pins, boards, and categories
├── model/
│   ├── author_model.dart               # Author/creator data model
│   ├── board_model.dart                # Board collection model
│   ├── comment_model.dart              # User comment model
│   └── pin_model.dart                  # Core Pin model with JSON serialization
├── ui/
│   ├── tokens/
│   │   ├── colors.dart                 # Pinterest #E60023, light & dark palette
│   │   ├── spacing.dart                # Spacing scales, radii (pill, md, lg)
│   │   └── typography.dart             # Headings, body, button, caption text styles
│   ├── widgets/
│   │   └── app_image.dart              # Universal network & local file image widget
│   └── ui.dart                         # Light & Dark ThemeData definitions
├── view_model/
│   ├── boards_view_model.dart          # Board collections StateNotifier
│   ├── feed_view_model.dart            # Feed, category filter, likes/saves StateNotifier
│   └── search_view_model.dart          # Search queries, history & live streaming
└── views/
    ├── boards/
    │   ├── board_detail_view.dart      # Single board view with masonry grid
    │   ├── boards_view.dart            # All boards overview
    │   └── widgets/
    │       ├── board_card.dart         # 3-image collage card
    │       └── edit_board_dialog.dart  # Board edit/delete modal
    ├── create_pin/
    │   └── create_pin_view.dart        # Pin publishing studio
    ├── home/
    │   ├── home_view.dart              # Main waterfall feed
    │   └── widgets/
    │       ├── category_bar.dart       # Horizontal capsule pill filter
    │       └── pin_card.dart           # Masonry pin card with optimistic save/like
    ├── navigation/
    │   ├── app_router.dart             # GoRouter configuration & routes
    │   └── scaffold_with_nav_bar.dart  # Persistent bottom navigation shell
    ├── pin_detail/
    │   ├── pin_detail_view.dart        # Full pin view with zoom & recommendations
    │   └── widgets/
    │       ├── comments_section.dart   # Interactive comments sheet
    │       └── save_to_board_sheet.dart# Save to board modal sheet
    ├── profile/
    │   └── profile_view.dart           # User profile with Created/Saved/Boards tabs
    └── search/
        └── search_view.dart            # Dual search & visual discovery
```

---

## 🎨 Design System

| Element | Value | Description |
| :--- | :--- | :--- |
| **Primary Brand** | `#E60023` | Signature Pinterest red |
| **Primary Hover** | `#AD081B` | Deep red for pressed/hover states |
| **Light Background**| `#FFFFFF` | Clean white canvas |
| **Dark Background** | `#111111` | OLED-friendly deep dark canvas |
| **Light Surface** | `#F0F0F0` | Subtle pill and card backgrounds |
| **Dark Surface** | `#222222` | Dark container and card backgrounds |
| **Border Radii** | `8px`, `16px`, `24px`, `9999px` | Rounded corners and signature capsule pills |

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.24.0` / stable)
* [Dart SDK](https://dart.dev/) (`>= 3.5.0`)
* FVM (optional, project configured with `.fvmrc`)

### Installation

1. **Clone or navigate to the project directory**:
   ```bash
   cd /Users/shamini/Projects/pinterest_flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   # Or using FVM:
   fvm flutter pub get
   ```

3. **Verify code health**:
   ```bash
   flutter analyze lib/
   ```

---

## 📱 Running the Application

### Chrome (Web)
```bash
flutter run -d chrome
```

### macOS Desktop
```bash
flutter run -d macos
```

### iOS Simulator
```bash
# Open iOS Simulator
open -a Simulator
flutter run -d ios
```

### Android Emulator / Device
```bash
flutter run -d android
```

---

## 🧪 Testing & Validation

Run the static analyzer across the codebase to ensure zero warnings:
```bash
flutter analyze lib/
```

---

## 📄 License
This project is built for educational and portfolio demonstration purposes. All rights and trademarks for Pinterest belong to Pinterest, Inc.
