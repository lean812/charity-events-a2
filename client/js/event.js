/**
 * event.js
 * Reads the selected event id from the URL query string (?id=), requests that
 * event's full details from the API, and renders a professional detail layout.
 * The Register button opens a modal because purchasing is added in Assessment 3.
 */
(function () {
  const root = document.getElementById('detail-root');

  function renderError(message) {
    root.innerHTML = `
      <div class="container section">
        <div class="empty-message">
          <strong>Event unavailable</strong><br />
          ${message}<br /><br />
          <a class="btn" href="search.html">Back to Search Events</a>
        </div>
      </div>`;
  }

  function render(ev) {
    const colour = categoryColour(ev.category_name);
    const timeRange = ev.start_time
      ? `${formatTime(ev.start_time)}${ev.end_time ? ' &ndash; ' + formatTime(ev.end_time) : ''}`
      : 'TBC';
    const priceLabel =
      ev.ticket_price === 0
        ? '<span class="free-label">Free entry</span>'
        : '$' + ev.ticket_price.toFixed(2);

    root.innerHTML = `
      <section class="detail-hero" style="background:linear-gradient(120deg, ${colour}, var(--teal-900))">
        <div class="container">
          <span class="tag">${ev.category_name}</span>
          <h1>${ev.event_name}</h1>
          <p class="org">Hosted by ${ev.org_name}</p>
        </div>
      </section>

      <section class="section">
        <div class="container detail-layout">
          <div class="detail-main">
            <h2>About this event</h2>
            <p>${ev.summary}</p>
            <p>${ev.full_description}</p>

            <h2>Purpose</h2>
            <p>${ev.org_mission}</p>
          </div>

          <aside class="detail-side">
            <ul class="fact-list">
              <li>
                <span class="fact-label">Date</span>
                <span>${formatDate(ev.event_date)}</span>
              </li>
              <li>
                <span class="fact-label">Time</span>
                <span>${timeRange}</span>
              </li>
              <li>
                <span class="fact-label">Venue</span>
                <span>${ev.location_name || 'TBC'}</span>
              </li>
              <li>
                <span class="fact-label">Address</span>
                <span>${ev.address ? ev.address + ', ' : ''}${ev.city || ''}</span>
              </li>
              <li>
                <span class="fact-label">Category</span>
                <span>${ev.category_name}</span>
              </li>
            </ul>

            <div class="price-line">${priceLabel}</div>

            <div class="progress-wrap">
              <div class="progress-values">
                <span>Raised: $${ev.raised_amount.toLocaleString()}</span>
                <span>Goal: $${ev.goal_amount.toLocaleString()}</span>
              </div>
              <div class="progress-bar">
                <div class="fill" style="width:${ev.progress_percent}%"></div>
              </div>
              <p class="register-note">${ev.progress_percent}% of the fundraising goal</p>
            </div>

            <button type="button" class="btn btn-amber" id="register-btn"
                    style="width:100%">Register</button>
            <p class="register-note">Your registration is a donation to this cause.</p>
          </aside>
        </div>
      </section>`;

    document
      .getElementById('register-btn')
      .addEventListener('click', () => {
        openModal('This feature is currently under construction.');
      });
  }

  async function init() {
    const params = new URLSearchParams(window.location.search);
    const id = params.get('id');

    if (!id || !/^\d+$/.test(id)) {
      renderError('No valid event was selected. Please choose an event from the Home or Search page.');
      return;
    }
    try {
      const res = await fetchJSON('/events/' + id);
      render(res.data);
    } catch (err) {
      renderError(err.message);
    }
  }

  init();
})();
