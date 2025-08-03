
# WhatsApp‑Driven Google Drive Assistant (n8n Workflow)

*Task 2 submission for the Internship challenge – deadline 10 Aug 2025*

---

## 📚 Overview
This repository contains a ready‑to‑import **n8n** workflow that turns a WhatsApp chat into a Google Drive file manager. Through simple slash‑style commands you can **list, move, delete or summarise** Drive items without leaving WhatsApp.

Key components:

| Layer | Tech |
|-------|------|
| Inbound channel | Twilio **WhatsApp Sandbox** |
| Orchestration | **n8n** low‑code workflow engine |
| Cloud storage | **Google Drive** (OAuth 2.0) |
| AI summary | **OpenAI GPT‑4o** |
| Deployment | `docker‑compose` (single‑container) |

## 💡 Features
- `list <folder>` – show files inside a Drive folder.  
- `summarize <folder>/<file>` – GPT‑4o bullet digest of each doc (PDF / DOCX / TXT).  
- `move <srcFolder>/<file> <destFolder>` – relocate a file.  
- `delete <folder>` or `delete <folder>/<file>` – soft‑delete (moves to Trash).  
- Automatic confirmation guard against mass deletes.  
- Every action is logged to an *Audit* Google Sheet for traceability.

## 🚀 Quick‑start

### 1 . Clone & prepare env
```bash
git clone https://github.com/your‑handle/task2-drive-assistant.git
cd task2-drive-assistant

cp .env.sample .env           # fill in the blanks ✍️
```

### 2 . Twilio WhatsApp Sandbox
1. Create a free Twilio account.  
2. Activate the **WhatsApp Sandbox** and note the *Sandbox number* and *join code*.
3. Set the Sandbox **incoming webhook URL** to  
   `https://<your‑public‑url>/webhook/whatsapp` – when running locally expose n8n with [`cloudflared`](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/) or `ngrok`.

### 3 . Google Drive OAuth 2.0
1. In Google Cloud Console create an **OAuth Client ID → Web application**.  
2. Add an authorised redirect URI:  
   `http://localhost:5678/rest/oauth2-credential/callback`  
3. Paste the *Client ID* & *Secret* into `.env`, run the stack, then **Create new credential → Google Drive OAuth2** inside n8n and complete the consent flow.

### 4 . OpenAI key
Generate an API key from https://platform.openai.com/ → add it to `.env`.

### 5 . Run with Docker
```bash
docker-compose up -d
# or ./scripts/start.sh
```

Open http://localhost:5678 → *Workflows → Import* and pick `workflows/task2_whatsapp_drive_assistant.json`.

### 6 . Link Twilio ↔️ n8n
Copy the **Production URL** shown under *Webhook1* node → set it as the **WHEN A MESSAGE COMES IN** URL in Twilio Sandbox settings.

Done! Send e.g. `list Notes` to your Sandbox chat.

## 🛠️ Repo layout
```
.
├── workflows/
│   └── task2_whatsapp_drive_assistant.json
├── scripts/
│   └── start.sh
├── docker-compose.yml
├── .env.sample
└── README.md
```

## 📝 Command grammar
| Command | Arguments | Example |
|---------|-----------|---------|
| `list` | `<folder>` | `list ProjectX` |
| `delete` | `<folder>` or `<folder>/<file>` | `delete Reports/2024.pdf` |
| `move` | `<srcFolder>/<file> <destFolder>` | `move Reports/2024.pdf Archive` |
| `summarize` | `<folder>` or `<file>` | `summarize MeetingNotes` |

> **Note:** Commands are case‑insensitive; extra whitespace is ignored.


## 🙅‍♀️ Known limitations
- Binary formats other than PDF/DOCX/TXT are skipped in summaries.
- Large folders (>10 MB cumulative) may exceed Twilio message limits – they are chunked automatically.

## 🧪 Extending
The workflow is organised with **node groups & comments** for clarity. Add new verbs by duplicating the **Switch** branch and following existing patterns.

## 🚑 Troubleshooting
| Symptom | Fix |
|---------|-----|
| Twilio 404 | Make sure the *Webhook1* URL is reachable from the internet (use ngrok / cloudflared). |
| `insufficientPermissions` from Drive | Re‑authorize the Google credential with appropriate scopes (`drive`, `drive.readonly`). |
| Empty summaries | Check OpenAI usage quota and key in `.env`. |

## 📜 Licence
MIT
