#[Server Repo](https://github.com/sree-vignesh/smart_trip_planner_server)

---

# Smart Trip Planner

````markdown
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

Smart Trip Planner is a Flutter app that generates AI-driven travel itineraries based on natural language input. Users can describe their trip (location, duration, preferences), and the AI produces a day-by-day plan with activities, times, and locations.

---

## Features

- AI-generated day-by-day itineraries
- Supports multiple AI providers (OpenAI, Gemini, Ollama)
- Validation of AI output to ensure consistency
- Firebase Authentication and cloud storage
- Interactive UI with Flutter
- Search locations and activities
- Fallback dummy itinerary for offline testing

---

## Demo Video

[Watch Demo](https://drive.google.com/drive/folders/1dM6UQb80O1JyI72iQn8jzYpt9CbZ8Hpc)

---

## Setup Instructions

### Prerequisites

- Flutter 3.x or above
- Dart 3.x
- Homebrew (macOS) or equivalent
- Firebase project

### Installation

1. **Clone the repository**

```bash
git clone https://https://github.com/sree-vignesh/smart_trip_planner_flutter.git
cd smart-trip-planner
```
````

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Firebase**

```bash
flutterfire configure
```

4. **Run the app**

```bash
flutter run
```

---

## Architecture Overview

The app is modular, separating **UI**, **services**, **models**, **widgets**, and **core utilities**.

## How the AI Agent Chain Works

1. **Prompt Creation**
   User input is structured into a prompt object via `TripInputHandler`.

2. **AI Tool Integration**
   The prompt is sent to the AI backend (`ItineraryAPIService`) for itinerary generation.

3. **Validation**
   JSON output is validated using `JSONService` to ensure schema compliance and logical consistency.

4. **UI Rendering**
   Valid itineraries are parsed into models and displayed via `ItineraryScreen` and `ItineraryCard`.

5. **Fallbacks**
   `DummyItineraryService` provides sample itineraries if the AI backend fails.

---

## Source Code Documentation

### Overview

The app separates concerns into **models**, **services**, **screens**, **widgets**, and **core utilities**, making it modular and easy to maintain.

### Project Structure

```
.
├── core
│   ├── app_snackbar.dart
│   └── colors.dart
├── firebase_options.dart
├── main.dart
├── models
│   ├── itinerary.dart
│   └── itinerary.g.dart
├── screens
│   ├── chat_screen.dart
│   ├── home_page.dart
│   ├── itinerary_screen.dart
│   ├── sign_in_screen.dart
│   ├── sign_up_page.dart
│   └── user_screen.dart
├── services
│   ├── auth_service.dart
│   ├── dummy_itinerary_service.dart
│   ├── itinerary_api_service.dart
│   ├── json_service.dart
│   └── search_service.dart
└── widgets
    └── itinerary_card.dart
```

### Core Modules

- **core/** – Utilities (`app_snackbar.dart`, `colors.dart`)
- **models/** – Data structures (`Itinerary`, `Day`, `Activity`) with JSON serialization
- **services/** – Backend, AI, authentication, validation, and search logic
- **screens/** – Flutter UI screens for chat, home, itinerary, sign-in/up, and user profile
- **widgets/** – Custom UI components (`ItineraryCard`)

### Key Points

- **Modularity:** Clear separation of concerns between UI, services, and models.
- **Scalability:** Easy to integrate new AI providers, tools, or features.
- **Validation:** Ensures only valid and logical itineraries reach the UI.
- **Reusability:** Widgets and services can be reused across screens or other projects.
