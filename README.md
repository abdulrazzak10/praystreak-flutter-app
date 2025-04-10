# PrayStreak

A Flutter app to help Muslims track their daily prayers, maintain streaks, and build consistency in their prayer habits.

## Features

- **Prayer Tracking**: Log your five daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha)
- **Streak Tracking**: Build and maintain a streak of consistent prayers
- **Statistics**: View detailed statistics about your prayer performance
- **Minimalist UI**: Clean, distraction-free interface focused on the essential
- **User Authentication**: Secure login and signup functionality
- **Profile Management**: Update profile information and change password

## Screenshots

[Screenshots will be added soon]

## Firebase Setup

This project uses Firebase for authentication and database. Follow these steps to complete the setup:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app with package name `com.example.praystreak` (or your custom package name)
3. Download the `google-services.json` file and place it in the `android/app/` directory
4. Add an iOS app (if needed) and follow the instructions to download and place the `GoogleService-Info.plist` file
5. Enable the Authentication and Firestore services in your Firebase project
6. Run `flutter pub get` to install all dependencies

## Getting Started

1. Clone the repository
2. Set up the Firebase project as described above
3. Run the app with `flutter run`

## Project Structure

- `lib/screens/` - Contains all the screen UI files
- `lib/models/` - Data models for the application
- `lib/services/` - Service classes for authentication and prayer tracking
- `lib/widgets/` - Reusable UI components
- `lib/constants/` - App constants, theme settings, etc.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by habit tracking apps and the importance of regular prayer in Islam
- Special thanks to the Flutter and Firebase communities for their excellent documentation

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
