# 🎉 Hangout Planner App

A cross-platform mobile app (Flutter) with a **Node.js + Express** backend to help friends plan, vote on, and finalize group hangouts seamlessly.

---

## 📌 Table of Contents

- [About The Project](#about-the-project)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Flutter App Setup](#flutter-app-setup)
- [Usage](#usage)
- [API Endpoints](#api-endpoints)
- [Testing](#testing)
- [Flavors](#flavors)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## About The Project

This app simplifies planning hangouts:

1. Create an event with proposed date/time and location options.
2. Invite friends via email or shareable link.
3. Collect votes on options via Flutter app.
4. Automatically select the most popular option.
5. Send push notifications and allow calendar exports.

---

## Features

- 📅 Multi-option events (dates, times, venues)
- 📩 Invite via email/link
- 🗳 Voting system
- 🏆 Auto-finalization of options
- 🔔 Push notifications
- 📥 Calendar export (iCal / Google)
- 🎯 Android & iOS support via Flutter

---

## Tech Stack

- **Backend**: Node.js + Express
- **Database**: MongoDB (Mongoose ORM)
- **Auth**: JWT
- **Email**: Nodemailer
- **Mobile**: Flutter (Dart)
- **Deployment Suggestions**: Heroku, AWS, Firebase

---

## Getting Started

### Prerequisites

- Node.js ≥14 & npm
- MongoDB (local or cloud)
- Flutter SDK ≥3.0

### Backend Setup

```bash
cd backend
cp .env.example .env
# Fill in DB_URI, JWT_SECRET, EMAIL_ credentials
npm install
npm run dev         # Starts Node.js server
npm test            # Run backend tests
Flutter App Setup
bash
Copy
Edit
cd mobile
flutter pub get
flutter run -d <device>  # Run on Android or iOS
flutter test             # Run Flutter tests
Usage
Register or log in on the app.

Create a hangout with options.

Invite participants.

Users vote via Flutter interface.

Backend tallies votes and picks winner.

Notifications sent; attendees can export to calendar.

API Endpoints
Auth

POST /api/auth/signup

POST /api/auth/login

Events

GET /api/events

POST /api/events

GET /api/events/:id

PATCH /api/events/:id

DELETE /api/events/:id

Invites & Voting

POST /api/events/:id/invite

GET /api/events/:id/invites

POST /api/events/:id/vote

GET /api/events/:id/votes

Finalize

POST /api/events/:id/finalize

Testing
Backend: cd backend && npm test

Frontend: cd mobile && flutter test

Flavors (Optional)
Configure environments:

bash
Copy
Edit
flutter run --flavor development -d <device>
flutter run --flavor production -d <device>
Align with separate .env or config files.

Contributing
We welcome contributions!

Fork the repo

Create a feature branch: git checkout -b feature/my-feature

Commit changes: git commit -m "Add new feature"

Push: git push origin feature/my-feature

Open a PR

License
Distributed under the MIT License. See LICENSE for details.

Contact
Developed by Ansh Bhamiya – feel free to reach out via GitHub or open an issue.
