\section*{Projects}

\textbf{Hangout Planner App} 📱 \\
A comprehensive Flutter mobile app (Node.js backend) for planning and coordinating hangouts. \\
\href{https://github.com/Ansh-bhamniya/hangout_planner_app}{GitHub} \quad
\href{https://drive.google.com/file/d/1mObhA8odwQSAi7_W3nsrC1sFkFpKESck/view?usp=sharing}{Demo Video}

\vspace{-0.3em}
\begin{itemize}[leftmargin=*,itemsep=0pt]
  \item Event creation with real-time RSVP, live updates, Google Maps integration, and push notifications.
  \item Cross-platform Flutter UI with authentication, offline support, themes; uses Node.js backend, JWT, Socket.io.
\end{itemize}

## Features ✨

### Core Functionality
- **Event Creation**: Create detailed hangout events with customizable options
- **User Management**: User authentication and profile management
- **Real-time Updates**: Live synchronization of event changes
- **RSVP System**: Easy response tracking for event participants
- **Location Integration**: Map integration for venue selection
- **Notification System**: Push notifications for event updates

### User Experience
- **Intuitive UI**: Clean, modern Flutter interface
- **Cross-platform**: Works on both iOS and Android
- **Offline Support**: Core features available without internet
- **Dark/Light Theme**: Customizable app appearance

## Tech Stack 🛠️

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider/Riverpod/Bloc (specify which one you're using)
- **HTTP Client**: Dio/HTTP package
- **Local Storage**: Hive/SharedPreferences
- **Maps**: Google Maps Flutter
- **Notifications**: Firebase Cloud Messaging

### Backend (Node.js)
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB/PostgreSQL (specify your choice)
- **Authentication**: JWT (JSON Web Tokens)
- **Real-time**: Socket.io
- **Cloud Storage**: AWS S3/Firebase Storage

## Getting Started 🚀

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Node.js (16.0 or higher)
- npm or yarn
- Android Studio/VS Code
- Git

### Installation

#### 1. Clone the Repository
```bash
git clone https://github.com/Ansh-bhamniya/hangout_planner_app.git
cd hangout_planner_app
```

#### 2. Backend Setup
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Configure your environment variables in .env
# DB_CONNECTION_STRING=your_database_url
# JWT_SECRET=your_jwt_secret
# PORT=3000

# Start the development server
npm run dev
```

#### 3. Flutter App Setup
```bash
# Navigate to Flutter app directory
cd flutter_app

# Install dependencies
flutter pub get

# Configure API endpoints in lib/config/api_config.dart
# Update BASE_URL to point to your backend

# Run the app
flutter run
```

## Configuration ⚙️

### Environment Variables (Backend)
Create a `.env` file in the backend directory:

```env
# Database
DB_CONNECTION_STRING=mongodb://localhost:27017/hangout_planner
# or for PostgreSQL: postgresql://username:password@localhost:5432/hangout_planner

# Authentication
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRE_TIME=7d

# Server
PORT=3000
NODE_ENV=development

# External APIs
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
FIREBASE_SERVER_KEY=your_firebase_server_key

# File Upload
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10MB
```

### Flutter Configuration
Update `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';
  static const String googleMapsApiKey = 'your_google_maps_api_key';
}
```

## Project Structure 📁

```
hangout_planner_app/
├── backend/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── middleware/
│   ├── config/
│   └── server.js
├── flutter_app/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── services/
│   │   ├── providers/
│   │   └── main.dart
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── docs/
└── README.md
```

## API Endpoints 🔗

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/profile` - Get user profile

### Events
- `GET /api/events` - Get all events
- `POST /api/events` - Create new event
- `GET /api/events/:id` - Get specific event
- `PUT /api/events/:id` - Update event
- `DELETE /api/events/:id` - Delete event

### RSVP
- `POST /api/events/:id/rsvp` - RSVP to event
- `GET /api/events/:id/attendees` - Get event attendees

## Development 💻

### Running Tests
```bash
# Backend tests
cd backend
npm test

# Flutter tests
cd flutter_app
flutter test
```

### Code Style
- **Flutter**: Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **Backend**: Use ESLint with Airbnb configuration

### Git Workflow
1. Create feature branch from `main`
2. Make changes and commit with descriptive messages
3. Push branch and create Pull Request
4. Code review and merge

## Deployment 🚀

### Backend Deployment
```bash
# Build for production
npm run build

# Start production server
npm start
```

### Flutter App Deployment

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines
- Follow the existing code style
- Write tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support 📞

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/Ansh-bhamniya/hangout_planner_app/issues) page
2. Create a new issue if your problem isn't already reported
3. Contact the maintainer: [Ansh Bhamniya](https://github.com/Ansh-bhamniya)

## Acknowledgments 🙏

- Flutter team for the amazing framework
- Node.js community for excellent backend tools
- All contributors who helped improve this project

## Roadmap 🗺️

- [ ] Integration with calendar apps
- [ ] Advanced notification preferences
- [ ] Group chat functionality
- [ ] Event analytics and insights
- [ ] Integration with social media platforms
- [ ] Multi-language support

---

**Made with ❤️ by [Ansh Bhamniya](https://github.com/Ansh-bhamniya)**
