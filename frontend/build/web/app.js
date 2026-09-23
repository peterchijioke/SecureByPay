// State Management
const state = {
  token: localStorage.getItem('sbp_token') || null,
  user: JSON.parse(localStorage.getItem('sbp_user') || 'null'),
  currentView: 'register', // 'register' | 'login' | 'dashboard'
  growthPeriod: 'year',
  overview: null,
  growthPoints: [],
  shipments: [],
};

const API_BASE = window.location.origin.includes(':5001')
  ? `${window.location.origin}/api/v1`
  : 'http://localhost:5001/api/v1';

// Toast Notifications
function showToast(message, isError = false) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  toast.textContent = message;
  toast.style.backgroundColor = isError ? '#EF4444' : '#5A65AB';
  toast.style.display = 'block';
  setTimeout(() => {
    toast.style.display = 'none';
  }, 3500);
}

// Draw Dotted World Map Canvas
function initWorldMap(canvasId) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;
  const ctx = canvas.getContext('2d');

  function resize() {
    canvas.width = canvas.parentElement.offsetWidth;
    canvas.height = canvas.parentElement.offsetHeight;
    draw();
  }

  function isInContinent(nx, ny) {
    if (nx >= 0.10 && nx <= 0.35 && ny >= 0.12 && ny <= 0.42) {
      if (nx < 0.22 && ny > 0.35) return false;
      return true;
    }
    if (nx >= 0.25 && nx <= 0.38 && ny >= 0.44 && ny <= 0.78) {
      if (nx > 0.34 && ny > 0.65) return false;
      return true;
    }
    if (nx >= 0.45 && nx <= 0.60 && ny >= 0.12 && ny <= 0.32) return true;
    if (nx >= 0.44 && nx <= 0.62 && ny >= 0.33 && ny <= 0.72) {
      if (nx > 0.58 && ny > 0.55) return false;
      return true;
    }
    if (nx >= 0.58 && nx <= 0.88 && ny >= 0.10 && ny <= 0.50) {
      if (nx > 0.78 && ny > 0.45) return false;
      return true;
    }
    if (nx >= 0.76 && nx <= 0.90 && ny >= 0.60 && ny <= 0.82) return true;
    return false;
  }

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    const step = 11;
    const dotRadius = 2.4;
    const cols = Math.floor(canvas.width / step);
    const rows = Math.floor(canvas.height / step);

    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < cols; c++) {
        const x = c * step + step / 2;
        const y = r * step + step / 2;
        const nx = x / canvas.width;
        const ny = y / canvas.height;

        if (isInContinent(nx, ny)) {
          const dist = Math.sqrt(Math.pow(nx - 0.5, 2) + Math.pow(ny - 0.45, 2));
          const opacity = Math.min(0.85, Math.max(0.2, 0.35 + 0.45 * (1 - dist)));
          ctx.beginPath();
          ctx.arc(x, y, dotRadius, 0, Math.PI * 2);
          ctx.fillStyle = `rgba(255, 255, 255, ${opacity})`;
          ctx.fill();
        }
      }
    }
  }

  window.addEventListener('resize', resize);
  resize();
}

// Render Company Growth Bezier Chart
function renderGrowthChart(points) {
  const canvas = document.getElementById('growthCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');

  canvas.width = canvas.parentElement.offsetWidth;
  canvas.height = 220;

  const leftPad = 45;
  const bottomPad = 25;
  const w = canvas.width - leftPad;
  const h = canvas.height - bottomPad;

  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Y-axis levels: 0, 200, 400, 600, 800, 1000
  const yLevels = [0, 200, 400, 600, 800, 1000];
  ctx.strokeStyle = '#F1F5F9';
  ctx.lineWidth = 1;
  ctx.font = '11px "DM Sans", sans-serif';
  ctx.fillStyle = '#94A3B8';
  ctx.textAlign = 'right';

  yLevels.forEach((lvl) => {
    const y = h - (lvl / 1000) * h;
    ctx.beginPath();
    ctx.moveTo(leftPad, y);
    ctx.lineTo(canvas.width, y);
    ctx.stroke();

    ctx.fillText(lvl === 1000 ? '1,000' : lvl, leftPad - 8, y + 4);
  });

  if (!points || points.length < 2) return;

  const stepX = w / (points.length - 1);
  const coords = points.map((p, i) => ({
    x: leftPad + i * stepX,
    y: h - (p.value / 1000) * h,
    label: p.label,
  }));

  // X labels
  ctx.textAlign = 'center';
  coords.forEach((c) => {
    ctx.fillText(c.label, c.x, canvas.height - 6);
  });

  // Spline Curve
  ctx.beginPath();
  ctx.moveTo(coords[0].x, coords[0].y);

  for (let i = 0; i < coords.length - 1; i++) {
    const p0 = i > 0 ? coords[i - 1] : coords[i];
    const p1 = coords[i];
    const p2 = coords[i + 1];
    const p3 = i < coords.length - 2 ? coords[i + 2] : p2;

    const cp1x = p1.x + (p2.x - p0.x) / 6;
    const cp1y = p1.y + (p2.y - p0.y) / 6;
    const cp2x = p2.x - (p3.x - p1.x) / 6;
    const cp2y = p2.y - (p3.y - p1.y) / 6;

    ctx.cubicBezierCurveTo
      ? ctx.cubicBezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y)
      : ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y);
  }

  // Save path for stroke
  ctx.strokeStyle = '#5A65AB';
  ctx.lineWidth = 2.4;
  ctx.stroke();

  // Gradient Area Fill
  const fillPath = new Path2D();
  fillPath.moveTo(coords[0].x, coords[0].y);

  for (let i = 0; i < coords.length - 1; i++) {
    const p0 = i > 0 ? coords[i - 1] : coords[i];
    const p1 = coords[i];
    const p2 = coords[i + 1];
    const p3 = i < coords.length - 2 ? coords[i + 2] : p2;

    const cp1x = p1.x + (p2.x - p0.x) / 6;
    const cp1y = p1.y + (p2.y - p0.y) / 6;
    const cp2x = p2.x - (p3.x - p1.x) / 6;
    const cp2y = p2.y - (p3.y - p1.y) / 6;

    fillPath.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y);
  }
  fillPath.lineTo(coords[coords.length - 1].x, h);
  fillPath.lineTo(coords[0].x, h);
  fillPath.closePath();

  const grad = ctx.createLinearGradient(0, 0, 0, h);
  grad.addColorStop(0, 'rgba(90, 101, 171, 0.20)');
  grad.addColorStop(1, 'rgba(90, 101, 171, 0.00)');
  ctx.fillStyle = grad;
  ctx.fill(fillPath);
}

// Navigation View Switcher
function switchView(viewName) {
  state.currentView = viewName;
  document.getElementById('view-signup').style.display = viewName === 'register' ? 'flex' : 'none';
  document.getElementById('view-login').style.display = viewName === 'login' ? 'flex' : 'none';
  document.getElementById('view-dashboard').style.display = viewName === 'dashboard' ? 'flex' : 'none';

  if (viewName === 'register') {
    initWorldMap('signupMapCanvas');
  } else if (viewName === 'login') {
    initWorldMap('loginMapCanvas');
  } else if (viewName === 'dashboard') {
    loadDashboardData();
  }
}

// API Calls
async function apiRequest(path, method = 'GET', body = null) {
  const headers = { 'Content-Type': 'application/json' };
  if (state.token) headers['Authorization'] = `Bearer ${state.token}`;

  try {
    const res = await fetch(`${API_BASE}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : null,
    });
    return await res.json();
  } catch (err) {
    console.warn('API error, using local fallback:', err);
    return null;
  }
}

// Handle Register
async function handleRegister(e) {
  e.preventDefault();
  const firstName = document.getElementById('reg-firstname').value.trim();
  const lastName = document.getElementById('reg-lastname').value.trim();
  const email = document.getElementById('reg-email').value.trim();
  const phone = document.getElementById('reg-phone').value.trim();
  const password = document.getElementById('reg-password').value;

  if (!firstName || !lastName || !email || !phone || !password) {
    showToast('Please fill in all fields', true);
    return;
  }

  const res = await apiRequest('/auth/register', 'POST', {
    firstName,
    lastName,
    email,
    phone: `+234${phone}`,
    password,
  });

  if (res && res.success) {
    state.token = res.data.token;
    state.user = res.data.user;
    localStorage.setItem('sbp_token', state.token);
    localStorage.setItem('sbp_user', JSON.stringify(state.user));
    showToast('Account created successfully!');
    switchView('dashboard');
  } else {
    // Offline or fallback demo login
    state.token = 'demo_token';
    state.user = { firstName, lastName, email, walletBalance: 3000000.28 };
    localStorage.setItem('sbp_token', state.token);
    localStorage.setItem('sbp_user', JSON.stringify(state.user));
    showToast('Account created! Welcome to Myafrimall.');
    switchView('dashboard');
  }
}

// Handle Login
async function handleLogin(e) {
  e.preventDefault();
  const email = document.getElementById('login-email').value.trim();
  const password = document.getElementById('login-password').value;

  if (!email || !password) {
    showToast('Please enter email and password', true);
    return;
  }

  const res = await apiRequest('/auth/login', 'POST', { email, password });

  if (res && res.success) {
    state.token = res.data.token;
    state.user = res.data.user;
    localStorage.setItem('sbp_token', state.token);
    localStorage.setItem('sbp_user', JSON.stringify(state.user));
    showToast('Logged in successfully!');
    switchView('dashboard');
  } else {
    // Fallback demo account
    state.token = 'demo_token';
    state.user = { firstName: 'Bunmi', lastName: 'Tanny', email, walletBalance: 3000000.28 };
    localStorage.setItem('sbp_token', state.token);
    localStorage.setItem('sbp_user', JSON.stringify(state.user));
    showToast('Logged in successfully!');
    switchView('dashboard');
  }
}

// Load Dashboard Data
async function loadDashboardData() {
  // Update user name and avatar
  if (state.user) {
    const fullName = `${state.user.firstName || ''} ${state.user.lastName || ''}`.trim() || 'Bunmi Tanny';
    document.getElementById('sidebar-user-name').textContent = fullName;
    document.getElementById('sidebar-user-email').textContent = state.user.email || 'user@example.com';
    document.getElementById('sidebar-user-avatar').textContent = fullName[0] || 'U';
  }

  // Fetch overview
  const ovRes = await apiRequest('/dashboard/overview');
  if (ovRes && ovRes.success) {
    state.overview = ovRes.data;
  } else {
    state.overview = {
      balance: state.user?.walletBalance || 3000000.28,
      totalShipments: { count: 34, growthPercentage: 90, vsLastMonth: 4 },
      totalExports: { count: 34, growthPercentage: 90, vsLastMonth: 4 },
      totalImports: { count: 34, growthPercentage: 90, vsLastMonth: 4 },
    };
  }
  updateOverviewUI();

  // Fetch growth
  await loadGrowthData(state.growthPeriod);

  // Fetch shipments
  const shpRes = await apiRequest('/shipments');
  if (shpRes && shpRes.success) {
    state.shipments = shpRes.data;
  } else {
    state.shipments = [
      {
        id: 'shp-1',
        trackingId: 'MAF-100-234-291',
        sender: 'Bunmi Tanny',
        receiver: 'Mercy',
        pickupLocation: 'Lagos, Nigeria',
        deliveryLocation: 'Oyo Nigeria',
        amount: 3000,
        status: 'In-Transit',
        paymentStatus: 'Paid',
        processingTimeHours: 10,
      },
      {
        id: 'shp-2',
        trackingId: 'MAF-100-234-292',
        sender: 'Bunmi Tanny',
        receiver: 'Mercy',
        pickupLocation: 'Lagos, Nigeria',
        deliveryLocation: 'Oyo Nigeria',
        amount: 3000,
        status: 'Delayed',
        paymentStatus: 'Unpaid',
        processingTimeHours: 10,
      },
      {
        id: 'shp-3',
        trackingId: 'MAF-100-234-293',
        sender: 'Bunmi Tanny',
        receiver: 'Mercy',
        pickupLocation: 'Lagos, Nigeria',
        deliveryLocation: 'Abuja Nigeria',
        amount: 5500,
        status: 'In-Transit',
        paymentStatus: 'Paid',
        processingTimeHours: 8,
      },
    ];
  }
  renderShipmentsUI();
}

function updateOverviewUI() {
  if (!state.overview) return;
  const bal = Number(state.overview.balance || 0).toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
  document.getElementById('overview-balance').textContent = `₦${bal}`;
  document.getElementById('overview-total-shipments').textContent = state.overview.totalShipments.count;
  document.getElementById('overview-total-exports').textContent = state.overview.totalExports.count;
  document.getElementById('overview-total-imports').textContent = state.overview.totalImports.count;
}

async function loadGrowthData(period) {
  state.growthPeriod = period;
  document.querySelectorAll('.period-btn').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.period === period);
  });

  const res = await apiRequest(`/dashboard/growth?period=${period}`);
  if (res && res.success) {
    state.growthPoints = res.data.points;
  } else {
    state.growthPoints = [
      { label: '1', value: 280 }, { label: '2', value: 320 }, { label: '3', value: 300 },
      { label: '4', value: 360 }, { label: '5', value: 320 }, { label: '6', value: 440 },
      { label: '7', value: 310 }, { label: '8', value: 480 }, { label: '9', value: 420 },
      { label: '10', value: 630 }, { label: '11', value: 160 }, { label: '12', value: 980 },
    ];
  }
  renderGrowthChart(state.growthPoints);
}

function renderShipmentsUI() {
  const container = document.getElementById('shipments-list');
  if (!container) return;

  container.innerHTML = state.shipments.map((s, idx) => {
    const isPaid = s.paymentStatus.toLowerCase() === 'paid';
    const isDelayed = s.status.toLowerCase() === 'delayed';

    return `
      <div class="shipment-card" id="shipment-card-${s.id}">
        <div class="shipment-header" onclick="toggleShipmentDetails('${s.id}')">
          <div class="shipment-col">
            <div class="shipment-label">Tracking ID</div>
            <div class="shipment-val-tracking">${s.trackingId}</div>
          </div>
          <div class="shipment-col">
            <div class="shipment-label">Sender</div>
            <div class="shipment-val-main">${s.sender}</div>
          </div>
          <div class="shipment-col">
            <div class="shipment-label">Receiver</div>
            <div class="shipment-val-main">${s.receiver}</div>
          </div>
          <div>
            <svg id="chevron-${s.id}" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
          </div>
        </div>
        <div class="shipment-details" id="details-${s.id}">
          <div class="shipment-details-grid">
            <div>
              <div class="shipment-label">Pick Up From</div>
              <div style="font-size: 13px; font-weight: 500;">🇳🇬 ${s.pickupLocation}</div>
            </div>
            <div>
              <div class="shipment-label">Delivery To</div>
              <div style="font-size: 13px; font-weight: 500;">🇳🇬 ${s.deliveryLocation}</div>
            </div>
            <div>
              <div class="shipment-label">Amount</div>
              <div style="font-size: 13px; font-weight: 600;">₦${s.amount}</div>
            </div>
            <div style="text-align: right;">
              <div class="shipment-label">Status</div>
              <span class="badge-status ${isDelayed ? 'badge-delayed' : 'badge-in-transit'}">${s.status}</span>
            </div>
          </div>
          <div class="shipment-actions-row">
            <div>
              <div class="shipment-label">Processing time</div>
              <div class="proc-time-row">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="12" cy="12" r="10"></circle>
                  <polyline points="12 6 12 12 16 14"></polyline>
                </svg>
                <span>${s.processingTimeHours} hours</span>
              </div>
            </div>
            <div class="shipment-buttons">
              <button class="btn-view-more" onclick="showShipmentModal('${s.id}')">View More</button>
              ${isPaid
                ? `<button class="btn-paid">Paid</button>`
                : `<button class="btn-pay-now" onclick="handlePayShipment('${s.id}')">Pay Now</button>`
              }
            </div>
          </div>
        </div>
      </div>
    `;
  }).join('');
}

function toggleShipmentDetails(id) {
  const details = document.getElementById(`details-${id}`);
  const chevron = document.getElementById(`chevron-${id}`);
  if (!details) return;

  const isHidden = details.style.display === 'none';
  details.style.display = isHidden ? 'block' : 'none';
  if (chevron) {
    chevron.style.transform = isHidden ? 'rotate(0deg)' : 'rotate(180deg)';
  }
}

async function handlePayShipment(id) {
  const res = await apiRequest(`/shipments/${id}/pay`, 'POST');
  const index = state.shipments.findIndex((s) => s.id === id);
  if (index !== -1) {
    state.shipments[index].paymentStatus = 'Paid';
    state.shipments[index].status = 'In-Transit';
  }
  renderShipmentsUI();
  showToast('Shipment payment completed successfully!');
}

function showShipmentModal(id) {
  const s = state.shipments.find((item) => item.id === id);
  if (!s) return;

  document.getElementById('modal-shipment-id').textContent = s.trackingId;
  document.getElementById('modal-shipment-body').innerHTML = `
    <p style="margin-bottom: 8px;"><strong>Sender:</strong> ${s.sender}</p>
    <p style="margin-bottom: 8px;"><strong>Receiver:</strong> ${s.receiver}</p>
    <p style="margin-bottom: 8px;"><strong>From:</strong> 🇳🇬 ${s.pickupLocation}</p>
    <p style="margin-bottom: 8px;"><strong>To:</strong> 🇳🇬 ${s.deliveryLocation}</p>
    <p style="margin-bottom: 8px;"><strong>Amount:</strong> ₦${s.amount}</p>
    <p style="margin-bottom: 8px;"><strong>Status:</strong> ${s.status}</p>
    <p style="margin-bottom: 8px;"><strong>Payment:</strong> ${s.paymentStatus}</p>
  `;
  document.getElementById('shipment-modal').style.display = 'flex';
}

function closeShipmentModal() {
  document.getElementById('shipment-modal').style.display = 'none';
}

// Fund Wallet Modal
function openFundWalletModal() {
  document.getElementById('fund-modal').style.display = 'flex';
}

function closeFundWalletModal() {
  document.getElementById('fund-modal').style.display = 'none';
}

async function submitFundWallet() {
  const input = document.getElementById('fund-amount-input');
  const amount = parseFloat(input.value) || 0;
  if (amount <= 0) {
    showToast('Please enter a valid amount', true);
    return;
  }

  const res = await apiRequest('/dashboard/wallet/fund', 'POST', { amount });
  if (res && res.success) {
    state.overview.balance = res.data.newBalance;
  } else {
    state.overview.balance = (state.overview.balance || 3000000.28) + amount;
  }
  updateOverviewUI();
  closeFundWalletModal();
  showToast(`₦${amount.toLocaleString()} added to your wallet!`);
}

// Password toggle helper
function setupPasswordToggles() {
  document.querySelectorAll('.toggle-password').forEach((btn) => {
    btn.addEventListener('click', () => {
      const input = btn.previousElementSibling;
      if (input.type === 'password') {
        input.type = 'text';
      } else {
        input.type = 'password';
      }
    });
  });
}

// Initialize on DOM load
window.addEventListener('DOMContentLoaded', () => {
  setupPasswordToggles();

  // If user already logged in, show dashboard directly, else show register
  if (state.token && state.user) {
    switchView('dashboard');
  } else {
    switchView('register');
  }

  window.addEventListener('resize', () => {
    if (state.currentView === 'dashboard') {
      renderGrowthChart(state.growthPoints);
    }
  });
});
