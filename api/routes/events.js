/**
 * routes/events.js
 * ---------------------------------------------------------------------------
 * GET /api/events        Home page list / Search page filtered list
 * GET /api/events/:id    Full details of a single event
 * ---------------------------------------------------------------------------
 */
const express = require('express');
const { query } = require('../event_db');

const router = express.Router();

// Columns shared by the Home and Search summary views
const LIST_COLUMNS = `
  e.event_id, e.event_name, e.summary, e.event_date, e.start_time,
  e.location_name, e.address, e.city, e.ticket_price,
  e.goal_amount, e.raised_amount, e.image_url,
  c.category_id, c.category_name,
  o.org_id, o.org_name
`;

// Convert the DECIMAL values (returned as strings by the driver) into numbers
function normaliseEvent(row) {
  return {
    ...row,
    ticket_price: Number(row.ticket_price),
    goal_amount: Number(row.goal_amount),
    raised_amount: Number(row.raised_amount),
  };
}

/**
 * GET /api/events
 * Without query parameters: returns all ACTIVE, UPCOMING events (Home page).
 * With any of the parameters below it additionally filters the results
 * (Search page):
 *   date         -> exact event date, YYYY-MM-DD
 *   location     -> partial match on city / address / location name
 *   category_id  -> exact category id
 */
router.get('/', async (req, res, next) => {
  try {
    const { date, location, category_id } = req.query;

    // Base condition: only active (never suspended) and upcoming events.
    const conditions = ["e.status = 'active'", 'e.event_date >= CURDATE()'];
    const params = [];

    if (date) {
      conditions.push('e.event_date = ?');
      params.push(date);
    }
    if (location && location.trim() !== '') {
      conditions.push(
        '(e.city LIKE ? OR e.location_name LIKE ? OR e.address LIKE ?)'
      );
      const like = `%${location.trim()}%`;
      params.push(like, like, like);
    }
    if (category_id) {
      conditions.push('e.category_id = ?');
      params.push(category_id);
    }

    const sql = `
      SELECT ${LIST_COLUMNS}
      FROM events e
      JOIN categories c   ON c.category_id = e.category_id
      JOIN organisations o ON o.org_id = e.org_id
      WHERE ${conditions.join(' AND ')}
      ORDER BY e.event_date ASC, e.start_time ASC;
    `;

    const rows = await query(sql, params);
    const events = rows.map(normaliseEvent);

    res.json({
      success: true,
      count: events.length,
      filters_applied: {
        date: date || null,
        location: location || null,
        category_id: category_id || null,
      },
      data: events,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/events/:id
 * Returns every detail for one event, including its category and the hosting
 * organisation. A 404 is returned when the event does not exist or is
 * suspended (suspended events must remain hidden).
 */
router.get('/:id', async (req, res, next) => {
  try {
    const eventId = Number(req.params.id);
    if (!Number.isInteger(eventId) || eventId <= 0) {
      return res.status(400).json({
        success: false,
        message: 'A valid numeric event id is required.',
      });
    }

    const sql = `
      SELECT e.*, c.category_name,
             o.org_name, o.mission AS org_mission,
             o.contact_email AS org_email, o.contact_phone AS org_phone,
             o.website AS org_website, o.address AS org_address
      FROM events e
      JOIN categories c   ON c.category_id = e.category_id
      JOIN organisations o ON o.org_id = e.org_id
      WHERE e.event_id = ? AND e.status = 'active';
    `;
    const rows = await query(sql, [eventId]);

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: `No active event found with id ${eventId}.`,
      });
    }

    const event = normaliseEvent(rows[0]);
    // Progress percentage towards the fundraising goal (0 when no goal set)
    event.progress_percent =
      event.goal_amount > 0
        ? Math.min(100, Math.round((event.raised_amount / event.goal_amount) * 100))
        : 0;

    res.json({ success: true, data: event });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
