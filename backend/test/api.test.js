const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');

// We test against the built app
const app = require('../dist/app').default;

let server;
let baseUrl;

test.before(async () => {
  await new Promise((resolve) => {
    server = http.createServer(app);
    server.listen(0, () => {
      const port = server.address().port;
      baseUrl = `http://localhost:${port}`;
      resolve();
    });
  });
});

test.after(async () => {
  await new Promise((resolve) => server.close(resolve));
});

test('GET /api/v1/health returns status ok', async () => {
  const res = await fetch(`${baseUrl}/api/v1/health`);
  const body = await res.json();
  assert.strictEqual(res.status, 200);
  assert.strictEqual(body.status, 'ok');
  assert.strictEqual(body.service, 'SecureByPay API');
});

test('POST /api/v1/auth/register fails if required fields are missing', async () => {
  const res = await fetch(`${baseUrl}/api/v1/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'test@example.com' }),
  });
  const body = await res.json();
  assert.strictEqual(res.status, 400);
  assert.strictEqual(body.success, false);
});

test('POST /api/v1/auth/register succeeds and issues token', async () => {
  const uniqueEmail = `test_${Date.now()}@securebypay.com`;
  const res = await fetch(`${baseUrl}/api/v1/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      firstName: 'Chukwu',
      lastName: 'Emeka',
      email: uniqueEmail,
      phone: '+2348012345678',
      password: 'SecurePassword123!',
    }),
  });
  const body = await res.json();
  assert.strictEqual(res.status, 201);
  assert.strictEqual(body.success, true);
  assert.ok(body.data.token);
  assert.strictEqual(body.data.user.email, uniqueEmail);
  assert.strictEqual(body.data.user.firstName, 'Chukwu');
});

test('POST /api/v1/auth/login works for seeded demo account', async () => {
  const res = await fetch(`${baseUrl}/api/v1/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'user@example.com',
      password: 'Password123!',
    }),
  });
  const body = await res.json();
  assert.strictEqual(res.status, 200);
  assert.strictEqual(body.success, true);
  assert.ok(body.data.token);
  assert.strictEqual(body.data.user.email, 'user@example.com');
});

test('Protected routes reject requests without token', async () => {
  const res = await fetch(`${baseUrl}/api/v1/dashboard/overview`);
  assert.strictEqual(res.status, 401);
});

test('Protected routes accept valid token', async () => {
  // First login
  const loginRes = await fetch(`${baseUrl}/api/v1/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'user@example.com',
      password: 'Password123!',
    }),
  });
  const loginData = await loginRes.json();
  const token = loginData.data.token;

  // Test /api/v1/dashboard/overview
  const overviewRes = await fetch(`${baseUrl}/api/v1/dashboard/overview`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const overviewBody = await overviewRes.json();
  assert.strictEqual(overviewRes.status, 200);
  assert.strictEqual(overviewBody.data.balance, 3000000.28);
  assert.strictEqual(overviewBody.data.totalShipments.count, 34);

  // Test /api/v1/dashboard/growth
  const growthRes = await fetch(`${baseUrl}/api/v1/dashboard/growth?period=year`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const growthBody = await growthRes.json();
  assert.strictEqual(growthRes.status, 200);
  assert.strictEqual(growthBody.data.points.length, 12);

  // Test /api/v1/shipments
  const shipmentsRes = await fetch(`${baseUrl}/api/v1/shipments`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const shipmentsBody = await shipmentsRes.json();
  assert.strictEqual(shipmentsRes.status, 200);
  assert.ok(shipmentsBody.data.length >= 2);
});
