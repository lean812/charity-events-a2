-- =====================================================================
-- PROG2002 Web Development II - Assignment 2
-- Charity Events Management Website
-- Database export script: charityevents_db.sql
-- DBMS: MySQL 8.x (InnoDB, utf8mb4)
--
-- This script creates the database, schema, relationships and the
-- initial sample dataset. Run it once in MySQL Workbench or with:
--     mysql -u root -p < charityevents_db.sql
-- =====================================================================

DROP DATABASE IF EXISTS charityevents_db;
CREATE DATABASE charityevents_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE charityevents_db;

-- ---------------------------------------------------------------------
-- Table: organisations  (the charitable organisations hosting events)
-- ---------------------------------------------------------------------
CREATE TABLE organisations (
  org_id        INT AUTO_INCREMENT PRIMARY KEY,
  org_name      VARCHAR(150) NOT NULL,
  mission       TEXT,
  description   TEXT,
  contact_email VARCHAR(120),
  contact_phone VARCHAR(30),
  website       VARCHAR(150),
  address       VARCHAR(255),
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Table: categories  (types of charity events)
-- ---------------------------------------------------------------------
CREATE TABLE categories (
  category_id   INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(80) NOT NULL,
  description   VARCHAR(255)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Table: events
--   status = 'active' (visible) or 'suspended' (hidden, policy violation)
--   "past" vs "upcoming" is derived at run time from event_date and the
--   current date; it is therefore not stored as a separate status.
-- ---------------------------------------------------------------------
CREATE TABLE events (
  event_id        INT AUTO_INCREMENT PRIMARY KEY,
  event_name      VARCHAR(200) NOT NULL,
  summary         VARCHAR(300),
  full_description TEXT,
  category_id     INT NOT NULL,
  org_id          INT NOT NULL,
  event_date      DATE NOT NULL,
  start_time      TIME,
  end_time        TIME,
  location_name   VARCHAR(150),
  address         VARCHAR(255),
  city            VARCHAR(80),
  ticket_price    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  goal_amount     DECIMAL(12,2),
  raised_amount   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  image_url       VARCHAR(255),
  status          ENUM('active','suspended') NOT NULL DEFAULT 'active',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_event_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_event_org
    FOREIGN KEY (org_id) REFERENCES organisations(org_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- Helpful indexes for the Home / Search / Details queries
CREATE INDEX idx_events_date     ON events(event_date);
CREATE INDEX idx_events_city     ON events(city);
CREATE INDEX idx_events_category ON events(category_id);
CREATE INDEX idx_events_status   ON events(status);

-- =====================================================================
-- Initial data
-- =====================================================================

-- Organisations -------------------------------------------------------
INSERT INTO organisations
  (org_id, org_name, mission, description, contact_email, contact_phone, website, address) VALUES
(1, 'Heart of Liuzhou Foundation',
 'To connect caring people in Liuzhou with local causes through community events that raise funds and awareness for education, health and community welfare.',
 'Heart of Liuzhou Foundation is a registered non-profit organisation that organises fun runs, gala dinners, auctions, concerts and community walks across Liuzhou. Every event raises money and awareness for a specific local cause.',
 'hello@heartofliuzhou.org', '+86 772 2600 100',
 'www.heartofliuzhou.org', 'No. 8 Wenchang Road, Chengzhong District, Liuzhou, Guangxi'),
(2, 'Riverside Community Care',
 'To support vulnerable families and elderly residents living along the Liu River through neighbour-led fundraising and volunteer activities.',
 'Riverside Community Care is a volunteer-run charity focused on neighbourhood welfare, food drives and health outreach in the riverside districts of Liuzhou.',
 'contact@riversidecare.org', '+86 772 2600 200',
 'www.riversidecare.org', 'No. 21 Riverside Avenue, Yufeng District, Liuzhou, Guangxi');

-- Categories ----------------------------------------------------------
INSERT INTO categories (category_id, category_name, description) VALUES
(1, 'Fun Run',          'Organised running events where participants raise funds through registration and sponsorship.'),
(2, 'Gala Dinner',      'Formal evening dinners with entertainment, held to raise donations for a cause.'),
(3, 'Silent Auction',   'Events where donated goods and experiences are sold to the highest sealed bid.'),
(4, 'Charity Concert',  'Live music and performance events where ticket sales support a charity.'),
(5, 'Community Walk',   'Group walking events that raise awareness and funds for a specific cause.'),
(6, 'Bake Sale',        'Community sales of home-baked goods, with all proceeds donated to charity.');

-- Events --------------------------------------------------------------
-- Upcoming + active (shown on the Home page after 2026-10-09)
INSERT INTO events
  (event_id, event_name, summary, full_description, category_id, org_id,
   event_date, start_time, end_time, location_name, address, city,
   ticket_price, goal_amount, raised_amount, image_url, status) VALUES
(1, 'Spring Community Fun Run',
 'A 5 km family fun run through Wenchang District raising funds for rural school libraries.',
 'Join hundreds of runners for the Spring Community Fun Run. The flat 5 km route is suitable for all ages and abilities, and every registration helps build libraries in rural schools around Liuzhou. The morning includes a warm-up session, water stations along the route, a finisher medal for every participant, and a community picnic at the finish line. Families, teams and first-time runners are all welcome.',
 1, 1, '2026-10-24', '08:00:00', '11:30:00',
 'Liuzhou Sports Center', 'No. 1 Sports Road, Chengzhong District', 'Liuzhou',
 50.00, 40000.00, 12500.00, 'funrun.jpg', 'active'),

(2, 'Annual Charity Gala Dinner',
 'An elegant evening of dinner, live music and guest speakers supporting children''s healthcare.',
 'The Annual Charity Gala Dinner is our flagship fundraising evening. Guests enjoy a three-course dinner, live jazz, a guest speaker from the children''s hospital, and a short programme sharing the stories of families supported this year. All proceeds fund medical equipment and treatment for children in need. Black tie is optional and tables of ten are available for corporate sponsors.',
 2, 1, '2026-11-14', '18:30:00', '22:00:00',
 'Liuzhou International Hotel Grand Ballroom', 'No. 55 Youyi Road', 'Liuzhou',
 380.00, 120000.00, 46800.00, 'gala.jpg', 'active'),

(3, 'Hope Silent Auction',
 'Bid on donated art, dinners, travel and experiences, with all proceeds funding student scholarships.',
 'The Hope Silent Auction brings together over 80 generously donated lots, including artwork, hotel stays, restaurant vouchers, guided tours and unique experiences. Bidders place sealed offers during the evening and the highest bid for each lot is announced at the close. Light refreshments are included and admission is free. Every yuan raised goes directly to scholarships for students from low-income families.',
 3, 1, '2026-11-28', '15:00:00', '19:00:00',
 'Wenchang Cultural Hall', 'No. 12 Wenchang Road', 'Liuzhou',
 0.00, 60000.00, 9300.00, 'auction.jpg', 'active'),

(4, 'Voices for Change Charity Concert',
 'An evening of live performances by local artists raising funds for community mental-health programmes.',
 'Voices for Change is a concert celebrating local talent while supporting mental-health programmes in Liuzhou. The line-up features bands, choirs and solo artists, alongside short talks from people who have benefited from the programmes. Ticket sales and donations fund free counselling sessions and community support groups. Seating is general admission and doors open one hour before the show.',
 4, 1, '2026-12-05', '19:30:00', '22:00:00',
 'Liuzhou Cultural Square Grand Theatre', 'No. 30 Jiefang South Road', 'Liuzhou',
 120.00, 80000.00, 21600.00, 'concert.jpg', 'active'),

(5, 'Winter Warmth Community Walk',
 'A gentle 3 km riverside walk raising funds for winter clothing for elderly residents.',
 'The Winter Warmth Community Walk is a relaxed 3 km walk along the Liu River riverfront. The event brings neighbours together to raise money for warm coats, blankets and heaters for elderly residents in the riverside communities. The walk is wheelchair and pram friendly, hot drinks are provided at the finish, and no fundraising minimum is required beyond registration.',
 5, 2, '2026-12-19', '09:00:00', '11:00:00',
 'Liu River Riverside Park', 'No. 21 Riverside Avenue', 'Liuzhou',
 30.00, 25000.00, 4800.00, 'walk.jpg', 'active'),

(6, 'New Year Charity Bake Sale',
 'Home-baked cakes, breads and treats sold to support neighbourhood food-assistance families.',
 'Start the new year with something sweet for a good cause. Volunteers and local bakeries donate hundreds of home-baked cakes, cookies, breads and seasonal treats, all sold with 100% of proceeds going to neighbourhood food assistance for families facing hardship. Entry is free, coffee and tea are available, and donations of baked goods on the day are very welcome.',
 6, 2, '2027-01-09', '10:00:00', '15:00:00',
 'Yufeng Community Centre', 'No. 9 Yufeng Road', 'Liuzhou',
 0.00, 15000.00, 1200.00, 'bakesale.jpg', 'active'),

(7, 'Moonlight Fun Run',
 'A glowing night-time 5 km fun run with glow sticks and music, supporting flood-relief efforts.',
 'Experience the city after dark at the Moonlight Fun Run. Runners receive a glow pack and LED bib number before setting off on a lit 5 km route with music zones along the way. The event raises funds for local flood-relief and resilience efforts. A safety briefing is held before the start, reflective gear is recommended, and a warm supper waits at the finish line.',
 1, 2, '2027-02-13', '19:00:00', '21:30:00',
 'Liuzhou Sports Center', 'No. 1 Sports Road, Chengzhong District', 'Liuzhou',
 60.00, 45000.00, 3000.00, 'moonrun.jpg', 'active'),

(8, 'Spring Gala for Education',
 'A gala dinner and awards evening celebrating and funding education programmes for rural children.',
 'The Spring Gala for Education combines dinner, entertainment and an awards ceremony honouring outstanding volunteer tutors and students. Funds raised pay for school supplies, tutoring and digital learning equipment for rural classrooms around Liuzhou. The evening includes a raffle and a short documentary about the students and schools supported.',
 2, 1, '2027-03-20', '18:00:00', '21:30:00',
 'Liuzhou International Hotel Grand Ballroom', 'No. 55 Youyi Road', 'Liuzhou',
 350.00, 100000.00, 0.00, 'educationgala.jpg', 'active'),

-- Past events (dates before 2026-10-09; excluded from the Home page)
(9, 'Summer Charity Concert',
 'A summer afternoon concert that funded free summer camps for children.',
 'The Summer Charity Concert brought together local bands for an afternoon of music in the park, raising funds for free summer camps for children who would otherwise have no holiday programmes. The event included food stalls, family activities and a community sing-along.',
 4, 1, '2026-08-15', '16:00:00', '20:00:00',
 'Longtan Park Open Stage', 'No. 43 Longtan Road', 'Liuzhou',
 80.00, 50000.00, 52400.00, 'summerconcert.jpg', 'active'),

(10, 'Riverside Walk for Health',
 'A community walk that funded health check-ups for elderly residents.',
 'The Riverside Walk for Health was a morning community walk that raised funds for free health check-ups and blood-pressure monitoring for elderly residents in the riverside districts. More than 600 walkers took part and the fundraising goal was exceeded.',
 5, 2, '2026-09-12', '08:30:00', '10:30:00',
 'Liu River Riverside Park', 'No. 21 Riverside Avenue', 'Liuzhou',
 25.00, 20000.00, 21800.00, 'healthwalk.jpg', 'active'),

-- Suspended event (upcoming date but hidden from the public pages)
(11, 'Citywide Charity Raffle',
 'This event is suspended pending a policy review and is hidden from the public website.',
 'This raffle has been suspended by the administrator because it did not comply with the event-listing policy. Suspended events must not appear on the Home or Search pages while under review.',
 3, 2, '2026-11-07', '12:00:00', '16:00:00',
 'Yufeng Community Centre', 'No. 9 Yufeng Road', 'Liuzhou',
 20.00, 30000.00, 0.00, 'raffle.jpg', 'suspended');

-- =====================================================================
-- Verification (optional)
-- =====================================================================
SELECT 'organisations' AS table_name, COUNT(*) AS rows_count FROM organisations
UNION ALL
SELECT 'categories',   COUNT(*) FROM categories
UNION ALL
SELECT 'events',       COUNT(*) FROM events;
