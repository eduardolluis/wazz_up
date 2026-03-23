
A **WhatsApp clone** built with Flutter, replicating the core features of the world's most popular messaging app.

## ✨ Features

- 💬 **Real-time messaging** via WebSockets (Socket.IO)
- 📞 **Voice & video calls** with Agora RTC Engine and LiveKit
- 📷 **Image & video sharing** from camera or gallery
- 🎙️ **Voice messages** recorded directly in the app
- 📍 **Live location sharing** with Geolocator
- 📁 **File sharing** with built-in file picker
- 👥 **Device contacts integration**
- 🔐 **Authentication** with Firebase Auth (phone OTP)
- 🗄️ **Cloud database** with Cloud Firestore
- 🖼️ **File storage** with Firebase Storage
- 🗺️ **Integrated maps** with Google Maps
- 😊 **Emoji picker** inside the chat
- 🌐 **Cross-platform**: Android, iOS, Web, Windows, macOS and Linux

---

## 🛠️ Tech Stack

| Category | Technologies |
|---|---|
| Framework | Flutter (Dart SDK ^3.5.0) |
| Real-time backend | Socket.IO Client, LiveKit |
| Video calls | Agora RTC Engine |
| Authentication | Firebase Auth, OTP Text Field |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| Maps | Google Maps |
| Media | Camera, Video Player, Image Picker, Record |
| Utilities | Geolocator, URL Launcher, Flutter Contacts, File Picker |
| Fonts | OpenSans (Bold, Regular, Italic) |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (compatible with Dart ^3.5.0)
- [Firebase CLI](https://firebase.google.com/docs/cli) configured
- Firebase project with Firestore, Auth and Storage enabled
- Google Maps API key (for maps functionality)
- Agora credentials (for voice/video calls)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/eduardolluis/whatzapp.git
cd whatzapp

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# Add your google-services.json to android/app/
# Add your GoogleService-Info.plist to ios/Runner/

# 4. Run the app
flutter run
```

### Chat Server

The project includes a chat server inside the `chat_server/` folder. Make sure it's running before launching the app:

```bash
cd chat_server
# Install dependencies and start the server following the internal instructions
```

---

## 📁 Project Structure

```
whatzapp/
├── android/          # Android configuration
├── ios/              # iOS configuration
├── linux/            # Linux configuration
├── macos/            # macOS configuration
├── web/              # Web configuration
├── windows/          # Windows configuration
├── assets/           # Images and static resources
├── fonts/            # Custom fonts (OpenSans)
├── chat_server/      # WebSocket server
├── lib/              # Main Flutter source code
├── test/             # Unit tests
├── pubspec.yaml      # Project dependencies
└── firebase.json     # Firebase configuration
```

---

## 📸 Screenshots
🔐 Login Screen
<p align="left"><br/> <img src="https://github.com/user-attachments/assets/726b8693-e8ef-474b-91cb-dd792df8a3e4" width="250"/> <img src="https://github.com/user-attachments/assets/17923567-02c4-41b9-9b32-e1c222b62dc4" width="250"/> </p>
🔑 OTP Screen
<p align="left"> <br/><img src="https://github.com/user-attachments/assets/76c868f7-ebe3-4d92-9676-f33775d7491e" width="250"/> </p>
🏠 Home Screen
<p align="left"> <br/><img src="https://github.com/user-attachments/assets/d5a04449-1ad6-4c9d-9342-f8e84b51a2b4" width="220"/> <img src="https://github.com/user-attachments/assets/6a30abf9-7ef2-4681-b301-e9b0e70bf073" width="220"/> <img src="https://github.com/user-attachments/assets/7af593b5-1233-47e5-ba6d-b03845eec5ab" width="220"/> </p> <p align="center"> <img src="https://github.com/user-attachments/assets/04e6a75b-d426-4466-a316-9877d44fad71" width="220"/> <img src="https://github.com/user-attachments/assets/6d395b63-8e64-4f1e-9352-79ad8bba6baf" width="220"/> </p>
👤 Contact Pages
<p align="left"> <br/><img src="https://github.com/user-attachments/assets/8efe9bad-f871-4217-9360-178f69b0547e" width="220"/> <img src="https://github.com/user-attachments/assets/e48d1b05-a004-4bc2-b130-120305f7f696" width="220"/> <img src="https://github.com/user-attachments/assets/555a69f7-7e04-4873-bdaa-f7aae91ecb15" width="220"/> </p>
📊 Status Page
<p align="left"><br/> <img src="https://github.com/user-attachments/assets/627a2ccb-fd89-4f13-ac08-912bb5a7e877" width="220"/> <img src="https://github.com/user-attachments/assets/cb51c10f-085a-424a-86f5-ef315aa336ac" width="220"/> <img src="https://github.com/user-attachments/assets/e673efaf-8f44-4a9d-b613-57554736a20e" width="220"/> </p>
📞 Call History
<p align="left"> <br/><img src="https://github.com/user-attachments/assets/cc403538-8d25-4b7c-9074-8e4bdb3d1504" width="220"/> <img src="https://github.com/user-attachments/assets/e07dd9a3-a725-4283-863a-c552ae99437c" width="220"/> <img src="https://github.com/user-attachments/assets/213669c7-7ab9-4884-b2f8-88f78ec855fd" width="220"/> </p>
💬 Chat Page
<p align="left"><br/> <img src="https://github.com/user-attachments/assets/ba5b8c4d-815e-4840-a821-45dd5f723d14" width="220"/> <img src="https://github.com/user-attachments/assets/dd07d2bc-e3a5-4722-bd6d-0baf45f5dcd2" width="220"/> <img src="https://github.com/user-attachments/assets/31452a9d-7714-472e-9bbe-6eed01443fb9" width="220"/> </p> <p align="center"> <img src="https://github.com/user-attachments/assets/9858f48d-2262-42b0-895f-c2469e78b0d7" width="220"/> <img src="https://github.com/user-attachments/assets/4b9ace80-bf7b-46c3-869e-468f33d861c0" width="220"/> </p>
⚙️ Settings
<p align="left"><br/> <img src="https://github.com/user-attachments/assets/90fd48eb-9dd2-4a5f-bb57-c37f4a2a8519" width="220"/> <img src="https://github.com/user-attachments/assets/f328a089-6a31-46f0-84db-f74f80c189d1" width="220"/> </p>
---


## 🤝 Contributing

Contributions are welcome! If you'd like to improve the project:

1. Fork the repository
2. Create a branch: `git checkout -b feature/new-feature`
3. Commit your changes: `git commit -m 'feat: add new feature'`
4. Push to the branch: `git push origin feature/new-feature`
5. Open a Pull Request

---

## 📄 License

This project is for educational and personal use only. It is not affiliated with WhatsApp or Meta.

---

## 👨‍💻 Author

**Eduardo De La Cruz** — [@eduardolluis](https://github.com/eduardolluis)
