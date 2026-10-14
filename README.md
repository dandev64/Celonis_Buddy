# Celonis Buddy

An AI assistant for the Celonis platform, powered by extracted Academy course content and official documentation.  
Built for Accenture colleagues who want quick, grounded answers without hunting through the Academy.

---

## What's in here

| Folder | Contents |
|--------|----------|
| `docs/courses/` | 36 Academy courses — full DEDA track + extras (~870 KB) |
| `docs/reference/` | 7 official Celonis docs pages (~730 KB) |
| `courses.json` | Manifest of all tracked content with source URLs |
| `CHANGELOG.md` | History of doc updates |
| `scripts/sync-to-github.ps1` | Push freshly-scraped docs to this repo |
| `claude-project-prompt.md` | Paste this into the Claude.ai Project instructions |

---

## Using the assistant (for colleagues)

1. Go to **claude.ai** → **Projects** → open **Celonis Buddy**
2. Ask anything about Celonis — PQL, Action Flows, Data Integration, Studio, etc.
3. The assistant answers from the docs in this repo, not from memory

**Example questions:**
- "How do PU functions work and when should I use them over a JOIN?"
- "What's the difference between a Knowledge Model and a View in Studio?"
- "Walk me through setting up an extractor for SAP"
- "How do I handle errors in Action Flows?"

---

## Setting up the Claude.ai Project (one-time, admin only)

> You need a **Claude.ai Pro or Team** plan to create Projects.

1. Go to **claude.ai** → **Projects** → **New Project**
2. Name it **Celonis Buddy**
3. Under **Project Instructions**, paste the contents of `claude-project-prompt.md` (everything after the horizontal rule)
4. Under **Project Knowledge**, click **Add content → GitHub** and connect this repo
   - Or upload the `docs/` folder contents manually if GitHub sync isn't available on your plan
5. Share the project with colleagues

---

## Updating the docs (for maintainers)

When Celonis updates course content or you want to add a new course:

### Step 1 — Scrape the updated course(s)

Open Claude Code and run the scraper skill:

```
/celonis-scrape https://academy.celonis.com/learn/course/<slug>
```

The scraped file lands in `C:\Users\<you>\Documents\Celonis training\`.  
Copy it to the matching path in `docs/courses/` or `docs/reference/` in this repo.

### Step 2 — Push to GitHub

```powershell
cd C:\Users\daniel.jan.p.medado\Documents\celonis-buddy
.\scripts\sync-to-github.ps1
```

The script will:
- Detect which files changed
- Append an entry to `CHANGELOG.md`
- Commit and push to `main`

GitHub Actions will then post a summary (and optionally notify Teams if you've set the webhook secret).

### Step 3 — Colleagues get it automatically

Claude.ai Projects with GitHub sync re-index on each push.  
If you uploaded docs manually, re-upload the changed files.

---

## Adding a new course

1. Scrape it with `/celonis-scrape <url>` → file appears in `Celonis training\`
2. Copy the file to `docs/courses/`
3. Add an entry to `courses.json` (copy an existing entry and update slug/url/file/id)
4. Run `.\scripts\sync-to-github.ps1`

---

## Scheduled automation (optional)

To have your machine re-scrape all courses automatically on a weekly schedule:

1. Open **Task Scheduler** → Create Basic Task
2. Trigger: Weekly, your preferred day
3. Action: Start a program
   - Program: `powershell.exe`
   - Arguments: `-NonInteractive -File "C:\Users\daniel.jan.p.medado\Documents\celonis-buddy\scripts\sync-to-github.ps1"`
4. Note: Edge must be open and logged into Celonis Academy when the task runs  
   (the scraper uses your existing browser session)

---

## Content coverage

Courses tracked: see `courses.json`  
Last update: see `CHANGELOG.md`  
Limitations: interactive quizzes, click-to-expand accordions, and video content are not captured.
