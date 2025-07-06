# Digital Certificate Repository Mobile App

A secure, scalable mobile application built with Flutter that serves as a Digital Certificate Repository. This application enables Certificate Authorities (CAs) to generate, manage, and share digital certificates on behalf of their clients such as companies, universities, or event organizers.

## 🚀 Features

### Authentication & Role Management
- Google OAuth login with UPM email (@upm.edu.my) verification
- Role-based access control (RBAC)
- Support for Certificate Authorities (CAs) and Recipients

### Certificate Management
- Create and manage digital certificates
- Attach PDFs or generate certificates dynamically
- Digital signing with visual watermarks
- Certificate approval workflow

### Document Repository
- Secure cloud storage for certificates
- Unique, secure shareable links
- Token-based document access for viewers
- Personal repository view for logged-in users

### True Copy Verification
- Upload physical documents for verification
- Metadata extraction and validation
- CA verification interface
- Admin monitoring dashboard

## 🛠️ Technology Stack

- **Frontend**: Flutter/Dart
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **Payment**: Stripe integration for donations
- **Testing**: Unit tests and widget tests
- **CI/CD**: GitHub Actions

## 📱 User Roles

### System Administrator
- Register/Login with Google UPM ID
- Register Certificate Authorities
- Manage User Roles
- Monitor Activity Logs
- Configure Metadata Rules

### Certificate Authority (CA)
- Register/Login with Google ID
- Manage Client Profiles
- Generate and Issue Certificates
- Certify True Copies
- Share Certificate Links

### Client
- Request Certificate Issuance
- Review and Approve Certificates

### Recipient
- Register/Login
- View Received Certificates
- Upload Physical Certificates for Verification
- Share Certificates
- Manage Document Repository

### Viewer
- Access Shared Links
- Authenticate Access
- Verify Certificate Authenticity

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Philosamphy/MobileApp.git
   cd MobileApp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in `lib/firebase_options.dart`

4. **Run the application**
   ```bash
   flutter run
   ```

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

## 📁 Project Structure

```
lib/
├── models/          # Data models
├── services/        # Business logic and API services
├── screens/         # UI screens
├── widgets/         # Reusable UI components
├── utils/           # Utility functions and constants
└── main.dart        # Application entry point
```

## 🔧 Configuration

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication (Google Sign-In)
3. Set up Firestore database
4. Configure Storage rules
5. Add your app to Firebase project

### Stripe Payment (Optional)
To enable Stripe payment gateway for donations:
1. Set up Stripe account
2. Configure payment keys in environment variables
3. Run the Stripe server: `node stripe_server/server.js`

## 📊 GitHub Contribution Rubric

- **Commit Quality**: 5%
- **Code Contribution**: 20%
- **Pull Request Management**: 5%
- **Unit Testing & Code Coverage**: 5%
- **CI/CD Integration**: 5%
- **Issue Tracking & Resolution**: 10%
- **Team Communication**: 10%
- **Functionality and Quality**: 30%
- **Screencast and Demo Video**: 10%
- **Bonus**: Stripe Payment Integration - 10%

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is part of SSE3401 Mobile Application Development course at UPM.

## 👥 Team Members

- @Philosamphy
- @subohao952
- @owen666-sudo
- @liuez
- @samorynn

## 📞 Support

For support and questions, please contact the development team or refer to the course instructor.

---

**Note**: This application is designed for educational purposes as part of the SSE3401 Mobile Application Development course at Universiti Putra Malaysia (UPM).
