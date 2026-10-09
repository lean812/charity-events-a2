/**
 * common.js
 * Shared helpers used by all three pages: API calls (Promises), date/price
 * formatting, category colours, card rendering and the generic modal.
 */

/* ---------- API helper -------------------------------------------------- */

/**
 * fetchJSON - performs a GET request and parses the JSON response.
 * Returns a Promise that rejects with a clear Error on network or HTTP failure.
 * @param {string} path  path relative to the API base, e.g. '/events'
 * @returns {Promise<any>} parsed response body
 */
async function fetchJSON(path) {
  const url = window.API_CONFIG.BASE_URL + path;
  let response;
  try {
    response = await fetch(url);
  } catch (networkErr) {
    throw new Error(
      'Unable to reach the server. Please make sure the API is running on ' +
        window.API_CONFIG.BASE_URL
    );
  }

  const body = await response.json().catch(() => null);
  if (!response.ok) {
    const message = (body && body.message) || `Request failed (${response.status})`;
    throw new Error(message);
  }
  return body;
}

/* ---------- Formatting helpers ----------------------------------------- */

function formatDate(dateStr) {
  if (!dateStr) return 'TBC';
  const d = new Date(dateStr + 'T00:00:00');
  if (Number.isNaN(d.getTime())) return dateStr;
  return d.toLocaleDateString('en-AU', {
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

function formatTime(timeStr) {
  if (!timeStr) return '';
  const [h, m] = timeStr.split(':');
  const hour = Number(h);
  const ampm = hour >= 12 ? 'PM' : 'AM';
  const hour12 = hour % 12 === 0 ? 12 : hour % 12;
  return `${hour12}:${m} ${ampm}`;
}

function formatPrice(price) {
  const value = Number(price);
  if (value === 0) return 'Free';
  return '$' + value.toFixed(2);
}

// A stable colour per category, used for the card thumbnail and tags
const CATEGORY_COLOURS = {
  'Fun Run': '#2e8b7d',
  'Gala Dinner': '#b8860b',
  'Silent Auction': '#7a5c9e',
  'Charity Concert': '#c0504d',
  'Community Walk': '#4f8a3b',
  'Bake Sale': '#d0873c',
};

function categoryColour(name) {
  return CATEGORY_COLOURS[name] || '#5a7184';
}

/* ---------- Reusable card markup --------------------------------------- */

function eventCardHTML(ev) {
  const colour = categoryColour(ev.category_name);
  const initials = ev.category_name
    .split(' ')
    .map((w) => w[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();
  return `
    <article class="event-card">
      <a class="card-thumb" href="event.html?id=${ev.event_id}"
         style="background:linear-gradient(135deg, ${colour}, ${colour}bb)"
         aria-label="View details of ${ev.event_name}">
        <span class="thumb-initials">${initials}</span>
        <span class="thumb-category">${ev.category_name}</span>
      </a>
      <div class="card-body">
        <h3 class="card-title">
          <a href="event.html?id=${ev.event_id}">${ev.event_name}</a>
        </h3>
        <p class="card-meta">
          <span class="meta-icon" aria-hidden="true">&#128197;</span> ${formatDate(ev.event_date)}
        </p>
        <p class="card-meta">
          <span class="meta-icon" aria-hidden="true">&#128205;</span>
          ${ev.location_name || ev.city}
        </p>
        <div class="card-footer">
          <span class="ticket-price">${formatPrice(ev.ticket_price)}</span>
          <a class="btn btn-sm" href="event.html?id=${ev.event_id}">View details</a>
        </div>
      </div>
    </article>`;
}

function renderEventCards(events, container) {
  if (!events.length) {
    container.innerHTML =
      '<p class="empty-message">No events to display.</p>';
    return;
  }
  container.innerHTML = events.map(eventCardHTML).join('');
}

/* ---------- Generic modal ---------------------------------------------- */

function openModal(message) {
  let overlay = document.getElementById('generic-modal');
  if (!overlay) {
    overlay = document.createElement('div');
    overlay.id = 'generic-modal';
    overlay.className = 'modal-overlay';
    overlay.innerHTML = `
      <div class="modal-box" role="dialog" aria-modal="true">
        <p class="modal-message"></p>
        <button type="button" class="btn modal-close">OK</button>
      </div>`;
    document.body.appendChild(overlay);
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay || e.target.classList.contains('modal-close')) {
        overlay.classList.remove('show');
      }
    });
  }
  overlay.querySelector('.modal-message').textContent = message;
  overlay.classList.add('show');
}
