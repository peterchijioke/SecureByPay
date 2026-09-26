# SecureByPay — Render Deployment Guide

## Architecture on Render

| Service | Type | Source |
|---|---|---|
| `securebypay-api` | Web Service (Node.js) | `backend/` |
| `securebypay-frontend` | Static Site | `frontend/build/web/` |

---

## Step 1 — Push to GitHub

Make sure the repo is on GitHub. The `frontend/build/web/` folder must be committed (it is not ignored — see `.gitignore`).

```bash
git add .
git commit -m "chore: prepare for Render deployment"
git push origin main
```

---

## Step 2 — Deploy the Backend (Web Service)

1. In Render → **New → Web Service**
2. Connect your GitHub repo
3. Set the following:

| Setting | Value |
|---|---|
| **Root Directory** | `backend` |
| **Runtime** | `Node` |
| **Build Command** | `npm install && npm run build` |
| **Start Command** | `npm start` |

4. Add **Environment Variables**:

| Key | Value |
|---|---|
| `NODE_ENV` | `production` |
| `PORT` | `10000` |
| `JWT_SECRET` | *(Generate or set a strong secret)* |
| `JWT_EXPIRES_IN` | `7d` |

5. Click **Deploy**. Note your backend URL e.g. `https://securebypay-api.onrender.com`

---

## Step 3 — Rebuild Flutter with the Production API URL

Once you know your backend URL, rebuild the Flutter web app:

```bash
cd frontend
flutter build web \
  --release \
  --no-tree-shake-icons \
  --dart-define="API_BASE_URL=https://YOUR-BACKEND.onrender.com/api/v1"
```

Or use the provided script (edit the URL inside first):
```bash
API_BASE_URL=https://YOUR-BACKEND.onrender.com/api/v1 ./frontend/build.sh
```

Commit the new build:
```bash
git add frontend/build/web
git commit -m "chore: production flutter build for Render"
git push origin main
```

---

## Step 4 — Deploy the Frontend (Static Site)

1. In Render → **New → Static Site**
2. Connect the same GitHub repo
3. Set the following:

| Setting | Value |
|---|---|
| **Root Directory** | `frontend/build/web` |
| **Build Command** | *(leave empty)* |
| **Publish Directory** | `.` |

4. Under **Redirects/Rewrites**, add:

| Source | Destination | Action |
|---|---|---|
| `/*` | `/index.html` | Rewrite |

5. Click **Deploy**

---

## Step 5 — Configure CORS (if needed)

If the frontend and backend are on different Render subdomains, update `backend/src/app.ts` to allow your frontend's Render URL:

```typescript
app.use(cors({
  origin: ['https://securebypay-frontend.onrender.com'],
  ...
}));
```

---

## Blueprint Deployment (Automatic)

The `render.yaml` in the repo root defines both services. You can deploy both at once via:

**Render Dashboard → New → Blueprint** → connect repo → Deploy

---

## Seed Data

On first boot the backend auto-creates `backend/data/users.json` with two accounts:

| Email | Password | Role |
|---|---|---|
| `user@example.com` | `Password123!` | user |
| `admin@securebypay.com` | `Password123!` | admin |

> ⚠️ **Note**: Render's free tier has ephemeral disk — `data/users.json` resets on each deploy. For persistent data, upgrade to a paid plan with a Disk mount, or migrate to a database.
