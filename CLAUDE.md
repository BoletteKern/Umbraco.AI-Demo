# Umbraco.AI-Demo

## What this project is

A demo Umbraco CMS site (Umbraco 18, .NET 10) used to explore the **Umbraco.AI** plugin
family without cloning or building any of that plugin's source. Every Umbraco.AI /
Umbraco.Automate capability is pulled in as a prebuilt NuGet package, so the whole point of
this repo is: change a version number, restore, run — never `git clone` a plugin repo.

The site itself is a standard "Clean" themed content site (blog, authors, pages) that
exists mainly as a host to exercise the AI plugins in a real backoffice:

- **Umbraco.AI** — core AI integration for Umbraco (`Umbraco.AI.Startup`,
  `Umbraco.AI.Web.StaticAssets`)
- Provider connectors: `Umbraco.AI.OpenAI`, `Umbraco.AI.Anthropic`, `Umbraco.AI.Google`,
  `Umbraco.AI.Amazon`, `Umbraco.AI.MicrosoftFoundry`
- **Umbraco.AI.Prompt** — prompt management (`Umbraco.AI.Prompt.Startup` /
  `.Web.StaticAssets`)
- **Umbraco.AI.Agent** — agent framework, UI, and Copilot experience
  (`Umbraco.AI.Agent.Startup` / `.Web.StaticAssets` / `.UI` / `.Copilot`)
- **Umbraco.AI.Automate** + **Umbraco.Automate** — lets AI trigger/interact with Umbraco's
  standalone workflow-automation product

## Dependency strategy: nightly feed, floating within major 18

`NuGet.config` maps every `Umbraco.AI*` and `Umbraco.Automate*` package to the **Umbraco
Nightly** MyGet feed (`https://www.myget.org/F/umbraconightly/api/v3/index.json`); everything
else (Umbraco.Cms, Clean theme, ICU runtime) comes from nuget.org as normal.

Those nightly-sourced packages are version-pinned as `18.*-*` in the `.csproj` — NuGet's
floating syntax that always resolves to the single highest published version whose major is
`18`, prerelease or not. That's a deliberate choice for this repo's purpose (explore
whatever's newest for major 18, no manual version bumping) — see below for the risk that
comes with it.

`Umbraco.Cms` / `Umbraco.Cms.DevelopmentMode.Backoffice` / `Clean` stay **pinned to exact
stable versions** (currently `18.1.0` / `18.1.0` / `8.0.1`) — bumping the CMS itself is a
deliberate, tested action, not something to float silently.

### Getting the latest nightly build

NuGet only re-resolves a floating version on an actual restore — `dotnet build` /
`dotnet run` alone will reuse whatever's already sitting in `obj/project.assets.json` and
won't hit the feed again. Run:

```bash
./refresh.sh
```

which clears `obj`/`bin`, restores (forcing a fresh resolve of every `18.*-*` reference),
and builds. If it fails, that's the fresh nightly build breaking, not stale cache — check
the `dotnet build` output for which package's version changed.

### The tradeoff

The nightly feed publishes **every commit** as a new prerelease build. Unlike a released,
non-prerelease version (which real semver protects from breaking API changes within a
major), a nightly prerelease build can legitimately break something the day before it
would have shipped stable. If `dotnet build` or the site's first boot after a restore
starts throwing, that's the expected failure mode of this setup — check what changed
upstream, not what changed here.

## Known v17→v18 gotchas already hit in this codebase

`IPublishedContent.Children` and `.Parent` became method-only in Umbraco 18 (no longer
usable as properties) — e.g. `homePage.Children()`, not `homePage.Children`. If a Razor
view fails to compile with `error CS0119: '...Children(...)' is a method, which is not
valid in the given context` (or the same for `Parent`), that's this — add the `()`.

## Running Umbraco.Automate

Umbraco.Automate needs its own connection string. Rather than a second database, this
site reuses the CMS's SQLite DB via `appsettings.json`:

```json
"Umbraco": { "Automate": { "UseNamedConnectionString": "umbracoDbDSN" } }
```

## Local dev

- Unattended install/upgrade is on (`appsettings.Development.json`), SQLite at
  `umbraco/Data/Umbraco.sqlite.db`.
- Backoffice: `/umbraco/` — `admin@example.com` / `password1234` (unattended install
  credentials, dev only).

## This is a download-and-run demo — commit the runtime state

Unlike a normal Umbraco project, this repo commits the things a `.gitignore` would usually
strip, specifically so `git clone && dotnet run` gives a fully working site with content
and media already in place — no install wizard, no empty database:

- **`umbraco/Data/Umbraco.sqlite.db`** is tracked. Its `-shm`/`-wal` companions stay
  gitignored (they're transient while the DB is open; a clean shutdown merges them into
  the main file, which is what's committed).
- **`wwwroot/media/`** is tracked (uploaded media referenced by the demo content).
- **`appsettings.json`** is tracked, including values Umbraco writes into it at runtime
  (e.g. the `Umbraco:CMS:Imaging:HMACSecretKey` it generates on first boot). When Umbraco
  adds a new config section to this file, commit it — that's expected, not a stray diff to
  discard.
- Still gitignored: `/umbraco/Data/TEMP/` (Examine/NuCache — rebuilt automatically),
  `/umbraco/Data/CreatedPackages/`, `/umbraco/Logs/` — genuinely derived/rebuildable, no
  reason to ship them.

If you change content or config through the backoffice, run `git status` afterwards —
`umbraco/Data/Umbraco.sqlite.db` and `appsettings.json` are the two files most likely to
have picked up something worth committing.
