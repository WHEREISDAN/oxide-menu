# Exports & API Reference

Complete API documentation for Oxide Menu.

---

## Table of Contents

- [Overview](#overview)
- [Modern API](#modern-api)
  - [open](#open)
  - [close](#close)
  - [isOpen](#isopen)
  - [register](#register)
  - [update](#update)
  - [updateItem](#updateitem)
  - [refresh](#refresh)
- [Legacy API](#legacy-api)
  - [openMenu](#openmenu)
  - [closeMenu](#closemenu)
  - [showHeader](#showheader)
- [Menu Data Structure](#menu-data-structure)
- [Item Types](#item-types)
- [Client Events](#client-events)
- [Integration Examples](#integration-examples)

---

## Overview

Oxide Menu provides two APIs:

1. **Modern API** - New, feature-rich API with callbacks and more options
2. **Legacy API** - Supports qb-menu data format for easier migration

Both APIs can be used simultaneously. The legacy API internally converts to modern format.

> **Note:** All exports use `'oxide-menu'` as the resource name, not `'qb-menu'`.

---

## Modern API

### open

Opens a menu with the specified configuration.

```lua
exports['oxide-menu']:open(menuData)
```

#### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| menuData | table | Yes | Menu configuration table |

#### Menu Data Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| id | string | nil | Unique menu identifier |
| title | string | nil | Menu header title |
| subtitle | string | nil | Subtitle below title |
| position | string | Config.Position | 'left', 'center', 'right' |
| searchable | boolean | true | Enable search bar |
| persist | boolean | nil | Keep menu open after item selection |
| items | table | {} | Array of menu items |
| onSelect | function | nil | Callback when item selected |
| onClose | function | nil | Callback when menu closed |
| onRefresh | function | nil | Callback to rebuild items after selection (persist menus) |

#### Returns

| Type | Description |
|------|-------------|
| boolean | true if menu opened successfully |

#### Example

```lua
exports['oxide-menu']:open({
    id = 'vehicle-menu',
    title = 'Vehicle Options',
    subtitle = 'Manage your vehicle',
    position = 'right',
    items = {
        { label = 'Lock/Unlock', icon = 'fas fa-lock', event = 'vehicle:toggleLock' },
        { label = 'Engine', icon = 'fas fa-power-off', event = 'vehicle:toggleEngine' },
        { type = 'divider' },
        { label = 'Trunk', icon = 'fas fa-box-open', event = 'vehicle:openTrunk' },
    },
    onSelect = function(item, index)
        print('Selected item:', item.label, 'at index:', index)
    end,
    onClose = function()
        print('Vehicle menu closed')
    end
})
```

---

### close

Closes the currently open menu or a specific menu by ID.

```lua
exports['oxide-menu']:close(menuId)
```

#### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| menuId | string | No | Optional menu ID to close |

#### Example

```lua
-- Close any open menu
exports['oxide-menu']:close()

-- Close specific menu
exports['oxide-menu']:close('vehicle-menu')
```

---

### isOpen

Checks if a menu is currently open.

```lua
local open = exports['oxide-menu']:isOpen(menuId)
```

#### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| menuId | string | No | Optional menu ID to check |

#### Returns

| Type | Description |
|------|-------------|
| boolean | true if menu (or specific menu) is open |

#### Example

```lua
-- Check if any menu is open
if exports['oxide-menu']:isOpen() then
    print('A menu is currently open')
end

-- Check specific menu
if exports['oxide-menu']:isOpen('vehicle-menu') then
    print('Vehicle menu is open')
end
```

---

### register

Pre-registers a menu for later use with submenu references.

```lua
exports['oxide-menu']:register(menuId, menuData)
```

#### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| menuId | string | Yes | Unique menu identifier |
| menuData | table | Yes | Menu configuration table |

#### Returns

| Type | Description |
|------|-------------|
| boolean | true if registered successfully |

#### Example

```lua
-- Register a submenu
exports['oxide-menu']:register('settings-audio', {
    title = 'Audio Settings',
    items = {
        { type = 'slider', label = 'Master Volume', min = 0, max = 100, value = 80 },
        { type = 'slider', label = 'Music', min = 0, max = 100, value = 50 },
        { type = 'slider', label = 'SFX', min = 0, max = 100, value = 70 },
    }
})

-- Main menu with submenu reference
exports['oxide-menu']:open({
    title = 'Settings',
    items = {
        { label = 'Audio', icon = 'fas fa-volume-up', submenu = 'settings-audio' },
        { label = 'Video', icon = 'fas fa-tv', submenu = 'settings-video' },
    }
})
```

---

### update

Updates the currently open menu with new data. Useful for refreshing items after state changes.

```lua
exports['oxide-menu']:update(data)
```

#### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| data | table | Yes | Update data (items, title, subtitle) |

#### Update Data Properties

| Property | Type | Description |
|----------|------|-------------|
| items | table | New items array (replaces all items) |
| title | string | New menu title |
| subtitle | string | New menu subtitle |

#### Returns

| Type | Description |
|------|-------------|
| boolean | true if update was successful |

#### Example

```lua
-- Update all items
exports['oxide-menu']:update({
    items = {
        { label = 'Water', description = 'Stock: 3' },
        { label = 'Bread', description = 'SOLD OUT', disabled = true },
    }
})

-- Update title only
exports['oxide-menu']:update({
    subtitle = 'Updated: ' .. os.date('%H:%M:%S')
})
```

---

### updateItem

Updates a single item in the currently open menu by index.

```lua
exports['oxide-menu']:updateItem(index, itemData)
```

#### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| index | number | Yes | 1-based item index |
| itemData | table | Yes | Properties to update (merged with existing) |

#### Returns

| Type | Description |
|------|-------------|
| boolean | true if update was successful |

#### Example

```lua
-- Update item description
exports['oxide-menu']:updateItem(2, {
    description = 'Stock: 4'
})

-- Disable an item
exports['oxide-menu']:updateItem(3, {
    label = 'Bandage (SOLD OUT)',
    disabled = true
})

-- Update multiple properties
exports['oxide-menu']:updateItem(1, {
    label = 'Water (On Sale!)',
    description = '$1.50 | Stock: 10',
    icon = 'fas fa-tag'
})
```

---

### refresh

Re-renders the current menu with its existing data. Useful after modifying `currentMenu` directly.

```lua
exports['oxide-menu']:refresh()
```

#### Returns

| Type | Description |
|------|-------------|
| boolean | true if refresh was successful |

---

## Legacy API

These exports accept the qb-menu data format for easier migration.

### openMenu

Opens a menu using the qb-menu data format.

```lua
exports['oxide-menu']:openMenu(menuData, sort, skipFirst)
```

#### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| menuData | table | Yes | Array of legacy menu items |
| sort | boolean | No | Sort items alphabetically |
| skipFirst | boolean | No | Skip first item when sorting |

#### Legacy Item Format

| Property | Type | Description |
|----------|------|-------------|
| header | string | Item title/label |
| txt | string | Description text |
| icon | string | Font Awesome icon class |
| isMenuHeader | boolean | Makes item a non-clickable header |
| disabled | boolean | Disables the item |
| hidden | boolean | Hides the item |
| params | table | Action parameters |

#### params Table

| Property | Type | Description |
|----------|------|-------------|
| event | string/function | Event name or function |
| args | any | Arguments to pass |
| isServer | boolean | Trigger as server event |
| isCommand | boolean | Execute as command |
| isQBCommand | boolean | Execute as QBCore command |
| isAction | boolean | Event is a function |

#### Example

```lua
exports['oxide-menu']:openMenu({
    {
        header = 'Shop Menu',
        isMenuHeader = true,
    },
    {
        header = 'Buy Water',
        txt = '$5 - Restores thirst',
        icon = 'fas fa-tint',
        params = {
            isServer = true,
            event = 'shop:buyItem',
            args = { item = 'water', price = 5 }
        }
    },
    {
        header = 'Buy Sandwich',
        txt = '$10 - Restores hunger',
        icon = 'fas fa-hamburger',
        params = {
            isServer = true,
            event = 'shop:buyItem',
            args = { item = 'sandwich', price = 10 }
        }
    },
})
```

---

### closeMenu

Closes the currently open menu.

```lua
exports['oxide-menu']:closeMenu()
```

#### Example

```lua
exports['oxide-menu']:closeMenu()
```

---

### showHeader

Alias for openMenu. Opens a menu using legacy format.

```lua
exports['oxide-menu']:showHeader(menuData)
```

---

## Menu Data Structure

### Modern Format

```lua
{
    id = 'menu-id',           -- Optional: Unique identifier
    title = 'Menu Title',     -- Optional: Header text
    subtitle = 'Subtitle',    -- Optional: Subheader text
    position = 'right',       -- Optional: left/center/right
    searchable = true,        -- Optional: Show search bar
    items = { ... },          -- Required: Array of items
    onSelect = function(item, index) end,  -- Optional: Selection callback
    onClose = function() end,              -- Optional: Close callback
}
```

### Legacy Format

```lua
{
    {
        header = 'Title',
        isMenuHeader = true,
    },
    {
        header = 'Item Label',
        txt = 'Description',
        icon = 'fas fa-icon',
        params = { ... }
    },
    -- More items...
}
```

---

## Item Types

### Button (Default)

Standard clickable menu item.

```lua
{
    label = 'Button Text',
    description = 'Optional description',
    icon = 'fas fa-star',
    disabled = false,
    persist = false,  -- Keep menu open after selection

    -- Actions (choose one):
    event = 'client:eventName',
    serverEvent = 'server:eventName',
    command = 'commandName',
    qbCommand = 'qbCommandName',
    submenu = 'registered-menu-id',

    -- Arguments for events
    args = { key = 'value' },
}
```

### Header

Non-clickable section header.

```lua
{
    label = 'SECTION TITLE',
    isHeader = true,
}
```

### Divider

Visual separator line.

```lua
{
    type = 'divider',
}
```

### Checkbox

Toggle switch with boolean state.

```lua
{
    type = 'checkbox',
    label = 'Enable Feature',
    description = 'Turn this on or off',
    checked = false,  -- Initial state
}
```

Listen for changes:

```lua
AddEventHandler('oxide-menu:client:checkboxChange', function(index, checked, item)
    print(item.label .. ' is now ' .. (checked and 'ON' or 'OFF'))
end)
```

### Slider

Range input with numeric value.

```lua
{
    type = 'slider',
    label = 'Volume',
    min = 0,
    max = 100,
    value = 50,   -- Initial value
    step = 5,     -- Increment amount
}
```

Listen for changes:

```lua
AddEventHandler('oxide-menu:client:sliderChange', function(index, value, item)
    print(item.label .. ' set to ' .. value)
end)
```

### Input

Text input field.

```lua
{
    type = 'input',
    label = 'Player Name',
    placeholder = 'Enter name...',
    value = '',  -- Initial value
}
```

Listen for submit (Enter key):

```lua
AddEventHandler('oxide-menu:client:inputSubmit', function(index, value, item)
    print(item.label .. ': ' .. value)
end)
```

---

## Client Events

### oxide-menu:client:closed

Fired when any menu is closed.

```lua
AddEventHandler('oxide-menu:client:closed', function()
    print('Menu closed')
end)
```

### oxide-menu:client:checkboxChange

Fired when a checkbox is toggled.

```lua
AddEventHandler('oxide-menu:client:checkboxChange', function(index, checked, item)
    -- index: 1-based item index
    -- checked: boolean state
    -- item: full item data
end)
```

### oxide-menu:client:sliderChange

Fired when a slider value changes.

```lua
AddEventHandler('oxide-menu:client:sliderChange', function(index, value, item)
    -- index: 1-based item index
    -- value: numeric value
    -- item: full item data
end)
```

### oxide-menu:client:inputSubmit

Fired when Enter is pressed in an input field.

```lua
AddEventHandler('oxide-menu:client:inputSubmit', function(index, value, item)
    -- index: 1-based item index
    -- value: string value
    -- item: full item data
end)
```

### qb-menu:client:menuClosed

This event still fires for scripts that listen to it.

```lua
AddEventHandler('qb-menu:client:menuClosed', function()
    print('Menu closed (legacy)')
end)
```

### Server-Triggered Updates

The server can push updates to open menus:

```lua
-- Server-side: Update entire menu
TriggerClientEvent('oxide-menu:client:update', source, {
    items = newItems
})

-- Server-side: Update single item
TriggerClientEvent('oxide-menu:client:updateItem', source, 2, {
    description = 'Price: $50',
    disabled = true
})
```

---

## Integration Examples

### Simple Shop Menu

```lua
local function OpenShop()
    exports['oxide-menu']:open({
        id = 'shop-menu',
        title = '24/7 Store',
        subtitle = 'Welcome!',
        searchable = true,
        items = {
            { label = 'FOOD', isHeader = true },
            { label = 'Water', description = '$5', icon = 'water', serverEvent = 'shop:buy', args = { item = 'water' } },
            { label = 'Bread', description = '$8', icon = 'bread', serverEvent = 'shop:buy', args = { item = 'bread' } },
            { type = 'divider' },
            { label = 'SUPPLIES', isHeader = true },
            { label = 'Bandage', description = '$25', icon = 'bandage', serverEvent = 'shop:buy', args = { item = 'bandage' } },
        }
    })
end
```

### Settings Menu with Interactive Elements

```lua
local settings = {
    musicVolume = 50,
    sfxVolume = 80,
    showHud = true,
}

local function OpenSettings()
    exports['oxide-menu']:open({
        id = 'settings',
        title = 'Settings',
        items = {
            { type = 'slider', label = 'Music Volume', min = 0, max = 100, value = settings.musicVolume },
            { type = 'slider', label = 'SFX Volume', min = 0, max = 100, value = settings.sfxVolume },
            { type = 'divider' },
            { type = 'checkbox', label = 'Show HUD', checked = settings.showHud },
        }
    })
end

AddEventHandler('oxide-menu:client:sliderChange', function(index, value, item)
    if item.label == 'Music Volume' then
        settings.musicVolume = value
        -- Apply music volume
    elseif item.label == 'SFX Volume' then
        settings.sfxVolume = value
        -- Apply SFX volume
    end
end)

AddEventHandler('oxide-menu:client:checkboxChange', function(index, checked, item)
    if item.label == 'Show HUD' then
        settings.showHud = checked
        -- Toggle HUD
    end
end)
```

### Job Menu with Submenus

```lua
-- Register submenus
exports['oxide-menu']:register('police-armory', {
    title = 'Armory',
    items = {
        { label = 'Pistol', icon = 'fas fa-gun', serverEvent = 'police:getWeapon', args = { weapon = 'pistol' } },
        { label = 'Taser', icon = 'fas fa-bolt', serverEvent = 'police:getWeapon', args = { weapon = 'taser' } },
        { label = 'Handcuffs', icon = 'fas fa-link', serverEvent = 'police:getItem', args = { item = 'handcuffs' } },
    }
})

exports['oxide-menu']:register('police-vehicles', {
    title = 'Vehicle Spawn',
    items = {
        { label = 'Police Cruiser', serverEvent = 'police:spawnVehicle', args = { model = 'police' } },
        { label = 'Police SUV', serverEvent = 'police:spawnVehicle', args = { model = 'police2' } },
    }
})

-- Main menu
local function OpenPoliceMenu()
    exports['oxide-menu']:open({
        id = 'police-main',
        title = 'Police Department',
        subtitle = 'Officer Menu',
        items = {
            { label = 'Toggle Duty', icon = 'fas fa-clock', serverEvent = 'police:toggleDuty' },
            { type = 'divider' },
            { label = 'Armory', icon = 'fas fa-shield-alt', submenu = 'police-armory' },
            { label = 'Vehicles', icon = 'fas fa-car', submenu = 'police-vehicles' },
        }
    })
end
```

### Persistent Shop Menu

```lua
-- Menu stays open after each purchase
local function OpenShop()
    exports['oxide-menu']:open({
        id = 'quick-shop',
        title = '24/7 Store',
        subtitle = 'Quick Buy Mode',
        persist = true,  -- Menu-level: all items keep menu open
        items = {
            { label = 'DRINKS', isHeader = true },
            { label = 'Water', description = '$2', icon = 'water', serverEvent = 'shop:buy', args = { item = 'water', price = 2 } },
            { label = 'Soda', description = '$3', icon = 'soda', serverEvent = 'shop:buy', args = { item = 'soda', price = 3 } },
            { type = 'divider' },
            { label = 'FOOD', isHeader = true },
            { label = 'Sandwich', description = '$5', icon = 'sandwich', serverEvent = 'shop:buy', args = { item = 'sandwich', price = 5 } },
            { type = 'divider' },
            { label = 'Done Shopping', icon = 'fas fa-check', persist = false },  -- Override: closes menu
        }
    })
end
```

### Live Updating Shop (onSelect Return)

```lua
-- Shop with live stock updates using onSelect return value
local stock = { water = 10, bread = 5 }

local function GetShopItems()
    return {
        { label = 'ITEMS', isHeader = true },
        {
            label = 'Water',
            description = '$2 | Stock: ' .. stock.water,
            disabled = stock.water <= 0,
            _item = 'water'
        },
        {
            label = 'Bread',
            description = '$3 | Stock: ' .. stock.bread,
            disabled = stock.bread <= 0,
            _item = 'bread'
        },
        { type = 'divider' },
        { label = 'Exit', persist = false },
    }
end

local function OpenShop()
    exports['oxide-menu']:open({
        id = 'live-shop',
        title = 'Live Stock Shop',
        persist = true,
        items = GetShopItems(),
        onSelect = function(item, index, isPersisting)
            if not isPersisting or not item._item then return end

            if stock[item._item] > 0 then
                stock[item._item] = stock[item._item] - 1
                -- Return updated items to refresh menu
                return GetShopItems()
            end
        end
    })
end
```

### Live Updating with updateItem

```lua
-- Update individual items for better performance
local function OpenCounterMenu()
    local counts = { 0, 0, 0 }

    exports['oxide-menu']:open({
        id = 'counters',
        title = 'Click Counters',
        persist = true,
        items = {
            { label = 'Counter 1', description = 'Clicks: 0', _idx = 1 },
            { label = 'Counter 2', description = 'Clicks: 0', _idx = 2 },
            { label = 'Counter 3', description = 'Clicks: 0', _idx = 3 },
        },
        onSelect = function(item, index, isPersisting)
            if not isPersisting or not item._idx then return end

            counts[item._idx] = counts[item._idx] + 1
            -- Update just this item (more efficient than full refresh)
            exports['oxide-menu']:updateItem(index, {
                description = 'Clicks: ' .. counts[item._idx]
            })
        end
    })
end
```

### Live Updating with onRefresh Callback

```lua
-- Cleanest approach: separate data logic from refresh logic
local inventory = { water = 5, bread = 3 }

local function buildItems()
    return {
        { label = 'Water x' .. inventory.water, disabled = inventory.water <= 0, _item = 'water' },
        { label = 'Bread x' .. inventory.bread, disabled = inventory.bread <= 0, _item = 'bread' },
        { label = 'Exit', persist = false },
    }
end

local function OpenInventory()
    exports['oxide-menu']:open({
        id = 'inventory',
        title = 'Use Items',
        persist = true,
        items = buildItems(),
        onSelect = function(item)
            -- Just handle the action, don't worry about refresh
            if item._item and inventory[item._item] > 0 then
                inventory[item._item] = inventory[item._item] - 1
            end
        end,
        onRefresh = function()
            -- Called automatically after onSelect when persist=true
            return buildItems()
        end
    })
end
```

### Vehicle Menu with Mixed Persist

```lua
-- Some items stay open, others close
local function OpenVehicleMenu()
    exports['oxide-menu']:open({
        id = 'vehicle-controls',
        title = 'Vehicle Options',
        items = {
            { label = 'TOGGLES', isHeader = true },
            -- These keep the menu open for quick toggling
            { label = 'Engine', icon = 'fas fa-power-off', persist = true, event = 'vehicle:toggleEngine' },
            { label = 'Lights', icon = 'fas fa-lightbulb', persist = true, event = 'vehicle:toggleLights' },
            { label = 'Lock', icon = 'fas fa-lock', persist = true, event = 'vehicle:toggleLock' },
            { type = 'divider' },
            { label = 'ACTIONS', isHeader = true },
            -- These close the menu (default behavior)
            { label = 'Store Vehicle', icon = 'fas fa-warehouse', serverEvent = 'vehicle:store' },
            { label = 'Transfer Keys', icon = 'fas fa-key', serverEvent = 'vehicle:transfer' },
        }
    })
end
```

---

*Oxide Menu - Modern menus for QBCore*
