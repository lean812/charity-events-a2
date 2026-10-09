# Charity Events API (PROG2002 Assessment 2)

RESTful API built with **Node.js, Express and MySQL** that serves charity-event
data to the client-side website.

## Setup

1. Install [Node.js](https://nodejs.org) and [MySQL](https://dev.mysql.com/downloads/mysql/).
2. Create the database and sample data by running the SQL script in MySQL
   Workbench, or from the command line:

   ```bash
   mysql -u root -p < sql/charityevents_db.sql
   ```

3. Install dependencies:

   ```bash
   npm install
   ```

4. Copy `.env.example` to `.env` and enter your MySQL password:

   ```
   DB_USER=root
   DB_PASSWORD=your_mysql_password
   DB_NAME=charityevents_db
   ```

5. Start the server:

   ```bash
   npm start
   ```

   The API runs on `http://localhost:3000`.

## Endpoints

| Method | Endpoint            | Description                                              |
|--------|---------------------|----------------------------------------------------------|
| GET    | `/api/events`       | Active, upcoming events (Home page)                      |
| GET    | `/api/events?date=YYYY-MM-DD&location=Liuzhou&category_id=1` | Search/filter events |
| GET    | `/api/events/:id`   | Full details of one event                                |
| GET    | `/api/categories`   | All categories (used to populate the search filter)      |

Only **GET** endpoints are implemented in Assessment 2; create/update/delete
operations are added in Assessment 3.

## Project structure

```
api/
├── event_db.js          # MySQL connection pool & query helper
├── server.js            # Express application entry point
├── package.json
├── .env / .env.example
├── routes/
│   ├── events.js
│   └── categories.js
└── sql/
    └── charityevents_db.sql
```
