# ZenFlow - Pomodoro Timer App

A beautiful and functional Pomodoro timer app built with Flutter, featuring Clean Architecture, MVVM pattern, and Hive database for local storage.

## Features

- ⏱️ **Pomodoro Timer** - Focus sessions (25 min), Short breaks (5 min), and Long breaks (15 min)
- 📝 **Task Management** - Create, complete, and track tasks with pomodoro counts
- 🔄 **Cycle Tracking** - Automatic cycle progression with visual progress indicators
- 💾 **Persistent Storage** - All data saved locally using Hive database
- 🎨 **Beautiful Dark Theme** - Modern UI inspired by the Flow Zone design
- 📊 **Statistics** - Track completed cycles and total focus time

## Architecture

This project follows **Clean Architecture** principles with three distinct layers:

### 1. Domain Layer (`lib/domain/`)
- **Entities**: Core business models (Task, TimerSession, AppSettings)
- **Repositories**: Abstract interfaces for data operations
- Pure Dart with no dependencies on Flutter or external packages

### 2. Data Layer (`lib/data/`)
- **Models**: Hive-annotated models with adapters
- **Repository Implementations**: Concrete implementations using Hive
- Handles all database operations and data persistence

### 3. Presentation Layer (`lib/presentation/`)
- **ViewModels**: Business logic using ChangeNotifier (MVVM pattern)
- **Screens**: Main app screens
- **Widgets**: Reusable UI components
- Uses Provider for state management

### Core (`lib/core/`)
- **Constants**: App-wide constants
- **Theme**: App colors and theme configuration

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
├── data/
│   ├── models/
│   │   ├── task_model.dart
│   │   ├── timer_session_model.dart
│   │   └── settings_model.dart
│   └── repositories/
│       ├── task_repository_impl.dart
│       ├── session_repository_impl.dart
│       └── settings_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── task.dart
│   │   ├── timer_session.dart
│   │   └── app_settings.dart
│   └── repositories/
│       ├── task_repository.dart
│       ├── session_repository.dart
│       └── settings_repository.dart
├── presentation/
│   ├── screens/
│   │   └── home_screen.dart
│   ├── viewmodels/
│   │   ├── timer_viewmodel.dart
│   │   ├── task_viewmodel.dart
│   │   └── settings_viewmodel.dart
│   └── widgets/
│       ├── timer_display.dart
│       ├── timer_controls.dart
│       ├── timer_type_selector.dart
│       ├── cycle_progress.dart
│       └── task_list_widget.dart
└── main.dart
```

## Technologies Used

- **Flutter** - UI framework
- **Hive** - Lightweight and fast NoSQL database
- **Provider** - State management
- **Equatable** - Value equality for entities
- **Google Fonts** - Custom typography (Poppins)

## Getting Started

### Prerequisites

- Flutter SDK (>=3.5.3)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd zenflow
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

## How to Use

1. **Select Timer Type**: Choose between Focus, Short Break, or Long Break
2. **Start Timer**: Press the START button to begin your session
3. **Add Tasks**: Enter tasks you're working on in the Tasks section
4. **Track Progress**: Monitor your cycle progress and completed pomodoros
5. **Complete Cycles**: After 4 focus sessions, you'll automatically get a long break

## Design Inspiration

This app is inspired by the Flow Zone Pomodoro Timer design available at [https://fzt.vercel.app/](https://fzt.vercel.app/)

## Features Details

### Timer Modes
- **Focus**: 25-minute work sessions
- **Short Break**: 5-minute breaks between focus sessions
- **Long Break**: 15-minute break after 4 completed cycles

### Task Management
- Create unlimited tasks
- Track pomodoros completed per task
- Mark tasks as complete
- Delete tasks when done

### Automatic Cycling
- App automatically transitions between Focus and Break modes
- Long break triggered after 4 focus sessions
- Visual cycle progress indicators

## Future Enhancements

- [ ] Settings screen for customizable timer durations
- [ ] Sound notifications when timer completes
- [ ] Push notifications
- [ ] Statistics dashboard
- [ ] Data export functionality
- [ ] Multiple themes

## License

This project is open source and available under the MIT License.

## Contributing

Contributions, issues, and feature requests are welcome!

## Author

Built with ❤️ using Flutter and Clean Architecture principles.
