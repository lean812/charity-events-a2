# Charity Events Client-Side Website (PROG2002 Assessment 2)

The client-side website is built with **plain HTML, CSS and JavaScript** (the
DOM, `fetch` and Promises). It consumes the Charity Events REST API.

## Pages

| File          | Page              | Features |
|---------------|-------------------|----------|
| `index.html`  | Home              | Static organisation information and a dynamic list of active, upcoming events |
| `search.html` | Search Events     | Filter form (date, location, category), Clear Filters, validation and error messages |
| `event.html`  | Event Details     | Full event information, goal vs progress, and a Register button (modal) |

The same navigation menu appears on every page.

## How to run

1. Make sure the API is running (see the `api` project) on
   `http://localhost:3000`.
2. Because the pages call the API over HTTP, open them through a local web
   server rather than the `file://` protocol. From this `client` folder you can
   use any static server, for example:

   ```bash
   npx http-server -p 5500
   ```

   Then open `http://localhost:5500/index.html`.

3. If the API runs on a different host/port, update `js/config.js`.

## Project structure

```
client/
├── index.html
├── search.html
├── event.html
├── css/
│   └── style.css
└── js/
    ├── config.js    # API base URL
    ├── common.js    # fetch helper, formatting, cards, modal
    ├── home.js
    ├── search.js
    └── event.js
```
