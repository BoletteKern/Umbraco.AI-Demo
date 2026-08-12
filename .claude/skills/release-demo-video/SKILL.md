---
name: release-demo-video
description: Checks the latest GitHub releases of Umbraco.AI and Umbraco.Automate for a headline new feature, checks whether a demo video for it already exists in the team's Slack channel, and if not, boots this repo's Umbraco instance, explores the feature with Playwright, records a clean demo, and posts it to Slack. Use whenever the user asks to make/check a release demo video, asks "do we have a video for the new [Automate|AI] feature yet", or wants the latest Umbraco.AI/Automate release demonstrated and shared with the team.
---

# Release demo video

Required input: **`SLACK_CHANNEL_ID`** — the destination channel. If not given when this
skill is invoked, ask for it before doing anything else; don't guess a channel.

Run the following once per product, `Umbraco.AI` and `Umbraco.Automate` (they release and
ship features independently, so treat them as two separate passes through this checklist).

## 1. Find the latest release

Fetch `https://github.com/umbraco/<Product>/releases` and read the top release's notes.
That's your "latest feature" for this pass — pick the single most demoable thing it adds
(not every bullet point; if the release is all bugfixes, say so and stop, there's nothing to
demo).

## 2. Check if it's already covered

Search Slack for an existing video of this feature before doing any work:

```
slack_search_public_and_private query="<feature name> <version>" content_types="files"
  channel_types=... (scope to SLACK_CHANNEL_ID via `in:`)
```

If a video already covering this release/feature is there, stop — nothing to do. Report
what you found instead of re-recording it.

## 3. Explore the feature (unrecorded)

Boot the site: `./refresh.sh` then `dotnet run` from the repo root (see `CLAUDE.md`).

Set up the Playwright project once if `e2e/node_modules` doesn't exist yet: `cd e2e && npm
install`. It's a minimal project (`package.json` + `playwright.config.js` already in this
skill's `e2e/` folder) built around
[`@umbraco-cms/acceptance-test-helpers`](https://www.npmjs.com/package/@umbraco-cms/acceptance-test-helpers)
— use its builders/helpers to log into the backoffice and drive it, rather than hand-rolling
selectors.

Poke around the backoffice for real, without recording, until you understand: where the
feature lives, what state the demo content needs to be in to show it off well, and the
shortest sequence of clicks that demonstrates it clearly. Release notes tell you *what*
shipped, not *where to click* — you have to find that yourself.

## 4. Record a clean pass

Once you know the walkthrough, re-run it in a Playwright context with `recordVideo` enabled
(see Playwright's [video docs](https://playwright.dev/docs/videos) — set
`recordVideo: { dir: 'videos/' }` on `browser.newContext()`). This second pass should be
deliberate and demo-quality: no dead ends, no fixing typos on camera. Keep it short — long
enough to show the feature working, not a full tour.

## 5. Post it

Upload the resulting video file to Google Drive
(`mcp__claude_ai_Google_Drive__create_file`, `base64Content` + matching
`contentMimeType`), then post the link to `SLACK_CHANNEL_ID` with
`slack_send_message` — name the product, version, and feature in the message so
whoever reads it later doesn't have to open the video to know what it's for.

**Known gap:** the Drive upload tool doesn't expose a way to set sharing permissions, so the
file may come out private to the uploading account. Mention this in the Slack message if
you can't confirm the link is viewable — better than posting a dead link silently.
