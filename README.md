# 🗞️ Flutter News App with Live & Static News, TTS, STT & Translation

A Flutter-based News App that fetches live news using the NewsAPI and also supports reading from static JSON data. It features:
* 🔴 Live News via NewsAPI
* 📁 Static News from local JSON
* 🔈 Text-to-Speech
* 🎙️ Voice Command to control reading ("start"/"stop")
* 🌐 Multi-language Translation (English, Hindi, Marathi)

---

## 🚀 Features

* ✅ Live News from NewsAPI
* ✅ Static News support (offline view via JSON)
* ✅ TTS (Text-to-Speech) with pitch control
* ✅ STT (Speech-to-Text) for voice-based play/stop
* ✅ UI Text & Article Translation (English, Hindi, Marathi)
* ✅ Translates using Google Translate API, MyMemory & LibreTranslate as fallback
* ✅ Language dropdown in the app bar

---

## 📁 Project Structure

```
lib/
├── main.dart              # Entry point with NewsScreen
├── HomePage.dart          # Home UI to choose Live or Static
├── NewsCard.dart          # UI component for each news article with TTS & STT
assets/
└── news.json              # Static news data (used in offline mode)
```

---

## 🛠️ How to Run

### 1. 📦 Clone and Setup Project

```bash
git clone <your-repo-url>
cd flutter_news_app
flutter pub get
```

### 2. 🔑 Add API Key

Replace this in `NewsScreen`:

```dart
final String apiKey = 'YOUR_NEWSAPI_KEY';
```

with your key from [https://newsapi.org/](https://newsapi.org/)

### 3. 🧪 Run the App

```bash
flutter run
```

---

## 🌐 Multi-language Support

UI and news content can be translated into:
* 🇬🇧 English
* 🇮🇳 Hindi
* 🇮🇳 Marathi

### 🔤 Translation Flow:

* Articles are translated dynamically using:
  1. Google Translate API (Unofficial free endpoint)
  2. MyMemory Translation API
  3. LibreTranslate (Backup)

---

## 🗣️ Voice Features

* 📢 **Text-to-Speech**: Converts description to audio with pitch control.
* 🎤 **Speech Recognition**: Say "start" to read article, "stop" to stop it.

---

## 📚 Dependencies Used

| Package              | Description                      |
| -------------------- | -------------------------------- |
| `http`               | API calls                        |
| `flutter_tts`        | Text-to-Speech                   |
| `speech_to_text`     | Speech Recognition               |
| `permission_handler` | Requesting microphone permission |

---

## 📦 JSON File (Static News)

Place your static news in `assets/news.json`.

Make sure to add this in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/news.json
```

---

## 🧠 Future Improvements

* Bookmarking articles
* Dark Mode
* Caching for offline live news
* Notification for breaking news

---

## 👨‍💻 Author

Created with ❤️ by Vainyala Samal

---

Would you like me to generate the `assets/news.json` format and screenshot folder structure too?
