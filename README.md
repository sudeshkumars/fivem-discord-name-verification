# FiveM Discord Name Verification

This is a simple FiveM server script that verifies whether a player's FiveM in-game name matches their Discord nickname before allowing them to join the server. It helps enforce consistent identity across Discord and your FiveM community.


<img width="1280" height="640" alt="Discord bots (1)" src="https://github.com/user-attachments/assets/ac6c6ad7-f216-4f65-aec2-dba71387865c" />


---
Contact me: 
Discord:dubbluu
Gmail:doubblu@proton.me


## 📌 Features

✅ Checks player’s FiveM name against their Discord nickname.  
✅ Supports bypass roles and users by Discord ID.  
✅ Sends connection logs to a Discord webhook.  
✅ Prevents players from joining if their names do not match.  
✅ Customizable and easy to integrate.

---

## ⚙️ Requirements

- A running FiveM (`fxserver`) server.
- A Discord Bot Token with **Guild Members** intent enabled.
- Your Discord server’s Guild ID.
- A Discord webhook URL for logs (optional but recommended).

---

## 🚀 Installation

1. **Download or Clone this Repository**


2. Put the resource folder in your FiveM resources directory.

3.Open your config.lua or server.lua and fill in:

local BotToken = "YOUR_BOT_TOKEN" [You can use txadmin bot]
local GuildId = "YOUR_GUILD_ID"
local webhookUrl = "YOUR_WEBHOOK_URL"

-- Bypass Roles (role IDs that can skip name check)
local bypassRoles = { "ROLE_ID_1", "ROLE_ID_2" }

-- Bypass Users (Discord IDs that can skip name check)
local bypassUsers = { "DISCORD_USER_ID_1" }
Start the Resource

4.Add this to your server.cfg:
5.Restart Your Server

📝How It Works
When a player connects, the script:

Gets their Discord ID.

Fetches their Discord nickname and roles via the Discord API.

Compares the normalized FiveM name with the normalized Discord nickname.

If they match, the player is allowed in.
If not, they are kicked with an explanation and a log is sent to Discord.

✅ Bypass Options
Add Discord Role IDs to bypassRoles if you want certain roles to skip verification.

Add Discord User IDs to bypassUsers if you want specific users to skip verification (e.g., admins).

📝Logging
All join attempts (approved, rejected, bypassed) are logged to your configured Discord webhook.

Logs include player name, IP endpoint, reason, and timestamp.

🛡️ License
This project is licensed under the MIT License.

Made with 💙 by Dubblu

