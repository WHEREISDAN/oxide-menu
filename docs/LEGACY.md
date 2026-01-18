# Legacy Compatibility Guide

Documentation for migrating from qb-menu to oxide-menu.

---

## Table of Contents

- [Overview](#overview)
- [Migration Requirements](#migration-requirements)
- [Legacy Exports](#legacy-exports)
- [Legacy Item Format](#legacy-item-format)
- [Legacy Events](#legacy-events)
- [Format Transformation](#format-transformation)
- [Action Functions](#action-functions)
- [Migration Tips](#migration-tips)
- [Compatibility Matrix](#compatibility-matrix)

---

## Overview

Oxide Menu supports the **legacy qb-menu data format**. This means you can use the same menu structure (headers, items, params) but you must update the export name.

### What's Compatible

1. Legacy data format (`header`, `txt`, `params`, etc.) works as-is
2. Legacy exports (`openMenu`, `closeMenu`, `showHeader`) use the same function signatures
3. Legacy events (`qb-menu:client:menuClosed`) still fire
4. Action functions are preserved and executed correctly

### What Must Change

You must change the export name from `'qb-menu'` to `'oxide-menu'` in your scripts.

---

## Migration Requirements

### Step 1: Update server.cfg

```cfg
# server.cfg
# ensure qb-menu    -- Remove or comment out
ensure oxide-menu   -- Add this
```

### Step 2: Update Export Names

Find and replace in your scripts:

```lua
-- Before
exports['qb-menu']:openMenu(...)
exports['qb-menu']:closeMenu()

-- After
exports['oxide-menu']:openMenu(...)
exports['oxide-menu']:closeMenu()
```

The menu data structure remains the same - only the export name changes.

---

## Legacy Exports

These exports accept the same parameters as qb-menu:

### openMenu

```lua
exports['oxide-menu']:openMenu(menuData, sort, skipFirst)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| menuData | table | Array of menu items |
| sort | boolean | Sort items alphabetically |
| skipFirst | boolean | Skip first item when sorting (preserve header) |

### closeMenu

```lua
exports['oxide-menu']:closeMenu()
```

### showHeader

Alias for `openMenu`:

```lua
exports['oxide-menu']:showHeader(menuData)
```

---

## Legacy Item Format

The legacy qb-menu item format is fully supported:

### Menu Header

```lua
{
    header = 'Menu Title',
    isMenuHeader = true,
}
```

### Standard Item

```lua
{
    header = 'Item Label',
    txt = 'Description text',
    icon = 'fas fa-icon',
    disabled = false,
    hidden = false,
}
```

### Item with Client Event

```lua
{
    header = 'Client Action',
    txt = 'Triggers client event',
    icon = 'fas fa-bolt',
    params = {
        event = 'my:clientEvent',
        args = { key = 'value' }
    }
}
```

### Item with Server Event

```lua
{
    header = 'Server Action',
    txt = 'Triggers server event',
    icon = 'fas fa-server',
    params = {
        isServer = true,
        event = 'my:serverEvent',
        args = { key = 'value' }
    }
}
```

### Item with Command

```lua
{
    header = 'Execute Command',
    txt = 'Runs a command',
    icon = 'fas fa-terminal',
    params = {
        isCommand = true,
        event = 'mycommand'
    }
}
```

### Item with QBCore Command

```lua
{
    header = 'QBCore Command',
    txt = 'Runs QBCore command',
    icon = 'fas fa-terminal',
    params = {
        isQBCommand = true,
        event = 'giveitem',
        args = { item = 'water', amount = 1 }
    }
}
```

### Item with Action Function

```lua
{
    header = 'Direct Action',
    txt = 'Calls a function',
    icon = 'fas fa-play',
    params = {
        isAction = true,
        event = function(args)
            print('Action called with:', json.encode(args))
        end,
        args = { custom = 'data' }
    }
}

-- Or simpler syntax:
{
    header = 'Simple Action',
    action = function()
        print('Action called!')
    end
}
```

### Item with Persist (Keep Menu Open)

```lua
-- Item-level persist
{
    header = 'Buy Water',
    txt = 'Menu stays open',
    icon = 'fas fa-tint',
    persist = true,  -- Keep menu open after selection
    params = {
        isServer = true,
        event = 'shop:buyItem',
        args = { item = 'water' }
    }
}

-- Or persist in params
{
    header = 'Buy Bread',
    txt = 'Menu stays open',
    params = {
        isServer = true,
        event = 'shop:buyItem',
        args = { item = 'bread' },
        persist = true  -- Also works here
    }
}
```

---

## Legacy Events

### qb-menu:client:menuClosed

This event fires when a menu opened with the legacy API is closed:

```lua
AddEventHandler('qb-menu:client:menuClosed', function()
    print('Menu was closed')
end)
```

> **Note:** The modern event `oxide-menu:client:closed` also fires for all menus.

---

## Format Transformation

When you use `openMenu`, items are transformed to the modern format internally.

### Transformation Rules

| Legacy Property | Modern Property |
|-----------------|-----------------|
| `header` | `label` |
| `txt` | `description` |
| `text` | `description` |
| `isMenuHeader` | `isHeader` |
| `icon` | `icon` |
| `disabled` | `disabled` |
| `hidden` | `hidden` |
| `persist` | `persist` |
| `params.event` | `event` or `serverEvent` |
| `params.args` | `args` |
| `params.isServer` | Uses `serverEvent` |
| `params.isCommand` | Uses `command` |
| `params.isQBCommand` | Uses `qbCommand` |
| `params.isAction` | Stored in action lookup |
| `params.persist` | `persist` |
| `action` (function) | Stored in action lookup |

### Example Transformation

**Input (Legacy):**
```lua
{
    header = 'Buy Item',
    txt = 'Purchase this item for $50',
    icon = 'fas fa-shopping-cart',
    params = {
        isServer = true,
        event = 'shop:buyItem',
        args = { item = 'water', price = 50 }
    }
}
```

**Internal (Modern):**
```lua
{
    label = 'Buy Item',
    description = 'Purchase this item for $50',
    icon = 'fas fa-shopping-cart',
    serverEvent = 'shop:buyItem',
    args = { item = 'water', price = 50 },
    _legacyIndex = 2
}
```

---

## Action Functions

Functions can't be sent to the NUI (browser), so Oxide Menu handles them specially.

### How Actions Work

1. When transforming legacy items, functions are stored in a Lua table
2. The item gets a `_hasAction = true` flag and `_legacyIndex`
3. When selected, the Lua callback retrieves and executes the function
4. The function table is cleared when the menu closes

### Supported Action Patterns

```lua
-- Pattern 1: Direct action property
{
    header = 'Do Something',
    action = function()
        print('Hello!')
    end
}

-- Pattern 2: Action in params with isAction
{
    header = 'Do Something',
    params = {
        isAction = true,
        event = function(args)
            print('Args:', json.encode(args))
        end,
        args = { foo = 'bar' }
    }
}
```

---

## Migration Tips

After changing export names, consider migrating to the modern API for additional features.

### Why Migrate?

| Feature | Legacy API | Modern API |
|---------|------------|------------|
| Checkboxes | No | Yes |
| Sliders | No | Yes |
| Text inputs | No | Yes |
| onSelect callback | No | Yes |
| onClose callback | No | Yes |
| Menu ID tracking | No | Yes |
| Submenus (registered) | No | Yes |

### Gradual Migration

You can use both APIs simultaneously:

```lua
-- Old code still works
exports['oxide-menu']:openMenu({
    { header = 'Old Menu', isMenuHeader = true },
    { header = 'Option 1', params = { event = 'old:event' } },
})

-- New code uses modern API
exports['oxide-menu']:open({
    id = 'new-menu',
    title = 'New Menu',
    items = {
        { label = 'Option 1', event = 'new:event' },
        { type = 'checkbox', label = 'Toggle', checked = false },
    },
    onSelect = function(item, index)
        print('Selected:', item.label)
    end
})
```

### Quick Conversion Guide

**Legacy:**
```lua
exports['oxide-menu']:openMenu({
    {
        header = 'Shop',
        isMenuHeader = true,
    },
    {
        header = 'Buy Water',
        txt = '$5',
        icon = 'fas fa-tint',
        params = {
            isServer = true,
            event = 'shop:buy',
            args = { item = 'water' }
        }
    }
})
```

**Modern:**
```lua
exports['oxide-menu']:open({
    title = 'Shop',
    items = {
        {
            label = 'Buy Water',
            description = '$5',
            icon = 'fas fa-tint',
            serverEvent = 'shop:buy',
            args = { item = 'water' }
        }
    }
})
```

---

## Compatibility Matrix

| qb-menu Feature | Oxide Menu Support |
|-----------------|-------------------|
| `openMenu()` | Full |
| `closeMenu()` | Full |
| `showHeader()` | Full |
| `header` property | Full |
| `txt` property | Full |
| `isMenuHeader` | Full |
| `icon` | Full (enhanced) |
| `disabled` | Full |
| `hidden` | Full |
| `persist` | Full (new feature) |
| `params.event` | Full |
| `params.isServer` | Full |
| `params.isCommand` | Full |
| `params.isQBCommand` | Full |
| `params.isAction` | Full |
| `params.persist` | Full (new feature) |
| `action` function | Full |
| `params.args` | Full |
| Sort functionality | Full |
| `qb-menu:client:menuClosed` | Full |

### Known Differences

1. **Visual Styling**: Oxide Menu has a modern semi-transparent UI
2. **Animations**: Menus animate in/out (configurable via `Config.Animation`)
3. **Search**: Menus show a search bar (configurable via `Config.Search`)
4. **Keyboard**: Arrow key navigation (configurable via `Config.Keyboard.enabled`)

These are additive features that don't break existing functionality. All can be configured or disabled in `config.lua`.

---

## Troubleshooting Legacy Issues

### Menu doesn't appear

Check if the legacy format is correct. The first item should typically be a header:

```lua
{
    header = 'Menu Title',
    isMenuHeader = true,  -- Required for header
}
```

### Events not firing

Ensure your event names are correct and the receiving handlers are registered:

```lua
-- Client event handler
AddEventHandler('my:clientEvent', function(args)
    print('Received:', json.encode(args))
end)

-- Server event handler
RegisterNetEvent('my:serverEvent', function(args)
    print('Received:', json.encode(args))
end)
```

### Action functions not working

Make sure the function is defined correctly:

```lua
-- Correct
action = function()
    print('Works!')
end

-- Incorrect (passing a string)
action = 'functionName'
```

### Running alongside qb-menu

Running both resources simultaneously is not recommended as they serve the same purpose. Choose one and migrate fully.

---

*Oxide Menu - Modern menus for QBCore*
