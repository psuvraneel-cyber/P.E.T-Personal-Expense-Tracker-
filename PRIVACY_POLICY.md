# Privacy Policy — Personal Expense Tracker (P.E.T)

**Last updated:** March 11, 2026

## Overview

Personal Expense Tracker ("P.E.T", "the App") is a personal finance management application. This privacy policy explains how the App handles your data.

## SMS Data Access

The App requests **READ_SMS** and **RECEIVE_SMS** permissions to automatically detect financial transactions from bank SMS messages. This is used solely for:

- Extracting transaction amounts, merchant names, and dates from bank alerts
- Categorising spending automatically
- Detecting recurring payments

### What we DO:

- **All SMS processing happens entirely on your device.** No SMS content is ever transmitted to external servers.
- Store only redacted transaction data (account numbers are masked, e.g., `XX****1234`)
- Allow you to delete any auto-detected transaction at any time

### What we DO NOT do:

- Read personal, promotional, or non-financial SMS messages
- Share, sell, or transmit raw SMS content to any third party
- Store the full, unredacted SMS body

## Data Storage

- **Local data** is stored in an on-device SQLite database
- **Cloud sync** (optional, via Google Sign-In) stores transaction metadata in Google Cloud Firestore, secured per-user with Firebase Authentication
- **AI Copilot** (optional) sends anonymised financial summaries to Groq's API for generating insights — no raw SMS data is included

## Third-Party Services

| Service | Purpose | Privacy Policy |
|---------|---------|----------------|
| Firebase Authentication | User sign-in | [Google Privacy Policy](https://policies.google.com/privacy) |
| Cloud Firestore | Cloud sync | [Google Cloud Terms](https://cloud.google.com/terms) |
| Groq API | AI financial insights | [Groq Privacy Policy](https://groq.com/privacy-policy/) |

## Data Deletion

You can delete all your data at any time by:
1. Signing out (clears local data)
2. Requesting account deletion via email (removes cloud data)

## Data Retention

Your data is retained until you choose to delete it. You may delete all data at any time by:
1. Signing out (clears local data)
2. Using the "Delete Account" option in Settings (removes all local and cloud data permanently)

There is no automatic data expiration — your records persist as long as you keep your account active.

## Contact

For questions about this privacy policy, contact:

**Email:** psuvraneel@gmail.com
