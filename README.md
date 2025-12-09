# AURA ONE

A Unified AI Operating System for Hospitals.

## Project Structure

- `backend/`: NestJS application (API, AI Gateway, Digital Twin)
- `mobile/`: Flutter application (Android/iOS)
- `docker-compose.yml`: Database infrastructure (PostgreSQL, Redis, TimescaleDB)

## Prerequisites

- Node.js (v18+) & NPM
- Flutter SDK (v3.16+)
- Docker & Docker Compose

## Setup Instructions

### 1. Fix Permissions (Important)

If you encounter `EACCES` errors with npm, run:

```bash
sudo chown -R $(whoami) ~/.npm
```

### 2. Backend Setup

```bash
cd backend
npm install
# If you have conflicts:
npm install --legacy-peer-deps
```

### 3. Database Setup

```bash
# In the root directory (AURA_ONE)
docker-compose up -d
```

### 4. Running the Backend

```bash
cd backend
npm run start:dev
```

### 5. Mobile App Setup

```bash
cd mobile
flutter pub get
flutter run
```
