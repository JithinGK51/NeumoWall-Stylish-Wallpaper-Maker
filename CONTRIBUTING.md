# Contributing to NeumoWall

Thank you for your interest in contributing to NeumoWall! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/NeumoWall-Stylish-Wallpaper-Maker.git
   cd NeumoWall-Stylish-Wallpaper-Maker
   ```

3. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

1. Ensure you have Flutter installed (3.7.2 or higher)
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Code Style

- Follow Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and single-purpose
- Write unit tests for new features

## Commit Messages

Follow conventional commits:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation
- `style:` for formatting
- `refactor:` for code restructuring
- `test:` for adding tests
- `chore:` for maintenance

Example:
```
feat: Add video wallpaper trimming functionality
```

## Pull Request Process

1. Update README.md if needed
2. Add tests if applicable
3. Ensure all tests pass
4. Submit a pull request with a clear description

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                  # Data models
├── providers/              # Riverpod providers
├── screens/                 # UI screens
├── services/               # Business logic
├── themes/                 # Theme configuration
├── utils/                  # Utilities
└── widgets/                # Reusable widgets
```

## Questions?

Open an issue for questions or discussions.

