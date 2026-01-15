--[[
    Oxide Menu - Client
    Modern menu system with qb-menu data format support
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- Menu State
local isOpen = false
local currentMenu = nil
local registeredMenus = {}
local menuCallbacks = {}

-- Utility Functions

local function Debug(...)
    if Config.Debug then
        print('[oxide-menu]', ...)
    end
end

local function PlaySound(soundType)
    if not Config.Sound or not Config.Sound.enabled then return end
    if soundType == 'hover' and Config.Sound.hover then
        PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    elseif soundType == 'select' and Config.Sound.select then
        PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    elseif soundType == 'close' and Config.Sound.close then
        PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    end
end

local function ProcessItemIcon(item)
    if item.icon and QBCore.Shared.Items[tostring(item.icon)] then
        local itemData = QBCore.Shared.Items[tostring(item.icon)]
        if itemData.image and not string.find(itemData.image, "//") then
            item.icon = "nui://qb-inventory/html/images/" .. itemData.image
        end
    end
    return item
end

local function IsEventAllowed(eventName, eventType)
    if not Config.Security or not Config.Security.ValidateEvents then
        return true
    end

    local whitelist
    if eventType == 'server' then
        whitelist = Config.Security.AllowedServerEvents
    elseif eventType == 'client' then
        whitelist = Config.Security.AllowedClientEvents
    else
        whitelist = Config.Security.AllowedCommands
    end

    if not whitelist or #whitelist == 0 then
        return true
    end

    for _, allowed in ipairs(whitelist) do
        if allowed == eventName then
            return true
        end
    end

    Debug('Blocked ' .. eventType .. ':', eventName)
    return false
end

-- Legacy Format Transformation
-- Action functions stored separately since they can't be serialized to NUI
local legacyActions = {}

local function TransformLegacyItem(legacyItem, originalIndex)
    if not legacyItem then return nil end

    local item = {
        label = legacyItem.header,
        description = legacyItem.txt or legacyItem.text,
        icon = legacyItem.icon,
        image = legacyItem.image,
        isHeader = legacyItem.isMenuHeader,
        disabled = legacyItem.disabled,
        hidden = legacyItem.hidden,
        _legacyIndex = originalIndex,
    }

    ProcessItemIcon(item)

    if legacyItem.action and type(legacyItem.action) == 'function' then
        legacyActions[originalIndex] = legacyItem.action
        item._hasAction = true
    end

    if legacyItem.params then
        local params = legacyItem.params

        if params.isAction and type(params.event) == 'function' then
            legacyActions[originalIndex] = function() params.event(params.args) end
            item._hasAction = true
        elseif params.isServer then
            item.serverEvent = params.event
            item.args = params.args
        elseif params.isCommand then
            item.command = params.event
        elseif params.isQBCommand then
            item.qbCommand = params.event
            item.args = params.args
        elseif params.event then
            item.event = params.event
            item.args = params.args
        end
    end

    return item
end

local function TransformLegacyMenu(legacyData)
    if not legacyData or not next(legacyData) then return nil end

    legacyActions = {}

    local items = {}
    local title = nil
    local hasHeader = false

    for i, legacyItem in ipairs(legacyData) do
        local item = TransformLegacyItem(legacyItem, i)
        if item then
            if item.isHeader and not hasHeader then
                title = item.label
                hasHeader = true
            end
            items[#items + 1] = item
        end
    end

    return {
        title = title,
        position = Config.Position,
        items = items,
        isLegacy = true
    }
end

local function SortLegacyData(data, skipFirst)
    if not data or #data == 0 then return data end

    local header = data[1]
    local tempData = {}

    for i, v in ipairs(data) do
        if not skipFirst or i > 1 then
            tempData[#tempData + 1] = v
        end
    end

    table.sort(tempData, function(a, b)
        return (a.header or '') < (b.header or '')
    end)

    if skipFirst then
        table.insert(tempData, 1, header)
    end

    return tempData
end

-- Core Menu Functions

local function Open(menuData)
    if not menuData then return false end

    if menuData.submenu and registeredMenus[menuData.submenu] then
        menuData = registeredMenus[menuData.submenu]
    end

    if menuData.id then
        menuCallbacks[menuData.id] = {
            onClose = menuData.onClose,
            onSelect = menuData.onSelect
        }
    end

    menuData.position = menuData.position or Config.Position

    if menuData.items and not menuData.isLegacy then
        for _, item in ipairs(menuData.items) do
            ProcessItemIcon(item)
        end
    end

    currentMenu = menuData
    isOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'OPEN_MENU',
        data = menuData
    })

    Debug('Menu opened:', menuData.id or 'unnamed')
    return true
end

local function Close(menuId)
    if not isOpen then return end
    if menuId and currentMenu and currentMenu.id ~= menuId then return end

    isOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'CLOSE_MENU',
        data = {}
    })

    local closedMenuId = currentMenu and currentMenu.id
    if closedMenuId and menuCallbacks[closedMenuId] then
        local cb = menuCallbacks[closedMenuId].onClose
        if cb then cb() end
        menuCallbacks[closedMenuId] = nil
    end

    currentMenu = nil
    legacyActions = {}
    Debug('Menu closed')
end

local function Register(menuId, menuData)
    if not menuId or not menuData then return false end
    registeredMenus[menuId] = menuData
    return true
end

local function IsOpen(menuId)
    if menuId then
        return isOpen and currentMenu and currentMenu.id == menuId
    end
    return isOpen
end

-- Legacy API Functions

local function OpenMenu(data, sort, skipFirst)
    if not data or not next(data) then return end

    if sort then
        data = SortLegacyData(data, skipFirst)
    end

    local menuData = TransformLegacyMenu(data)
    if menuData then
        Open(menuData)
    end
end

local function CloseMenu()
    Close()
end

local function ShowHeader(data)
    if not data or not next(data) then return end
    local menuData = TransformLegacyMenu(data)
    if menuData then
        Open(menuData)
    end
end

-- NUI Callbacks

RegisterNUICallback('onSelect', function(data, cb)
    cb('ok')
    if not currentMenu then return end
    if not data or type(data.item) ~= 'table' or not data.index then return end

    local item = data.item
    Debug('Item selected:', data.index)

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'CLOSE_MENU', data = {} })

    local menuId = currentMenu.id
    local wasLegacy = currentMenu.isLegacy
    isOpen = false
    currentMenu = nil

    if wasLegacy and item._hasAction and item._legacyIndex then
        local actionFn = legacyActions[item._legacyIndex]
        if actionFn then
            actionFn()
            legacyActions = {}
            TriggerEvent('qb-menu:client:menuClosed')
            return
        end
    end

    legacyActions = {}

    if item.event then
        if IsEventAllowed(item.event, 'client') then
            TriggerEvent(item.event, item.args)
        end
    elseif item.serverEvent then
        if IsEventAllowed(item.serverEvent, 'server') then
            TriggerServerEvent(item.serverEvent, item.args)
        end
    elseif item.command then
        if IsEventAllowed(item.command, 'command') then
            ExecuteCommand(item.command)
        end
    elseif item.qbCommand then
        if IsEventAllowed(item.qbCommand, 'command') then
            TriggerServerEvent('QBCore:CallCommand', item.qbCommand, item.args)
        end
    end

    if menuId and menuCallbacks[menuId] then
        local callback = menuCallbacks[menuId].onSelect
        if callback then callback(item, data.index) end
        menuCallbacks[menuId] = nil
    end

    if wasLegacy then
        TriggerEvent('qb-menu:client:menuClosed')
    end
end)

RegisterNUICallback('onClose', function(data, cb)
    cb('ok')
    PlaySound('close')

    local wasLegacy = currentMenu and currentMenu.isLegacy
    local closedMenuId = currentMenu and currentMenu.id

    isOpen = false
    SetNuiFocus(false, false)

    if closedMenuId and menuCallbacks[closedMenuId] then
        local callback = menuCallbacks[closedMenuId].onClose
        if callback then callback() end
        menuCallbacks[closedMenuId] = nil
    end

    currentMenu = nil
    legacyActions = {}

    TriggerEvent('oxide-menu:client:closed')
    if wasLegacy then
        TriggerEvent('qb-menu:client:menuClosed')
    end
end)

RegisterNUICallback('onBack', function(data, cb)
    cb('ok')
end)

RegisterNUICallback('onSound', function(data, cb)
    cb('ok')
    PlaySound(data.type)
end)

RegisterNUICallback('onCheckboxChange', function(data, cb)
    cb('ok')
    if not data or type(data.index) ~= 'number' then return end
    TriggerEvent('oxide-menu:client:checkboxChange', data.index, data.checked, data.item)
end)

RegisterNUICallback('onInputSubmit', function(data, cb)
    cb('ok')
    if not data or type(data.index) ~= 'number' then return end
    TriggerEvent('oxide-menu:client:inputSubmit', data.index, data.value, data.item)
end)

RegisterNUICallback('onSliderChange', function(data, cb)
    cb('ok')
    if not data or type(data.index) ~= 'number' then return end
    TriggerEvent('oxide-menu:client:sliderChange', data.index, data.value, data.item)
end)

-- Events

RegisterNetEvent('oxide-menu:client:open', function(menuData)
    Open(menuData)
end)

RegisterNetEvent('oxide-menu:client:close', function(menuId)
    Close(menuId)
end)

RegisterNetEvent('QBCore:Client:UpdateObject', function()
    QBCore = exports['qb-core']:GetCoreObject()
end)

-- Exports

exports('open', Open)
exports('close', Close)
exports('register', Register)
exports('isOpen', IsOpen)

exports('openMenu', OpenMenu)
exports('closeMenu', CloseMenu)
exports('showHeader', ShowHeader)

-- Initialization

CreateThread(function()
    SendNUIMessage({
        action = 'SET_THEME',
        data = { theme = Config.Theme }
    })
end)

-- Debug Commands (only when Config.Debug is enabled)

if Config.Debug then
    RegisterCommand('oxidemenu', function()
        Open({
            id = 'demo-main',
            title = 'Character Options',
            subtitle = 'Manage your character',
            position = 'right',
            items = {
                { label = 'Inventory', description = 'View your items', icon = 'fas fa-box' },
                { label = 'Clothing', description = 'Change your outfit', icon = 'fas fa-tshirt' },
                { label = 'Vehicles', description = 'Manage owned vehicles', icon = 'fas fa-car' },
                { type = 'divider' },
                { label = 'Settings', description = 'Adjust preferences', icon = 'fas fa-cog' },
                { label = 'Help', description = 'Get assistance', icon = 'fas fa-question-circle' },
            }
        })
    end, false)

    -- Job menu showcase
    RegisterCommand('oxidemenu2', function()
        Open({
            id = 'demo-job',
            title = 'Police Department',
            subtitle = 'Officer Actions',
            items = {
                { label = 'DUTY & EQUIPMENT', isHeader = true },
                { label = 'Go On Duty', description = 'Clock in for your shift', icon = 'fas fa-clock' },
                { label = 'Access Armory', description = 'Get department equipment', icon = 'fas fa-shield-alt' },
                { label = 'Locker Room', description = 'Change into uniform', icon = 'fas fa-door-open' },
                { type = 'divider' },
                { label = 'DEPARTMENT', isHeader = true },
                { label = 'View Roster', description = 'See active officers', icon = 'fas fa-users' },
                { label = 'Evidence Locker', description = 'Store case evidence', icon = 'fas fa-archive' },
                { label = 'Impound Lot', description = 'Access seized vehicles', icon = 'fas fa-warehouse' },
            }
        })
    end, false)

    -- Interactive elements showcase
    RegisterCommand('oxidemenu3', function()
        Open({
            id = 'demo-interactive',
            title = 'Vehicle Settings',
            subtitle = 'Customize your ride',
            items = {
                { type = 'checkbox', label = 'Engine Running', description = 'Toggle engine state', checked = true },
                { type = 'checkbox', label = 'Doors Locked', description = 'Lock all doors', checked = false },
                { type = 'checkbox', label = 'Neon Lights', description = 'Underglow lighting', checked = true },
                { type = 'divider' },
                { type = 'slider', label = 'Radio Volume', min = 0, max = 100, value = 75 },
                { type = 'slider', label = 'Window Tint', min = 0, max = 100, value = 50, step = 10 },
                { type = 'divider' },
                { type = 'input', label = 'License Plate', placeholder = 'Enter plate text...', value = '' },
            }
        })
    end, false)

    -- Shop menu showcase
    RegisterCommand('oxidemenu4', function()
        Open({
            id = 'demo-shop',
            title = '24/7 Supermarket',
            subtitle = 'Open 24 Hours',
            searchable = true,
            items = {
                { label = 'FOOD & DRINKS', isHeader = true },
                { label = 'Water Bottle', description = '$2.00 - Restores thirst', icon = 'fas fa-tint' },
                { label = 'Sandwich', description = '$5.00 - Restores hunger', icon = 'fas fa-hamburger' },
                { label = 'Energy Drink', description = '$4.00 - Stamina boost', icon = 'fas fa-bolt' },
                { label = 'Coffee', description = '$3.00 - Stay alert', icon = 'fas fa-mug-hot' },
                { type = 'divider' },
                { label = 'SUPPLIES', isHeader = true },
                { label = 'First Aid Kit', description = '$50.00 - Heal injuries', icon = 'fas fa-first-aid' },
                { label = 'Flashlight', description = '$25.00 - Light the way', icon = 'fas fa-flashlight' },
                { label = 'Phone Charger', description = '$15.00 - Charge device', icon = 'fas fa-battery-full' },
                { label = 'Binoculars', description = '$75.00 - See far away', icon = 'fas fa-binoculars' },
                { type = 'divider' },
                { label = 'MISCELLANEOUS', isHeader = true },
                { label = 'Cigarettes', description = '$8.00 - Pack of smokes', icon = 'fas fa-smoking' },
                { label = 'Lighter', description = '$2.00 - Start fires', icon = 'fas fa-fire' },
                { label = 'Newspaper', description = '$1.00 - Daily news', icon = 'fas fa-newspaper' },
            }
        })
    end, false)

    -- Legacy format showcase
    RegisterCommand('oxidemenu5', function()
        OpenMenu({
            {
                header = 'Mechanic Services',
                isMenuHeader = true,
            },
            {
                header = 'Repair Vehicle',
                txt = 'Fix body damage - $500',
                icon = 'fas fa-wrench',
                params = { event = 'oxide-menu:demo:notify', args = { msg = 'Vehicle repaired!' } }
            },
            {
                header = 'Engine Tune',
                txt = 'Improve performance - $2,000',
                icon = 'fas fa-cogs',
                params = { event = 'oxide-menu:demo:notify', args = { msg = 'Engine tuned!' } }
            },
            {
                header = 'Respray',
                txt = 'Change vehicle color - $1,000',
                icon = 'fas fa-paint-brush',
                params = { event = 'oxide-menu:demo:notify', args = { msg = 'Vehicle resprayed!' } }
            },
            {
                header = 'Tire Change',
                txt = 'Replace worn tires - $400',
                icon = 'fas fa-circle',
                params = { event = 'oxide-menu:demo:notify', args = { msg = 'Tires changed!' } }
            },
            {
                header = 'Nitrous Install',
                txt = 'Add nitrous system - $5,000',
                icon = 'fas fa-fire-alt',
                disabled = true,
            },
        })
    end, false)

    -- Position demo
    RegisterCommand('oxidemenu6', function(source, args)
        local pos = args[1] or 'right'
        Open({
            title = 'Menu Position: ' .. pos:upper(),
            subtitle = 'Try: /oxidemenu6 left|center|right',
            position = pos,
            items = {
                { label = 'Left Position', icon = 'fas fa-arrow-left', event = 'oxide-menu:demo:position', args = { pos = 'left' } },
                { label = 'Center Position', icon = 'fas fa-arrows-alt-h', event = 'oxide-menu:demo:position', args = { pos = 'center' } },
                { label = 'Right Position', icon = 'fas fa-arrow-right', event = 'oxide-menu:demo:position', args = { pos = 'right' } },
            }
        })
    end, false)

    -- Demo event handlers
    RegisterNetEvent('oxide-menu:demo:notify', function(data)
        QBCore.Functions.Notify(data.msg or 'Action completed!', 'success')
    end)

    RegisterNetEvent('oxide-menu:demo:position', function(data)
        ExecuteCommand('oxidemenu6 ' .. (data.pos or 'right'))
    end)

    AddEventHandler('oxide-menu:client:checkboxChange', function(index, checked, item)
        QBCore.Functions.Notify(item.label .. ': ' .. (checked and 'Enabled' or 'Disabled'), 'primary')
    end)

    AddEventHandler('oxide-menu:client:sliderChange', function(index, value, item)
    end)

    AddEventHandler('oxide-menu:client:inputSubmit', function(index, value, item)
        QBCore.Functions.Notify(item.label .. ' set to: ' .. value, 'primary')
    end)

    print('[oxide-menu] Debug mode enabled - Demo commands: /oxidemenu, /oxidemenu2, /oxidemenu3, /oxidemenu4, /oxidemenu5, /oxidemenu6')
end
