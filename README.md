# Digital Certificate Repository Mobile App

A mobile application built with Flutter that serves as a Digital Certificate Repository. This application enables Certificate Authorities (CAs) to generate, manage, and share digital certificates on behalf of their clients such as companies, universities, or event organizers.

##  Features

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

##  Technology Stack

- **Frontend**: Flutter/Dart
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **Payment**: Stripe integration for donations
- **Testing**: Unit tests and widget tests
- **CI/CD**: GitHub Actions

##  User Roles

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

