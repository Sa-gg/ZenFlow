# ZenFlow — Pomodoro Timer

A clean, distraction-free Pomodoro timer built with **Flutter** using Clean Architecture and MVVM.

## Features

- **Pomodoro Timer** — Focus (25 min), Short Break (5 min), Long Break (15 min)
- **Task Management** — Create tasks and track pomodoros per task
- **Cycle Tracking** — Visual progress dots with automatic long-break after 4 focus sessions
- **Auto-Switch** — Optionally auto-transition between focus and break modes
- **Customizable Durations** — Adjust all timer lengths and cycle count from settings
- **Audio & Notification Alerts** — System sound + notification on timer completion
- **Offline-First** — All data persisted locally with Hive (no account required)
- **Dark Theme** — Modern dark UI designed to minimise eye strain

## Screenshots

<!-- Add screenshots here -->

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.5.3)
- Android Studio / VS Code with the Flutter extension

### Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/zenflow.git
cd zenflow

# Install dependencies
flutter pub get

# Generate Hive type adapters (only needed after modifying models)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on a connected device or emulator
flutter run
```

### Running Tests

```bash
flutter test
```

## Project Structure

```
lib/
├── core/               # Constants, theme, services (audio, notifications)
├── data/               # Hive models, repository implementations
├── domain/             # Entities, abstract repository interfaces
├── presentation/
│   ├── screens/        # HomeScreen
│   ├── viewmodels/     # TimerViewModel, TaskViewModel, SettingsViewModel
│   └── widgets/        # Reusable UI components
└── main.dart

docs/                   # Documentation scripts and generated files
test/                   # Widget and unit tests
```

## Architecture

| Layer | Responsibility |
|-------|---------------|
| **Domain** | Entities (`Task`, `TimerSession`, `AppSettings`), abstract repositories |
| **Data** | Hive-annotated models + repository implementations |
| **Presentation** | `ChangeNotifier` ViewModels + Flutter widgets (MVVM) |
| **Core** | Theme, constants, audio/notification services |

State management uses **Provider** with `ChangeNotifier` ViewModels.

## Tech Stack

- **Flutter** — UI framework
- **Hive** — Lightweight NoSQL local database
- **Provider** — State management
- **Equatable** — Value equality for entities
- **Google Fonts** — Poppins typography
- **flutter_local_notifications** — Timer alerts

## Configuration

Default timer values (editable in-app):

| Setting | Default |
|---------|---------|
| Focus Duration | 25 minutes |
| Short Break | 5 minutes |
| Long Break | 15 minutes |
| Cycles Before Long Break | 4 |

## Contributing

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).
