# Daily Market Brew - Setup & Installation Guide

## Overview
The Daily Market Brew agent aggregates market intelligence from WhatsApp groups and web sources via Firecrawl, delivering curated daily briefings.

**Setup Time:** ~15-20 minutes  
**Difficulty:** Intermediate  
**Requirements:** WhatsApp Business Account, Firecrawl API key, access to target groups

---

## Pre-Setup Checklist

Before starting, ensure you have:
- [ ] Access to WhatsApp groups you want to monitor
- [ ] WhatsApp Business Account (or access to one)
- [ ] Firecrawl account with active API key
- [ ] Admin/owner permissions for any business groups
- [ ] List of target websites for daily scraping
- [ ] Preferred daily briefing time (HH:MM timezone)

---

## Step 1: WhatsApp Integration Setup

### 1.1 Choose Your WhatsApp Connection Method

**Option A: WhatsApp Business API** (Recommended for organizations)
- Provides official API access
- Full automation capabilities
- Requires business account verification

**Option B: WhatsApp Web Automation** (For personal/small group use)
- Browser-based automation
- No official API required
- Limited to authenticated sessions

**Option C: Webhook Integration** (If already using WhatsApp Business Platform)
- Integrate with existing setup
- Fastest implementation

---

### What You'll Need to Provide:

```
WhatsApp Configuration
├── Connection Method: [A/B/C] _______________
├── WhatsApp Phone Number: +_________________
├── Business Account ID: _____________________
├── API Access Token: _________________________
│   └── Where to get: https://developers.facebook.com/docs/whatsapp/cloud-api/get-started
├── Target Groups to Monitor:
│   ├── Group Name 1: ________________________
│   │   └── Group ID: ________________________
│   ├── Group Name 2: ________________________
│   │   └── Group ID: ________________________
│   └── Group Name N: ________________________
│       └── Group ID: ________________________
└── Monitoring Settings:
    ├── Monitor All Messages: [Yes/No] _______
    ├── Monitor Only Keywords: [Yes/No] _____
    │   └── Keywords: ________________________
    └── Messages Per Day Limit: ______________
```

**How to find Group IDs:**
1. Open WhatsApp → Target Group → Group Info
2. Copy group JID (format: `123456789-1234567890@g.us`)
3. Paste in configuration above

---

## Step 2: Firecrawl Configuration

### What You'll Need:

```
Firecrawl Setup
├── Firecrawl API Key: ________________________
│   └── Get at: https://www.firecrawl.dev/app/api-keys
├── Daily Scraping Targets:
│   ├── Site Name: ___________________________
│   │   └── URL Pattern: ______________________
│   ├── Site Name: ___________________________
│   │   └── URL Pattern: ______________________
│   └── Site Name: ___________________________
│       └── URL Pattern: ______________________
├── Scraping Parameters:
│   ├── Include Images: [Yes/No] ______________
│   ├── Include Tables: [Yes/No] ______________
│   ├── Wait for JS Rendering: [Yes/No] ______
│   ├── Markdown Output: [Yes/No] _____________
│   └── Max Pages Per Site: ____________________
└── Rate Limiting:
    ├── Requests Per Minute: ___________________
    └── Concurrent Requests: ___________________
```

**Setup Instructions:**
1. Go to [firecrawl.dev](https://www.firecrawl.dev)
2. Create account / sign in
3. Navigate to API Keys section
4. Create new API key → Copy
5. Test API key in this prompt: `firecrawl_test_key_here`

---

## Step 3: Content Processing & Keywords

### Define Your Market Focus

```
Market Intelligence Parameters
├── Market Categories:
│   ├── Crypto/Bitcoin: [Yes/No] ______________
│   ├── Forex/Trading: [Yes/No] _______________
│   ├── Stocks/Equity: [Yes/No] _______________
│   ├── Commodities: [Yes/No] _________________
│   └── Other: ________________________________
├── Alert Keywords (automatic flagging):
│   └── Comma-separated: _______________________
│       Example: "bullish,earnings,IPO,merger,breakout"
├── Sentiment Analysis:
│   ├── Enable: [Yes/No] ______________________
│   └── Languages: [EN/ES/FR/etc] ______________
├── Content Deduplication:
│   ├── Enable: [Yes/No] ______________________
│   └── Similarity Threshold (0-1): ___________
└── Custom Tags/Categories:
    ├── Tag 1: ________________________________
    ├── Tag 2: ________________________________
    └── Tag N: ________________________________
```

---

## Step 4: Output & Delivery Configuration

### Where Should Briefings Go?

```
Briefing Delivery Settings
├── Primary Output Channel:
│   ├── Option 1: Email
│   │   └── Email Address(es): _________________
│   ├── Option 2: WhatsApp
│   │   └── Send To Phone/Group: ______________
│   ├── Option 3: Slack
│   │   └── Webhook URL: ______________________
│   ├── Option 4: Telegram
│   │   └── Bot Token & Chat ID: ______________
│   └── Option 5: Local File/DB
│       └── Storage Path: ______________________
├── Briefing Schedule:
│   ├── Frequency: [Daily/Weekly/Custom] _______
│   ├── Time (24h format): HH:MM _______________
│   ├── Timezone: [UTC/PST/EST/etc] ___________
│   └── Days of Week (if weekly): _____________
├── Briefing Format:
│   ├── Style: [Executive Summary/Detailed/Lists] ___
│   ├── Max Length: [Short/Medium/Long] _______
│   ├── Include Sources: [Yes/No] ______________
│   └── Include Timestamps: [Yes/No] __________
└── Additional Recipients:
    ├── Recipient 1: __________________________
    ├── Recipient 2: __________________________
    └── Recipient N: __________________________
```

---

## Step 5: Authentication & Security

### Secure Credential Storage

```
Security Configuration
├── Credential Storage Method:
│   ├── Option 1: Environment Variables (.env)
│   ├── Option 2: Claude Code Secrets Manager
│   ├── Option 3: Encrypted Config File
│   └── Selected: ______________________________
├── Required Environment Variables:
│   ├── WHATSAPP_API_TOKEN=_____________________
│   ├── WHATSAPP_PHONE_ID=______________________
│   ├── FIRECRAWL_API_KEY=______________________
│   ├── BRIEFING_EMAIL_PASSWORD=________________
│   └── OTHER_SERVICE_TOKEN=____________________
├── IP Whitelisting:
│   ├── Enable: [Yes/No] ______________________
│   └── Allowed IPs: ___________________________
└── Rate Limiting & Abuse Prevention:
    ├── Max API Calls/Hour: _____________________
    └── Error Notification Email: ______________
```

**⚠️ Security Best Practices:**
- Never commit credentials to git
- Use environment variables for sensitive data
- Rotate API keys quarterly
- Enable 2FA on all service accounts
- Monitor API usage for anomalies

---

## Step 6: Advanced Configuration (Optional)

### Performance & Customization

```
Advanced Settings
├── Caching:
│   ├── Enable Message Cache: [Yes/No] _______
│   ├── Cache TTL (hours): _____________________
│   └── Cache Backend: [Memory/Redis/SQLite] ___
├── AI Processing:
│   ├── AI Model for Summarization: ___________
│   ├── Summarization Style: [Bullet/Prose] ___
│   └── Temperature (0-1): _____________________
├── Data Retention:
│   ├── Keep Messages (days): ___________________
│   ├── Keep Scraped Content (days): ___________
│   └── Archive Strategy: [Delete/Archive] _____
├── Error Handling:
│   ├── Retry Failed Requests: [Yes/No] _______
│   ├── Max Retries: ____________________________
│   └── Fallback Behavior: _____________________
└── Logging:
    ├── Log Level: [DEBUG/INFO/WARN/ERROR] _____
    └── Log Destination: _______________________
```

---

## Step 7: Validation & Testing

### Pre-Launch Checklist

Run each test and confirm successful:

```
Test Suite
├── [ ] WhatsApp Connection Test
│   └── Command: `test_whatsapp_connection`
│   └── Expected: "Connected to X groups successfully"
├── [ ] Firecrawl API Test
│   └── Command: `test_firecrawl_api`
│   └── Expected: "API key valid, X sites accessible"
├── [ ] Message Parsing Test
│   └── Command: `test_message_parsing`
│   └── Expected: "Parsed X sample messages correctly"
├── [ ] Content Scraping Test
│   └── Command: `test_scraping`
│   └── Expected: "Successfully scraped and processed X pages"
├── [ ] Briefing Generation Test
│   └── Command: `generate_test_briefing`
│   └── Expected: "Sample briefing created successfully"
├── [ ] Delivery Test
│   └── Command: `send_test_briefing`
│   └── Expected: "Briefing delivered to all configured channels"
└── [ ] End-to-End Test
    └── Command: `run_full_pipeline_test`
    └── Expected: "Full cycle completed in < 5 minutes"
```

**Troubleshooting:**
- WhatsApp connection fails → Check API token and phone ID
- Firecrawl rate limited → Reduce concurrent requests
- Messages not parsing → Check keyword filtering settings
- Briefing not sending → Verify delivery configuration

---

## Step 8: Installation Script

### Automated Setup (Optional)

Run this command to auto-prompt for all settings:

```bash
claude code market-brew:setup --guided
```

Or use the interactive form below:

```yaml
# market-brew-config.yaml (auto-generated after setup)
whatsapp:
  api_token: "${WHATSAPP_API_TOKEN}"
  phone_id: "${WHATSAPP_PHONE_ID}"
  groups:
    - name: "Trading Signals"
      id: "123456789@g.us"
    - name: "Market News"
      id: "987654321@g.us"

firecrawl:
  api_key: "${FIRECRAWL_API_KEY}"
  targets:
    - name: "CoinMarketCap"
      url: "https://coinmarketcap.com/"
    - name: "Financial Times"
      url: "https://markets.ft.com/"

briefing:
  schedule: "0 8 * * *"  # 8 AM daily
  format: "executive_summary"
  delivery:
    - type: "email"
      address: "team@example.com"
    - type: "whatsapp"
      group: "123456789@g.us"

keywords:
  alert: ["bullish", "earnings", "breakout", "IPO"]
  ignore: ["spam", "test"]
```

---

## Step 9: Ongoing Maintenance

### Regular Tasks

```
Maintenance Schedule
├── Daily:
│   └── Monitor job logs for errors
├── Weekly:
│   └── Review briefing quality and relevance
│   └── Check API usage trends
├── Monthly:
│   ├── Update keyword lists
│   ├── Review group/site accessibility
│   ├── Audit delivery metrics
│   └── Clean up old cached data
├── Quarterly:
│   ├── Rotate API keys
│   ├── Review and update documentation
│   └── Performance optimization check
└── As-Needed:
    ├── Add/remove groups or scraping targets
    ├── Adjust keyword filters
    └── Update delivery recipients
```

---

## Support & Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| "WhatsApp API token invalid" | Regenerate token at [Meta App Dashboard](https://developers.facebook.com) |
| "Firecrawl rate limit exceeded" | Reduce concurrent requests or upgrade plan |
| "Messages not being captured" | Check group permissions and monitoring settings |
| "Briefings arriving late" | Verify timezone setting and Firecrawl processing time |
| "Duplicate content in briefing" | Enable deduplication (Step 3) |
| "Memory/CPU high" | Reduce cache TTL or max concurrent requests |

### Getting Help

- **Configuration Questions:** Review relevant section above
- **API Issues:** Check service status pages:
  - WhatsApp: https://status.meta.com
  - Firecrawl: https://status.firecrawl.dev
- **Custom Setup:** Contact: [your support email]

---

## Configuration File Template

Save this as `market-brew-config.json`:

```json
{
  "version": "1.0",
  "name": "My Market Brew Instance",
  "whatsapp": {
    "connectionMethod": "A",
    "phoneNumber": "+1234567890",
    "businessAccountId": "YOUR_BUSINESS_ID",
    "apiToken": "${WHATSAPP_API_TOKEN}",
    "groups": [
      {
        "name": "",
        "id": ""
      }
    ],
    "monitoringSettings": {
      "monitorAllMessages": true,
      "keywords": [],
      "messagesPerDayLimit": 1000
    }
  },
  "firecrawl": {
    "apiKey": "${FIRECRAWL_API_KEY}",
    "targets": [
      {
        "name": "",
        "url": "",
        "frequency": "daily"
      }
    ],
    "scraping": {
      "includeImages": false,
      "includeTables": true,
      "markdownOutput": true,
      "maxPagesPerSite": 10,
      "requestsPerMinute": 30,
      "concurrentRequests": 3
    }
  },
  "intelligence": {
    "categories": ["crypto", "forex", "stocks"],
    "alertKeywords": ["bullish", "earnings"],
    "sentimentAnalysis": true,
    "deduplication": true,
    "similarityThreshold": 0.85
  },
  "briefing": {
    "schedule": "0 8 * * *",
    "timezone": "UTC",
    "format": "executive_summary",
    "delivery": [
      {
        "type": "email",
        "recipient": ""
      }
    ]
  },
  "security": {
    "credentialStorage": "env_vars",
    "logLevel": "INFO"
  }
}
```

---

## Quick Start (5 minutes)

**If you just want to get started NOW:**

1. **Get API Keys:**
   ```
   WhatsApp API Token: _______________
   Firecrawl API Key: _______________
   ```

2. **Set Environment Variables:**
   ```bash
   export WHATSAPP_API_TOKEN="your_token"
   export FIRECRAWL_API_KEY="your_key"
   ```

3. **Run Setup Wizard:**
   ```bash
   claude code market-brew:quick-setup
   ```

4. **Test:**
   ```bash
   claude code market-brew:test-connection
   ```

5. **Deploy:**
   ```bash
   claude code market-brew:start
   ```

---

## Next Steps

After setup completion:
- [ ] Review first generated briefing
- [ ] Adjust keywords and filters based on results
- [ ] Fine-tune schedule and delivery settings
- [ ] Train team on how to use briefings
- [ ] Set up monitoring and alerts

---

**Setup Version:** 1.0  
**Last Updated:** 2026-07-31  
**Maintained By:** [Your Team]
