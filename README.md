# Eldertree - Family Tree App

A beautiful Flutter-based family tree application with interactive visualization, audio recordings, and Supabase backend.

## 🌐 Live Demo
The application is automatically deployed to GitHub Pages:

**Live URL:** https://mrsmokemaker.github.io/Eldertree/

## 🚀 Features
- Interactive family tree visualization
- Audio recording and playback for family stories
- Supabase backend for data persistence
- Riverpod state management
- Freezed for immutable data models
- Responsive web design

## 🛠️ Development

### Prerequisites
- Flutter SDK (3.19.5 or higher)
- Dart SDK
- Git

### Local Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/MrSmokeMaker/Eldertree.git
   cd Eldertree
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run -d chrome
   ```

### Web Build
To build for web deployment:
```bash
flutter build web --release --base-href /Eldertree/
```

## 📦 Project Structure
```
lib/
├── core/           # Core configurations, routers, utilities
├── data/           # Models and repositories
├── features/       # Feature-based modules
│   ├── auth/       # Authentication
│   ├── tree_canvas/# Interactive tree visualization
│   ├── profile/    # User profiles
│   ├── interview/  # Interview features
│   └── premium/    # Premium features
└── main.dart       # Application entry point
```

## 🔧 GitHub Pages Deployment
The app is automatically deployed to GitHub Pages via GitHub Actions on every push to the `main` branch.

Workflow: `.github/workflows/deploy.yml`

## 📄 License
This project is open source and available under the MIT License.

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.