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
