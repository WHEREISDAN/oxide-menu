# Installation Guide

Complete installation instructions for Oxide Menu.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Fresh Installation](#fresh-installation)
- [Migration from qb-menu](#migration-from-qb-menu)
- [Verification](#verification)
- [Next Steps](#next-steps)

---

## Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| FiveM Server | Latest | Recommended: Latest artifacts |
| QBCore Framework | Latest | Required dependency |
| qb-inventory | Any | Optional: For item icon resolution |

---

## Fresh Installation

### Step 1: Download

Download the oxide-menu resource and extract it to your resources folder.

```
resources/
└── [nulldev]/
    └── oxide-menu/
        ├── fxmanifest.lua
        ├── config.lua
        ├── client/
        │   └── main.lua
        └── html/
            ├── index.html
            └── css/
                ├── variables.css
                ├── animations.css
                └── main.css
```

### Step 2: Server Configuration

Add the resource to your `server.cfg`:

```cfg
# After qb-core
ensure qb-core

# Oxide Menu
ensure oxide-menu
```

### Step 3: Remove qb-menu

If you're replacing qb-menu, disable or remove it:

```cfg
# Comment out or remove
# ensure qb-menu
```

> **Important:** Oxide Menu supports the qb-menu data format. You must update export names from `'qb-menu'` to `'oxide-menu'` in your scripts, but the menu data structure stays the same.

### Step 4: Configure

Edit `config.lua` to customize the menu behavior:

```lua
Config.Theme = 'oxide'      -- Visual theme
Config.Position = 'right'   -- Default position
Config.Debug = false        -- Set true to enable demo commands
```

See [CONFIGURATION.md](CONFIGURATION.md) for all options.

### Step 5: Restart

Restart your server or use:

```
refresh
ensure oxide-menu
```

---

## Migration from qb-menu

Oxide Menu supports the qb-menu data format with a simple export name change.

### Step 1: Backup

Always backup before making changes:
- Export your current resource folder
- Note any custom modifications to qb-menu

### Step 2: Replace Resource

1. Remove or rename your existing `qb-menu` folder
2. Add `oxide-menu` to your resources
3. Update `server.cfg`:

```cfg
# Replace this:
# ensure qb-menu

# With this:
ensure oxide-menu
```

### Step 3: Update Export Names

Find and replace in all scripts that use qb-menu:

```lua
-- Change this:
exports['qb-menu']:openMenu(...)
exports['qb-menu']:closeMenu()
exports['qb-menu']:showHeader(...)

-- To this:
exports['oxide-menu']:openMenu(...)
exports['oxide-menu']:closeMenu()
exports['oxide-menu']:showHeader(...)
```

The menu data you pass to these functions stays the same.

The legacy event still fires for compatibility:

```lua
AddEventHandler('qb-menu:client:menuClosed', function()
    -- Still triggers
end)
```

### Step 4: Verify

Test your existing menus to ensure they display correctly. See [Verification](#verification) below.

---

## Verification

### Check Resource Started

In server console or F8:

```
ensure oxide-menu
```

If debug mode is enabled (`Config.Debug = true`), you'll see:
```
[oxide-menu] Debug mode enabled - Demo commands: /oxidemenu through /oxidemenu11
```

If no message appears, the resource is running in production mode (normal).

### Test Demo Commands

Enable debug mode temporarily:

```lua
Config.Debug = true
```

Then test in-game:

```
/oxidemenu    -- Should show character options menu
/oxidemenu3   -- Should show interactive elements
```

### Test Existing Scripts

After updating the export names, open any menu from your scripts. They should display with the new Oxide Menu styling.

---

## Troubleshooting Installation

| Issue | Solution |
|-------|----------|
| Menu doesn't appear | Check F8 console for errors. Ensure resource started. |
| NUI errors | Clear FiveM cache: `%localappdata%/FiveM/FiveM.app/data/cache` |
| Exports not found | Ensure oxide-menu starts after qb-core in server.cfg |
| Styling broken | Verify all CSS files exist in `html/css/` folder |

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more solutions.

---

## Next Steps

- [Configure the menu](CONFIGURATION.md) - Customize theme, position, and behavior
- [Learn the API](EXPORTS.md) - Use modern or legacy exports
- [Customize the UI](CUSTOMIZATION.md) - Modify colors and styling
- [Explore features](FEATURES.md) - Discover all capabilities

---

*Oxide Menu - Modern menus for QBCore*
