# SecureByPay (Myafrimall) Technical Assessment

Full-stack web application built for the SecureByPay Technical Assessment, demonstrating frontend design fidelity, responsive layouts, and functional backend API integration.

![Platform](https://img.shields.io/badge/Platform-Flutter%20Web%20%7C%20Node.js-blue)
![Brand Color](https://img.shields.io/badge/Primary%20Color-%235A65AB-5A65AB)
![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success)

---

## 🚀 Overview

This application faithfully replicates the provided Figma designs for the **Myafrimall** platform:
1. **Design & Responsiveness**:
   - Primary Brand Color: `#5A65AB`
   - Custom Dotted World Map canvas graphic on authentication pages.
   - Fully responsive across Desktop (>1024px), Tablet (768px–1024px), and Mobile (<768px).
   - Collapsible desktop sidebar and mobile navigation drawer.
   - Interactive Company Growth spline curve with Year / Month / Week period filters.
   - Expandable shipment cards with detailed status badges (`In-Transit`, `Delayed`, `Paid`), pick-up/delivery locations, and payment actions.
2. **Backend API Integration**:
   - **Authentication**: Registration and Login flows with password hashing (`bcryptjs`), JWT token generation, and protected routes.
   - **Dashboard Analytics**: Live overview metrics (Wallet balance, total shipments, total exports, total imports, +90% growth trends).
   - **Interactive Operations**: Live shipment payment processing (`POST /api/v1/shipments/:id/pay`) and wallet funding (`POST /api/v1/dashboard/wallet/fund`).

---

## 📁 Repository Structure

The project follows standard production-grade clean architecture:

```
SecureByPay/
├── backend/                         # Node.js / Express Backend (TypeScript)
│   ├── src/
│   │   ├── config/                  # App configuration & environment variables
│   │   ├── controllers/             # Express request controllers (Auth, Dashboard, Shipments)
│   │   ├── middleware/              # JWT authentication & error handling middleware
│   │   ├── models/                  # TypeScript data interfaces & schemas
│   │   ├── routes/                  # Express API route modules
│   │   ├── services/                # Business logic & file-persisted storage layer
│   │   ├── utils/                   # JWT & helper utilities
│   │   ├── app.ts                   # Express application setup & static serving
│   │   └── server.ts                # Server entry point
│   ├── test/                        # Automated API test suite (Node test runner)
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/                        # Flutter Web Frontend
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/           # App colors (#5A65AB, #1E243A) & strings
│   │   │   ├── network/             # ApiService (HTTP client, JWT interceptor, fallback)
│   │   │   ├── theme/               # Material ThemeData with Google Fonts Inter
│   │   │   └── utils/               # Responsive layout builder (Desktop, Tablet, Mobile)
│   │   ├── features/
│   │   │   ├── auth/                # Sign-Up & Sign-In features
│   │   │   │   ├── models/          # UserModel
│   │   │   │   └── presentation/    # SignUpScreen, LoginScreen, AuthBanner
│   │   │   ├── dashboard/           # Main Dashboard Overview
│   │   │   │   ├── models/          # OverviewMetrics, GrowthPoint models
│   │   │   │   └── presentation/    # DashboardScreen, OverviewCards, GrowthChart, PromoBanner, Sidebar
│   │   │   └── shipments/           # Shipment feature
│   │   │       ├── models/          # ShipmentModel
│   │   │       └── presentation/    # ShipmentItemCard (expandable accordion & pay action)
│   │   ├── shared/
│   │   │   └── widgets/             # CustomTextField, CustomButton, DottedWorldMap
│   │   └── main.dart                # Flutter application entry point
│   ├── build/web/                   # Compiled web application distribution
│   ├── web/                         # Web manifest, index.html, preloader
│   └── pubspec.yaml                 # Flutter dependencies
│
├── package.json                     # Monorepo root scripts
├── .gitignore
└── README.md
```

---

## 🛠️ Technology Stack

- **Frontend**: Flutter Web (Dart 3.x), HTML5 Canvas, Google Fonts (Inter).
- **Backend**: Node.js (v22), Express.js, TypeScript, bcryptjs, jsonwebtoken, cors, dotenv.
- **Testing**: Node.js native test runner (`node:test`, `assert`).

---

## ⚡ Getting Started Locally

### Prerequisites
- Node.js (v18+)
- npm (v9+)
- Flutter SDK (optional if serving the bundled web distribution)

### 1. Quick Start (Run Both Frontend & Backend with 1 Command)

```bash
# Clone the repository
git clone <your-repo-url>
cd SecureByPay

# Install backend dependencies
cd backend && npm install && npm run build && cd ..

# Start the full-stack server
npm start
```

Open your browser to:
👉 **`http://localhost:5001`**

Both the frontend UI and the backend API are served seamlessly!

---

### 2. Running the Backend Independently

```bash
cd backend
npm install
npm run dev
```

Server will run on `http://localhost:5001`.
Health check: `http://localhost:5001/api/v1/health`

### 3. Running Backend Tests

```bash
cd backend
npm test
```

Expected output:
```
✔ GET /api/v1/health returns status ok
✔ POST /api/v1/auth/register fails if required fields are missing
✔ POST /api/v1/auth/register succeeds and issues token
✔ POST /api/v1/auth/login works for seeded demo account
✔ Protected routes reject requests without token
✔ Protected routes accept valid token
ℹ pass 6, fail 0
```

---

## 🔑 Demo Credentials

A default account is pre-seeded in the database for instant evaluation:
- **Email**: `user@example.com`
- **Password**: `Password123!`

You can also use the **Create account** form to register any new user.

---

## 📡 API Reference

Base URL: `http://localhost:5001/api/v1`

### Authentication
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/auth/register` | Register new user (firstName, lastName, email, phone, password) | No |
| `POST` | `/auth/login` | Log in and receive JWT token + user profile | No |
| `GET` | `/auth/me` | Fetch authenticated user profile | Yes (Bearer Token) |

### Dashboard & Analytics
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/dashboard/overview` | Fetch wallet balance, total shipments, exports, imports, trends | Yes |
| `GET` | `/dashboard/growth?period=year` | Fetch growth curve data (`year`, `month`, `week`) | Yes |
| `POST` | `/dashboard/wallet/fund` | Add funds to wallet balance (`amount`) | Yes |

### Shipments
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/shipments` | List all recent shipments | Yes |
| `GET` | `/shipments/:id` | Get shipment details by ID / Tracking ID | Yes |
| `POST` | `/shipments/:id/pay` | Pay for a shipment (updates status from Delayed to Paid) | Yes |

---

## 🌐 Hosting & Deployment Instructions

### Deploy to Render (Recommended for 1-Click Deployment)
1. Push this repository to GitHub.
2. Log into [Render.com](https://render.com) and click **New Web Service**.
3. Connect your GitHub repository.
4. Set the following configuration:
   - **Environment**: `Node`
   - **Build Command**: `npm install --prefix backend && npm run build --prefix backend`
   - **Start Command**: `npm start`
5. Click **Create Web Service**. Your live demo will be deployed with HTTPS automatically!

### Deploy to Railway
1. Create a project in [Railway.app](https://railway.app) from your GitHub repo.
2. Set start command: `npm start`.

---

## 📝 Assessment Submission Details

- **Role**: Full Stack Developer
- **Company**: SecureByPay
- **Applicant**: Chukwu
- **Candidate Email**: glory.okafor@securebypay.com
- **Deadline**: 12:00 PM, Saturday, 26th September
