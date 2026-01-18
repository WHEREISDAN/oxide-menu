# Troubleshooting Guide

Common issues and solutions for Oxide Menu.

---

## Table of Contents

- [Installation Issues](#installation-issues)
- [Menu Display Issues](#menu-display-issues)
- [Styling Issues](#styling-issues)
- [Event Issues](#event-issues)
- [Input/Interactive Issues](#inputinteractive-issues)
- [Performance Issues](#performance-issues)
- [Legacy Compatibility Issues](#legacy-compatibility-issues)
- [FAQ](#faq)

---

## Installation Issues

### Menu resource not found

**Symptom:** Error in console: `No such export openMenu in resource oxide-menu`

**Solutions:**
1. Ensure the resource is started in `server.cfg`:
   ```cfg
   ensure oxide-menu
   ```
2. Check the resource folder name is exactly `oxide-menu`
3. Ensure it starts after qb-core:
   ```cfg
   ensure qb-core
   ensure oxide-menu
   ```
4. Run `refresh` then `ensure oxide-menu` in console

### NUI not loading

**Symptom:** Menu opens but shows blank/broken UI

**Solutions:**
1. Clear FiveM cache:
   ```
   %localappdata%/FiveM/FiveM.app/data/cache/
   ```
   Delete contents of this folder

2. Verify all files exist:
   ```
   oxide-menu/
   ├── html/
   │   ├── index.html
   │   └── css/
   │       ├── variables.css
   │       ├── animations.css
   │       └── main.css
   ```

3. Check F8 console for NUI errors

### QBCore not found

**Symptom:** Error: `attempt to index a nil value (global 'QBCore')`

**Solutions:**
1. Ensure qb-core starts first in server.cfg
2. Verify qb-core is working properly
3. Check fxmanifest.lua has correct dependency

---

## Menu Display Issues

### Menu not appearing

**Symptom:** Export called but nothing shows

**Solutions:**

1. **Check if data is valid:**
   ```lua
   local menuData = { ... }
   print('Menu data:', json.encode(menuData))
   exports['oxide-menu']:open(menuData)
   ```

2. **Check for empty items:**
   ```lua
   -- This won't show:
   exports['oxide-menu']:open({ items = {} })

   -- Need at least one item:
   exports['oxide-menu']:open({
       items = {{ label = 'Test' }}
   })
   ```

3. **Check for script errors** in F8 console

4. **Verify NUI focus:**
   ```lua
   -- Menu sets focus automatically, but check if another resource stole it
   SetNuiFocus(false, false)  -- Reset first
   exports['oxide-menu']:open(...)
   ```

### Menu stuck open

**Symptom:** Can't close menu, mouse trapped

**Solutions:**

1. **Force close via console:**
   ```lua
   exports['oxide-menu']:close()
   ```

2. **Reset NUI focus:**
   ```lua
   SetNuiFocus(false, false)
   ```

3. **Check for script errors** that might prevent close callback

### Menu position wrong

**Symptom:** Menu appears in wrong location

**Solutions:**

1. **Check config:**
   ```lua
   Config.Position = 'right'  -- left, center, right
   ```

2. **Check per-menu override:**
   ```lua
   exports['oxide-menu']:open({
       position = 'left',  -- Overrides config
       items = { ... }
   })
   ```

---

## Styling Issues

### Wrong theme showing

**Symptom:** Theme doesn't match config

**Solutions:**

1. **Check config.lua:**
   ```lua
   Config.Theme = 'oxide'  -- oxide, dark, light
   ```

2. **Clear cache** and restart

3. **Verify theme exists** in `html/css/variables.css`

### Colors not updating

**Symptom:** CSS changes not visible

**Solutions:**

1. **Clear FiveM cache** (NUI assets are cached aggressively)

2. **Check correct file:** Changes should be in `html/css/variables.css`

3. **Check CSS syntax:** Invalid CSS silently fails

4. **Force refresh:** Disconnect and reconnect to server

### Icons not showing

**Symptom:** Missing icons, broken images

**Solutions:**

1. **Font Awesome icons:**
   - Use correct format: `fas fa-icon` (not just `fa-icon`)
   - Ensure Font Awesome CDN is accessible

2. **QBCore item icons:**
   - Verify item exists in `QBCore.Shared.Items`
   - Check qb-inventory has the image file

3. **Custom icons:**
   - Use `nui://` protocol: `nui://resource/path/image.png`
   - External URLs are blocked for security

4. **Check icon validation:**
   ```lua
   -- This is blocked:
   { icon = 'https://external.com/icon.png' }

   -- Use this instead:
   { icon = 'nui://my-resource/icons/custom.png' }
   ```

---

## Event Issues

### Event not triggering

**Symptom:** Click item, nothing happens

**Solutions:**

1. **Check event name matches:**
   ```lua
   -- Menu item
   { label = 'Test', event = 'myResource:testEvent' }

   -- Handler (must match exactly)
   AddEventHandler('myResource:testEvent', function(args)
       print('Received!')
   end)
   ```

2. **Check if security is blocking:**
   ```lua
   -- If ValidateEvents is true, event must be whitelisted
   Config.Security = {
       ValidateEvents = true,
       AllowedClientEvents = { 'myResource:testEvent' },
   }
   ```

3. **Enable debug mode** to see blocked events:
   ```lua
   Config.Debug = true
   -- Check console for: [oxide-menu] Blocked client: ...
   ```

4. **Verify event type:**
   ```lua
   -- Client event (RegisterNetEvent NOT needed)
   { event = 'client:event' }

   -- Server event (needs RegisterNetEvent on server)
   { serverEvent = 'server:event' }
   ```

### Server event not received

**Symptom:** Server handler never fires

**Solutions:**

1. **Register the event:**
   ```lua
   -- Server-side
   RegisterNetEvent('myResource:serverEvent', function(args)
       local src = source
       print('Received from', src)
   end)
   ```

2. **Use serverEvent, not event:**
   ```lua
   -- Correct:
   { serverEvent = 'myResource:serverEvent' }

   -- Wrong (this is client-only):
   { event = 'myResource:serverEvent' }
   ```

3. **Check security whitelist:**
   ```lua
   Config.Security = {
       ValidateEvents = true,
       AllowedServerEvents = { 'myResource:serverEvent' },
   }
   ```

### Args not passed correctly

**Symptom:** Args are nil or wrong

**Solutions:**

1. **Check args format:**
   ```lua
   -- Menu
   { serverEvent = 'test', args = { item = 'water', count = 5 } }

   -- Handler receives the table directly
   RegisterNetEvent('test', function(args)
       print(args.item)   -- 'water'
       print(args.count)  -- 5
   end)
   ```

2. **Args must be JSON-serializable:**
   ```lua
   -- This won't work (function can't serialize):
   { event = 'test', args = { callback = function() end } }
   ```

---

## Input/Interactive Issues

### Checkbox not updating

**Symptom:** Click checkbox, state doesn't change

**Solutions:**

1. **Listen for the event:**
   ```lua
   AddEventHandler('oxide-menu:client:checkboxChange', function(index, checked, item)
       print(item.label, 'is now', checked)
   end)
   ```

2. **Check item type:**
   ```lua
   { type = 'checkbox', label = 'Option', checked = false }
   ```

### Slider not working

**Symptom:** Can't drag slider or no updates

**Solutions:**

1. **Listen for the event:**
   ```lua
   AddEventHandler('oxide-menu:client:sliderChange', function(index, value, item)
       print(item.label, '=', value)
   end)
   ```

2. **Check item format:**
   ```lua
   { type = 'slider', label = 'Volume', min = 0, max = 100, value = 50 }
   ```

### Input not submitting

**Symptom:** Press Enter, nothing happens

**Solutions:**

1. **Listen for the event:**
   ```lua
   AddEventHandler('oxide-menu:client:inputSubmit', function(index, value, item)
       print('Submitted:', value)
   end)
   ```

2. **Ensure Enter key pressed** (not just clicking away)

### Keyboard navigation not working

**Symptom:** Arrow keys don't work

**Solutions:**

1. **Not focused on input:** Arrow keys work for menu navigation, not when typing in input field. Press Escape to unfocus input.

2. **Menu must be open:** Navigation only works with active menu

3. **Check for NUI focus issues:** Another resource may have stolen focus

---

## Performance Issues

### Menu slow to open

**Symptom:** Noticeable delay when opening

**Solutions:**

1. **Reduce item count:** Very large menus (100+) may be slow

2. **Disable sounds:**
   ```lua
   Config.Sound = { enabled = false }
   ```

3. **Disable animations in CSS:** Edit `html/css/animations.css` to reduce or remove animation duration

4. **Check for script errors** causing delays

### Laggy scrolling

**Symptom:** Scrolling through items stutters

**Solutions:**

1. **Reduce item count** in single menu

2. **Use submenus** to split large menus

3. **Check other resource** performance impact

---

## Legacy Compatibility Issues

### Scripts using qb-menu exports

**Symptom:** Script using `exports['qb-menu']` doesn't work

**Solution:**

Update the export name in your scripts:

```lua
-- Change from:
exports['qb-menu']:openMenu(...)

-- To:
exports['oxide-menu']:openMenu(...)
```

The menu data format stays the same - only the export name needs to change.

### Legacy menu looks different

**Symptom:** Old menus have new styling

**Expected behavior:** Oxide Menu applies its styling to all menus. This is not a bug.

**Solutions:**
1. This is intentional - modern styling for all menus
2. Customize theme in `variables.css` if needed
3. Functionality is preserved, only appearance changes

### Action functions not executing

**Symptom:** Menu with function actions doesn't work

**Solutions:**

1. **Check function is defined correctly:**
   ```lua
   {
       header = 'Action',
       action = function()  -- Function, not string
           print('Hello')
       end
   }
   ```

2. **Check params format:**
   ```lua
   {
       header = 'Action',
       params = {
           isAction = true,
           event = function(args)
               print(args.test)
           end,
           args = { test = 'value' }
       }
   }
   ```

---

## FAQ

### Can I use oxide-menu alongside qb-menu?

Not recommended. They serve the same purpose. Choose one and migrate fully.

### Do I need to update my existing scripts?

Yes, you need to change the export name from `'qb-menu'` to `'oxide-menu'`. The menu data format (headers, items, params) stays the same.

### How do I add custom fonts?

1. Add font import to `html/index.html`
2. Update `--font-family` in `html/css/variables.css`

### Why is my search not showing?

Search only appears when:
- `Config.Search.enabled = true` (global setting)
- Menu has >= `Config.Search.minItems` items (default 6)
- Menu doesn't have `searchable = false`

### How do I disable all animations?

```lua
Config.Animation = {
    enabled = false,
    duration = 0,
    type = 'slide'
}
```

### How do I make menus wider?

```lua
Config.Width = 400  -- Default is 320
```

### Can I have multiple menus open?

No. Opening a new menu closes the previous one. Use submenus for nested navigation.

### Why are external icons blocked?

Security feature. External URLs could track users or load malicious content. Use `nui://` protocol for custom images.

---

## Getting Help

If your issue isn't covered here:

1. **Check F8 console** for errors
2. **Enable debug mode** (`Config.Debug = true`)
3. **Review the documentation** linked in README
4. **Check for resource conflicts** with other NUI-based resources

---

*Oxide Menu - Modern menus for QBCore*
