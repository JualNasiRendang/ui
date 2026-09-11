--[[
    ============================================================================
    COMPACT MODERN UI DESIGN SYSTEM & LIBRARY (STANDALONE MODULE)
    ============================================================================
    Architecture : Decoupled UI Module
    File Path    : D:\Roblox\NEW UI\Compact Modern\Compact Modern.lua
    Author       : NRL Script
    Export       : returns CompactModern table / callable factory
    
    ----------------------------------------------------------------------------
    FITUR UTAMA:
    ----------------------------------------------------------------------------
    1. Dynamic Dual-Pane Responsive Layout:
       - Compact Menu Mode (lebar 270px) untuk navigasi hemat ruang.
       - Smooth Expand ke Dual-Pane Workspace (lebar 680px) dengan hairline separator
         ketika sub-item atau halaman aktif diklik.
       - Back button (←) di topbar untuk collapse kembali ke compact mode.
       - Auto-scale responsif (fitWindow) menyesuaikan mobile touch & desktop PC.
       
    2. Deep Stealth Matte Obsidian Theme:
       - Background Obsidian (#0B0E14), TopBar & Sidebar (#0D1118), Cards (#10141E).
       - Hairline Crisp Ice Borders (#222C41) & Glowing Silver accents (#78A0D2).
       - Specular gradient bevel pada active cards & tombol.

    3. Collapsible Accordion Navigation (Sidebar):
       - Multi-tier navigation dengan animasi panah rotasi (→ ke ↓).
       - Blue indicator bullet (#00B4FF) pada sub-item aktif.
       - Floating Scroll Hint Pill ("v Scroll Down" / "^ Scroll Up") otomatis.

    4. Floating Minimize Bubble & Dragging:
       - Draggable floating bubble icon saat window diminimize (drag position memory).
       - Hotkey RightShift untuk menyembunyikan / menampilkan window seketika.
       - Window dragging pada TopBar dengan pembagian koordinat UIScale.

    5. Multi-System Feedback & Toasts:
       - Bottom-Right Toasts: Notifikasi bertumpuk dengan auto-fadeout (showToast).
       - Top-Center Activity Toast Pill: Status bar melayang dengan pulsing dot & badge
         "LIVE ENGINE" untuk menampilkan status aktivitas background.
       - Center Modal Warning: Peringatan modal di tengah layar dengan animasi spring.

    6. Full Component Suite:
       - createSection / sectionLabel (Card container dengan ice indicator bar)
       - toggleRow (Single toggle switch dengan deskripsi opsional)
       - toggleDual (2 toggle switch mandiri berdampingan dalam satu baris)
       - toggleGrid & toggleCell (Grid matriks tombol toggle)
       - sliderRow (Drag slider presisi dengan badge nilai, gradient fill, & suffix)
       - inputRow (Modern text input box dengan focus lost commit)
       - dropdownSingle (Dropdown single-select dengan opsi icon gembok / lock)
       - dropdownMulti (Dropdown multi-select dengan instant search bar & header grup)
       - dropdownDual (2 multi-dropdown berdampingan dengan auto-sync tinggi baris)
       - dualRow (Generic 2-kolom layout container)
       - multiSelectList (Embedded scrollable checkbox list)
       - buttonRow (Tombol stylish dengan gradient specular & hover animation)
       - textRow (Label teks dengan kustomisasi warna)
    
    ----------------------------------------------------------------------------
    CONTOH CARA PAKAI DI SCRIPT BARU:
    ----------------------------------------------------------------------------
    local CompactModern = loadfile("D:/Roblox/NEW UI/Compact Modern/Compact Modern.lua")()
    -- atau: local CompactModern = loadstring(game:HttpGet("..."))()

    local UI = CompactModern.CreateWindow({
        Title       = "Nasi Rendang",
        SubTitle    = "Universal Hub",
        Logo        = "rbxassetid://124947058155926",
        Discord     = "discord.gg/vrzg9YaNPj",
        DiscordUrl  = "https://discord.gg/vrzg9YaNPj",
        KeyText     = "Lifetime", -- opsional (auto-detect dari nr_loader_key.txt)
        BadgeText   = "LIVE ENGINE",
    })

    -- 1. Buat Halaman (Pages)
    local farmPage = UI.makePage("Auto Farm")
    local miscPage = UI.makePage("Misc")

    -- 2. Buat Navigasi Sidebar (navItem)
    UI.navItem("Farm", "Auto Farm", 1, nil, "Automation", {
        { title = "Auto Attack", page = "Auto Farm" },
    })
    UI.navItem("Misc", "Misc", 2, nil, "Settings & Tools")

    -- 3. Isi Komponen (Bisa cara OOP atau cara Fungsional)
    local sec = farmPage:AddSection("Combat Controls", 1)
    farmPage:AddToggle("Kill Aura", false, function(on)
        print("Kill aura:", on)
    end, "Menyerang musuh terdekat otomatis")

    farmPage:AddSlider("Attack Speed", 1, 100, 50, function(val)
        print("Speed:", val)
    end, "%")

    farmPage:AddButton("Reset Character", function()
        game.Players.LocalPlayer.Character:BreakJoints()
    end)
    ============================================================================
]]

-- Services
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local SoundService      = game:GetService("SoundService")
local LocalPlayer       = Players.LocalPlayer

local CompactModern = {}
CompactModern.__index = CompactModern

function CompactModern.CreateWindow(config)
    config = config or {}
    
    local UI = nil
    do
local PanelConns, panelAlive = {}, true
    local function trackConn(c) if c then PanelConns[#PanelConns + 1] = c end return c end

    local hoverSound, clickSound = Instance.new("Sound"), Instance.new("Sound")
    hoverSound.SoundId, hoverSound.Volume = "rbxassetid://10066931761", 0.35
    clickSound.SoundId, clickSound.Volume = "rbxassetid://121348992695732", 0.5
    local function playHover() pcall(function() SoundService:PlayLocalSound(hoverSound) end) end
    local function playClick() pcall(function() SoundService:PlayLocalSound(clickSound) end) end

    local function new(class, props, children)
        local inst = Instance.new(class)
        -- MATIIN AUTO-TRANSLATE ROBLOX.
        -- Pemain non-Inggris ke-translate otomatis, dan label panel ini istilah teknis
        -- ("Auto Steal", "Parasite", "Belly Charge", "Skip Reveal") — kalau diterjemahin
        -- mesin hasilnya ngaco dan gak nyambung lagi sama dokumentasi/diskusi.
        --
        -- Diset PER-OBJEK, bukan cuma di ScreenGui: diuji live, `AutoLocalize=false` di
        -- root TIDAK mengubah properti anaknya (Frame & TextLabel tetap true) dan
        -- semantik pewarisannya gak dijamin. Semua GUI panel lewat helper ini —
        -- Instance.new di luar sini cuma 2 Sound + 1 RemoteEvent, bukan GUI — jadi satu
        -- baris ini nutup seluruh 386 objek teks.
        --
        -- Ditaruh SEBELUM apply props, jadi kalau suatu saat ada objek yang sengaja mau
        -- di-translate tinggal oper AutoLocalize=true di props-nya dan itu yang menang.
        if inst:IsA("GuiBase2d") then
            pcall(function() inst.AutoLocalize = false end)
        end
        for k, v in pairs(props or {}) do inst[k] = v end
        for _, child in ipairs(children or {}) do child.Parent = inst end
        if class == "TextButton" or class == "ImageButton" then
            inst.MouseEnter:Connect(playHover)
            inst.MouseButton1Click:Connect(playClick)
        end
        return inst
    end
    local function corner(r) return new("UICorner", { CornerRadius = UDim.new(0, r or 10) }) end
    local function stroke(c, t)
        return new("UIStroke", { Color = c or Color3.fromRGB(30, 30, 38), Thickness = t or 1, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    end

    local FONT, FONT_BOLD = Enum.Font.BuilderSansMedium, Enum.Font.BuilderSansBold

    local Icons = {
        Logo        = "rbxassetid://124947058155926",
        General     = "rbxassetid://136127143111895",
        Account     = "rbxassetid://104393022470870",
        Changelog   = "rbxassetid://103804716016841",
        Recent      = "rbxassetid://76012717110003",
        Settings    = "rbxassetid://135306776138575",
        Discord     = "rbxassetid://103385895626663",
        Website     = "rbxassetid://105345745320241",
        Config      = "rbxassetid://105075600358691",
        Upgrades    = "rbxassetid://82956444540457",
        FPS         = "rbxassetid://123623357851005",
    }

    local Theme = {
        Background    = Color3.fromRGB(11, 14, 20),      -- #0B0E14 Deep Stealth Matte Obsidian
        Window        = Color3.fromRGB(11, 14, 20),
        TopBar        = Color3.fromRGB(13, 17, 24),      -- #0D1118
        Sidebar       = Color3.fromRGB(13, 17, 24),      -- #0D1118
        Card          = Color3.fromRGB(16, 20, 30),      -- #10141E Obsidian Surface
        Control       = Color3.fromRGB(22, 28, 42),      -- #161C2A Inner Control Surface
        CardHover     = Color3.fromRGB(28, 36, 52),      -- #1C2434
        CardActive    = Color3.fromRGB(36, 46, 68),      -- #242E44
        Border        = Color3.fromRGB(34, 44, 65),      -- #222C41 Crisp Hairline Ice Border
        BorderLight   = Color3.fromRGB(120, 160, 210),   -- #78A0D2 Glowing Ice Silver
        Text          = Color3.fromRGB(255, 255, 255),   -- Pure Crisp White
        SubText       = Color3.fromRGB(130, 150, 180),   -- #8296B4 Muted Silver Slate
        TextSecondary = Color3.fromRGB(145, 165, 192),
        TextDisabled  = Color3.fromRGB(75, 90, 115),     -- #4B5A73 Dim Slate
        Accent        = Color3.fromRGB(240, 248, 255),   -- Frosted Ice White
        AccentDim     = Color3.fromRGB(26, 34, 50),      -- Muted Ice Base
        AccentGlow    = Color3.fromRGB(170, 220, 255),   -- Cyan Frost Tint
        Money         = Color3.fromRGB(160, 225, 255),   -- Cyan Frost Glow
        Success       = Color3.fromRGB(52, 211, 153),
        Danger        = Color3.fromRGB(248, 113, 113),
    }
    if config.Theme and type(config.Theme) == "table" then
        for k, v in pairs(config.Theme) do Theme[k] = v end
    end

    -- PlayerGui DULU: container gethui() ke-lock capability → thread input (klik
    -- dropdown) gak bisa bikin instance di dalemnya → "lacking capability Plugin"
    -- → dropdown area gak bisa ke-populate. PlayerGui gak ada lock-nya.
    -- WaitForChild, BUKAN FindFirstChild. Pas auto-execute lewat loader, script jalan
    -- sangat awal dan PlayerGui sering belum ke-replikasi -> FindFirstChild balik nil ->
    -- panel jatuh ke gethui(). Padahal komentar di atas nyebut sendiri: container gethui()
    -- ke-lock capability, dropdown jadi gak bisa ke-populate. Jadi kejadian itu bukan
    -- fallback yang aman, tapi bug diam-diam yang cuma nimpa pemakai auto-exec.
    -- Timeout 5 detik: kalau PlayerGui beneran gak ada, baru turun ke fallback.
    local CoreParent
    pcall(function() CoreParent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
    if not CoreParent then
        pcall(function() if typeof(gethui) == "function" then CoreParent = gethui() end end)
    end
    if not CoreParent then
        pcall(function()
            local cg = game:GetService("CoreGui")
            CoreParent = (cg and typeof(cloneref) == "function") and cloneref(cg) or cg
        end)
    end
    if not CoreParent then CoreParent = LocalPlayer:WaitForChild("PlayerGui") end

    local guiTag = config.Tag or "COMPACT_MODERN_TAG"
    do
        local seen, roots = {}, { CoreParent }
        pcall(function() if gethui then roots[#roots + 1] = gethui() end end)
        pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
        for _, root in ipairs(roots) do
            if root and not seen[root] then
                seen[root] = true
                pcall(function()
                    for _, g in ipairs(root:GetChildren()) do
                        if g:GetAttribute(guiTag) or g:GetAttribute("SAE_GUI_TAG") or g.Name == "CompactModern_Panel" or g.Name == "StealFix_Panel" then pcall(function() g:Destroy() end) end
                    end
                end)
            end
        end
    end

    local randomGuiName = ""
    for _ = 1, 16 do randomGuiName = randomGuiName .. string.char(math.random(97, 122)) end

    local ScreenGui = new("ScreenGui", { Name = config.GuiName or randomGuiName, Parent = CoreParent, ResetOnSpawn = false,
        IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 })
    ScreenGui:SetAttribute(guiTag, true)
    hoverSound.Parent, clickSound.Parent = ScreenGui, ScreenGui

    -- ===================== UKURAN WINDOW: COMPACT vs PC FULL SIZE =====================
    -- UIScale cuma MEMPERBESAR — isinya ikut kebesaran, jadi rasio konten-vs-jendela
    -- gak berubah dan scroll-nya tetep. Yang bikin scroll ilang itu RUANG LAYOUT-nya,
    -- makanya ukuran Window sendiri yang dinaikin, bukan cuma clamp skalanya.
    --
    -- Area konten = tinggi Window - 68 (topbar 40 + padding). Diukur live DI LEBAR 900
    -- (kunci: lebar naik 650->900 bikin konten Steal turun 798 -> 562, karena barisnya
    -- muat lebih lega jadi gak numpuk ke bawah):
    --   Settings 852 | Eggs 700 | Upgrades 596 | Steal 562 | Predict 554 | Pets 526
    --   Sakura 300 | FPS Boost 260 | Help Others 248
    -- Muat SEMUA butuh tinggi 852+68 = 920 — kegedean, 8 dari 9 halaman jadi separuhnya
    -- ruang kosong. Dipakai 700 (konten 632): 7 halaman muat penuh — Upgrades 596 yang
    -- paling mepet, sisa 36 unit. Eggs (700) & Settings (852) masih scroll.
    -- Knob tinggi: 680 lebih kecil lagi (Upgrades tinggal sisa 16, mepet banget) /
    --              780 Eggs ikut muat / 920 semuanya muat tanpa scroll.
    local isContentOpen = false
    local WIN_MENU_W    = 270
    local WIN_CONTENT_W = 680
    local WIN_H         = 390
    local WIN_COMPACT   = Vector2.new(270, 390)
    local WIN_PC        = Vector2.new(270, 390)
    local PC_ZOOM       = 1.0
    -- Default ikut perangkat: PC (bukan touch) langsung full size.
    local pcFullSize    = not UserInputService.TouchEnabled

    local Window = new("Frame", { Name = "Window", Parent = ScreenGui, AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, WIN_MENU_W, 0, WIN_H), Position = UDim2.new(0.5, 0, 0.52, 0), BackgroundColor3 = Theme.Window,
        BackgroundTransparency = 0, BorderSizePixel = 0, Active = true, ClipsDescendants = true, Visible = true }, {
        corner(18), stroke(Theme.Border, 1.2)
    })

    -- ===================== ANNOUNCEMENT POP-UP (BEFORE MAIN WINDOW) =====================
    local WindowScale = new("UIScale", { Parent = Window })
    local function fitWindow(overrideW)
        local baseW = overrideW or (isContentOpen and WIN_CONTENT_W or WIN_MENU_W)
        local base = Vector2.new(baseW, WIN_H)
        Window.Size = UDim2.new(0, base.X, 0, base.Y)
        local cam = workspace.CurrentCamera
        local vp = (cam and cam.ViewportSize) or Vector2.new(800, 600)
        local s = math.min((vp.X - 20) / base.X, (vp.Y - 20) / base.Y)
        if UserInputService.TouchEnabled then s = s * 0.88 end
        local finalScale = math.clamp(s, 0.25, pcFullSize and PC_ZOOM or 0.88)
        WindowScale:SetAttribute("TargetScale", finalScale)
        WindowScale.Scale = finalScale
    end
    -- AnchorPoint-nya (0.5,0.5) jadi window membesar dari titik tengahnya. Kalau tadinya
    -- di-drag mepet pinggir, pas gede bisa nyembul keluar layar — makanya balikin ke
    -- tengah tiap ganti mode.
    local function centerWindow()
        Window.Position = UDim2.new(0.5, 0, 0.52, 0)
    end
    fitWindow()
    local function hookViewport()
        local cam = workspace.CurrentCamera
        if cam then pcall(function() trackConn(cam:GetPropertyChangedSignal("ViewportSize"):Connect(fitWindow)) end) end
    end
    hookViewport()
    trackConn(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() fitWindow(); hookViewport() end))

    -- ================= WATCHDOG RENDER (perbaikan otomatis) =================
    -- Gejala yang dilaporin: "[StealFix] loaded" ke-print tapi panelnya gak nongol.
    -- Print itu baris TERAKHIR file, jadi script-nya kelar jalan — panelnya kebentuk,
    -- cuma gak kerender. Dua sebab yang mungkin:
    --   1. CoreParent kepilih container yang gak nge-render (race auto-execute)
    --   2. ScreenGui-nya kelindas / ke-orphan sama script lain
    --
    -- Ini benerin SENDIRI. Sengaja gak ada print diagnosa: minta user ngirim log itu
    -- bukan solusi, cuma mindahin masalah ke mereka.
    --
    -- AbsoluteSize dipakai sebagai penanda "kerender": diuji live, GuiObject yang gak
    -- ke-render selalu 0x0, sedangkan yang normal ngasih ukuran asli (688x560).
    -- Dicek 10x sekali sedetik lalu berhenti — cukup buat nutup fase startup, dan gak
    -- ninggalin loop abadi yang muter percuma seumur sesi.
    task.spawn(function()
        for _ = 1, 10 do
            task.wait(1)
            if not panelAlive then return end
            local pg
            pcall(function() pg = LocalPlayer:WaitForChild("PlayerGui", 5) end)
            if not pg then return end

            if not ScreenGui.Parent then
                -- ke-destroy / ke-orphan -> pasang ulang
                pcall(function() ScreenGui.Parent = pg end)
                pcall(fitWindow)
            elseif Window.Visible and Window.AbsoluteSize.X < 1 then
                -- kebentuk tapi 0x0 = parent-nya gak nge-render -> pindahin ke PlayerGui
                if ScreenGui.Parent ~= pg then
                    pcall(function() ScreenGui.Parent = pg end)
                    pcall(fitWindow)
                end
            end
        end
    end)

    local ToastHost = new("Frame", { Name = "Toasts", Parent = ScreenGui, AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -12, 1, -12), Size = UDim2.new(0, 250, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1 }, {
        new("UIListLayout", { Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder })
    })
    local function showToast(text, seconds)
        local card = new("Frame", { Parent = ToastHost, Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Theme.Window,
            BackgroundTransparency = 0.05, BorderSizePixel = 0 }, { corner(8), stroke(Theme.Accent, 1) })
        new("Frame", { Parent = card, Size = UDim2.new(0, 3, 1, -12), Position = UDim2.new(0, 6, 0.5, -16),
            BackgroundColor3 = Theme.Accent, BorderSizePixel = 0 }, { corner(2) })
        local lbl = new("TextLabel", { Parent = card, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -26, 1, 0),
            BackgroundTransparency = 1, Font = FONT, Text = text, TextColor3 = Theme.Text, TextSize = 14,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left })
        local sc = new("UIScale", { Parent = card }); sc.Scale = 0.85
        TweenService:Create(sc, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
        task.delay(seconds or 3, function()
            if not card.Parent then return end
            local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
            TweenService:Create(card, ti, { BackgroundTransparency = 1 }):Play()
            TweenService:Create(card.UIStroke, ti, { Transparency = 1 }):Play()
            TweenService:Create(lbl, ti, { TextTransparency = 1 }):Play()
            task.wait(0.32); if card.Parent then card:Destroy() end
        end)
    end

    -- ==================== FLOATING TOP-CENTER ACTIVITY TOAST PILL ====================
    local ActivityToastPill = new("Frame", {
        Name = "ActivityToastPill",
        Parent = ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, -45),
        Size = UDim2.new(0, 360, 0, 32),
        BackgroundColor3 = Color3.fromRGB(16, 22, 34),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 250,
        Visible = false,
    }, {
        corner(8),
        stroke(Color3.fromRGB(40, 56, 80), 1)
    })
    local ActivityToastStroke = ActivityToastPill:FindFirstChildOfClass("UIStroke")
    if ActivityToastStroke then ActivityToastStroke.Transparency = 1 end

    local ActivityToastDot = new("Frame", {
        Name = "IndicatorDot",
        Parent = ActivityToastPill,
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 12, 0.5, -4),
        BackgroundColor3 = Color3.fromRGB(160, 225, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 251
    }, { corner(4) })

    local ActivityToastLabel = new("TextLabel", {
        Name = "ActivityLabel",
        Parent = ActivityToastPill,
        Size = UDim2.new(1, -125, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Font = FONT,
        Text = "idle",
        TextColor3 = Color3.fromRGB(245, 250, 255),
        TextTransparency = 1,
        TextSize = 12.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 251
    })

    local ActivityToastBadge = new("TextLabel", {
        Name = "EngineBadge",
        Parent = ActivityToastPill,
        Size = UDim2.new(0, 85, 1, 0),
        Position = UDim2.new(1, -97, 0, 0),
        BackgroundTransparency = 1,
        Font = FONT_BOLD,
        Text = config.BadgeText or "LIVE ENGINE",
        TextColor3 = Color3.fromRGB(140, 215, 255),
        TextTransparency = 1,
        TextSize = 9.5,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 251
    })

    local ActivityToastDismissBtn = new("TextButton", {
        Name = "DismissButton",
        Parent = ActivityToastPill,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 252
    })

    local activityToastSeq = 0
    local isActivityToastShown = false

    local function hideActivityToast()
        if not isActivityToastShown then return end
        isActivityToastShown = false
        activityToastSeq = activityToastSeq + 1
        local tiOut = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local pTween = TweenService:Create(ActivityToastPill, tiOut, {
            Position = UDim2.new(0.5, 0, 0, -45),
            BackgroundTransparency = 1
        })
        if ActivityToastStroke then
            TweenService:Create(ActivityToastStroke, tiOut, { Transparency = 1 }):Play()
        end
        TweenService:Create(ActivityToastDot, tiOut, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(ActivityToastLabel, tiOut, { TextTransparency = 1 }):Play()
        TweenService:Create(ActivityToastBadge, tiOut, { TextTransparency = 1 }):Play()
        pTween:Play()
        pTween.Completed:Connect(function()
            if not isActivityToastShown then
                ActivityToastPill.Visible = false
            end
        end)
    end

    ActivityToastDismissBtn.MouseButton1Click:Connect(hideActivityToast)

    local function showActivityToast(text, duration)
        if not text or text == "" or text == "idle" then return end
        duration = tonumber(duration) or 5
        activityToastSeq = activityToastSeq + 1
        local currentSeq = activityToastSeq

        ActivityToastLabel.Text = tostring(text)
        ActivityToastPill.Visible = true

        if isActivityToastShown then
            local tiPulse = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tiBack = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            TweenService:Create(ActivityToastDot, tiPulse, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            task.delay(0.12, function()
                if isActivityToastShown and ActivityToastDot.Parent then
                    TweenService:Create(ActivityToastDot, tiBack, { BackgroundColor3 = Color3.fromRGB(160, 225, 255) }):Play()
                end
            end)
        else
            isActivityToastShown = true
            ActivityToastPill.Position = UDim2.new(0.5, 0, 0, -45)
            ActivityToastPill.BackgroundTransparency = 1
            if ActivityToastStroke then ActivityToastStroke.Transparency = 1 end
            ActivityToastDot.BackgroundTransparency = 1
            ActivityToastLabel.TextTransparency = 1
            ActivityToastBadge.TextTransparency = 1

            local tiIn = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            TweenService:Create(ActivityToastPill, tiIn, {
                Position = UDim2.new(0.5, 0, 0, 16),
                BackgroundTransparency = 0.1
            }):Play()
            if ActivityToastStroke then
                TweenService:Create(ActivityToastStroke, tiIn, { Transparency = 0 }):Play()
            end
            TweenService:Create(ActivityToastDot, tiIn, { BackgroundTransparency = 0 }):Play()
            TweenService:Create(ActivityToastLabel, tiIn, { TextTransparency = 0 }):Play()
            TweenService:Create(ActivityToastBadge, tiIn, { TextTransparency = 0 }):Play()
        end

        task.delay(duration, function()
            if activityToastSeq == currentSeq and isActivityToastShown then
                hideActivityToast()
            end
        end)
    end

    local function showCenterModalWarning(title, message, duration)
        local modal = new("Frame", { Parent = Window, Size = UDim2.new(0, 380, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(24, 16, 20), BackgroundTransparency = 0.05, BorderSizePixel = 0, ZIndex = 80 }, {
            corner(12),
            stroke(Color3.fromRGB(255, 75, 75), 1.5),
            new("UIPadding", { PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }),
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center })
        })

        local topRow = new("Frame", { Parent = modal, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = 1 }, {
            new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Center })
        })
        new("TextLabel", { Parent = topRow, Size = UDim2.new(0, 16, 0, 16), BackgroundTransparency = 1, Font = FONT_BOLD,
            Text = "!", TextColor3 = Color3.fromRGB(255, 75, 75), TextSize = 16 })
        new("TextLabel", { Parent = topRow, Size = UDim2.new(0, 300, 1, 0), BackgroundTransparency = 1, Font = FONT_BOLD,
            Text = title or "WARNING", TextColor3 = Color3.fromRGB(255, 95, 95), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Center })

        new("TextLabel", { Parent = modal, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, Font = FONT, Text = message, TextColor3 = Color3.fromRGB(240, 240, 245),
            TextSize = 14, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = 2 })

        local sc = new("UIScale", { Parent = modal }); sc.Scale = 0.8
        TweenService:Create(sc, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

        task.delay(duration or 3, function()
            if not modal.Parent then return end
            local ti = TweenInfo.new(0.25, Enum.EasingStyle.Quad)
            TweenService:Create(sc, ti, { Scale = 0.8 }):Play()
            TweenService:Create(modal, ti, { BackgroundTransparency = 1 }):Play()
            task.wait(0.26)
            if modal.Parent then modal:Destroy() end
        end)
    end

    local TopBar = new("Frame", { Name = "TopBar", Parent = Window, Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 20 })

    -- Horizontal divider line under title (hairline separator)
    local TopDivider = new("Frame", { Name = "TopDivider", Parent = TopBar, Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Color3.fromRGB(36, 48, 68), BackgroundTransparency = 0.2,
        BorderSizePixel = 0, ZIndex = 22 })

    -- Tombol panah kembali (←) di kiri atas persis seperti di mockup referensi
    local BackBtn = new("TextButton", { Name = "BackBtn", Parent = TopBar, Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 10, 0.5, -12),
        BackgroundTransparency = 1, AutoButtonColor = false, Text = "←", Font = FONT_BOLD, TextSize = 17,
        TextColor3 = Color3.fromRGB(160, 185, 215), ZIndex = 23 })

    -- Container Judul: [Logo NRL] [Nasi Rendang] [Steal an Egg]
    local TitleGroup = new("Frame", { Name = "TitleGroup", Parent = TopBar, Size = UDim2.new(1, -78, 1, 0),
        Position = UDim2.new(0, 40, 0, 0), BackgroundTransparency = 1, ZIndex = 23 }, {
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 9) })
    })

    local LogoIcon = new("ImageLabel", { Parent = TitleGroup, LayoutOrder = 1, Size = UDim2.fromOffset(26, 26),
        BackgroundTransparency = 1, Image = config.Logo or Icons.Logo, ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit, ResampleMode = Enum.ResamplerMode.Default, ZIndex = 24 })

    local TopTitle = new("TextLabel", { Parent = TitleGroup, LayoutOrder = 2, Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Font = FONT_BOLD, Text = config.Title or "Nasi Rendang",
        TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 24 })

    local SubTitle = new("TextLabel", { Parent = TitleGroup, LayoutOrder = 3, Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Font = FONT, Text = config.SubTitle or "Compact Modern",
        TextColor3 = Color3.fromRGB(140, 155, 175), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 24 })

    -- Compatibility references agar loop ticker tidak error
    local CenterNav = new("Frame", { Parent = TopBar, Visible = false })
    local setTopActiveTab = function() end
    local Pill = new("Frame", { Parent = TopBar, Visible = false })
    local PillLabel = new("TextLabel", { Parent = Pill, Text = "" })

    local WindowControls = new("Frame", { Parent = TopBar, Size = UDim2.new(0, 36, 1, 0), Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1, ZIndex = 22 }, {
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4) })
    })

    local function createWinBtn(symbolText, isClose)
        local btn = new("TextButton", { Parent = WindowControls, Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Card,
            BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, Text = symbolText, Font = FONT_BOLD,
            TextColor3 = Theme.TextSecondary, TextSize = 13, ZIndex = 23 }, { corner(6) })
        btn.MouseEnter:Connect(function()
            local bg = isClose and Theme.Danger or Theme.CardHover
            TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundColor3 = bg, BackgroundTransparency = isClose and 0.2 or 0, TextColor3 = Theme.Text }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 1, TextColor3 = Theme.TextSecondary }):Play()
        end)
        return btn
    end

    local CloseButton = createWinBtn("x", true)
    local MinButton = BackBtn

    local SIDEBAR_W = 270
    local Sidebar = new("Frame", { Name = "Sidebar", Parent = Window, Size = UDim2.new(0, 270, 1, -46),
        Position = UDim2.new(0, 0, 0, 46), BackgroundTransparency = 1,
        BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 10 })

    local CollapseBtn = new("TextButton", { Parent = Sidebar, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -26, 0, 6),
        BackgroundTransparency = 1, Text = "<", Font = FONT_BOLD, TextSize = 13, TextColor3 = Theme.SubText, ZIndex = 12, Visible = false })
    local isCollapsed = false

    local NavScroll = new("ScrollingFrame", { Parent = Sidebar, Size = UDim2.new(1, 0, 1, -96), Position = UDim2.new(0, 0, 0, 4),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 12 })

    local NavHighlight = new("Frame", { Parent = NavScroll, BackgroundColor3 = Color3.fromRGB(22, 29, 44), BackgroundTransparency = 0,
        BorderSizePixel = 0, ZIndex = 13, Size = UDim2.new(1, -12, 0, 32), Position = UDim2.new(0, 6, 0, 4), Visible = false }, {
        corner(8),
        stroke(Color3.fromRGB(55, 75, 110), 1),
    })

    local NavList = new("Frame", { Parent = NavScroll, Name = "NavList", Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 14 }, {
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) }),
        new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) })
    })

    -- Scroll Hint Indicator Pill untuk Sidebar
    local NavScrollHint = new("TextButton", { Parent = Sidebar, Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 1, -112),
        BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 0.2, AutoButtonColor = false, Text = "", ZIndex = 20, Visible = false }, {
        corner(9), stroke(Theme.Border, 1)
    })
    local NavHintIcon = new("TextLabel", { Parent = NavScrollHint, Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1, Font = FONT_BOLD, Text = "v", TextColor3 = Theme.SubText, TextSize = 12, ZIndex = 21 })
    local NavHintLabel = new("TextLabel", { Parent = NavScrollHint, Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1, Font = FONT, Text = "Scroll Down", TextColor3 = Theme.SubText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21 })

    local function updateNavScrollHint()
        local maxScroll = math.max(0, NavScroll.AbsoluteCanvasSize.Y - NavScroll.AbsoluteWindowSize.Y)
        if maxScroll > 10 then
            NavScrollHint.Visible = not isCollapsed
            if NavScroll.CanvasPosition.Y >= maxScroll - 6 then
                NavHintIcon.Text = "^"
                NavHintLabel.Text = "Scroll Up"
                NavScrollHint.Position = UDim2.new(0, 10, 0, 6)
            else
                NavHintIcon.Text = "v"
                NavHintLabel.Text = "Scroll Down"
                NavScrollHint.Position = UDim2.new(0, 10, 1, -112)
            end
        else
            NavScrollHint.Visible = false
        end
    end
    trackConn(NavScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(updateNavScrollHint))
    trackConn(NavScroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateNavScrollHint))
    NavScrollHint.MouseButton1Click:Connect(function()
        local maxScroll = math.max(0, NavScroll.AbsoluteCanvasSize.Y - NavScroll.AbsoluteWindowSize.Y)
        local targetY = (NavScroll.CanvasPosition.Y >= maxScroll - 6) and 0 or maxScroll
        TweenService:Create(NavScroll, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { CanvasPosition = Vector2.new(0, targetY) }):Play()
    end)

    local FooterFrame = new("Frame", { Parent = Sidebar, Size = UDim2.new(1, -28, 0, 80), Position = UDim2.new(0, 14, 1, -90),
        BackgroundColor3 = Color3.fromRGB(15, 20, 30), BackgroundTransparency = 0.5, ZIndex = 12 }, {
        corner(12),
        stroke(Color3.fromRGB(36, 48, 68), 1),
        new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
        new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
    })

    local function addFooterLink(asset, title, sub, url)
        local btn = new("TextButton", { Parent = FooterFrame, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 1, BackgroundColor3 = Theme.CardHover,
            BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 13 }, { corner(6) })
        local icon = new("ImageLabel", { Parent = btn, Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 8, 0.5, -7),
            BackgroundTransparency = 1, Image = asset, ImageColor3 = Theme.SubText, ZIndex = 14 })
        local lblTitle = new("TextLabel", { Parent = btn, Size = UDim2.new(1, -30, 0, 12), Position = UDim2.new(0, 28, 0, 2),
            BackgroundTransparency = 1, Font = FONT_BOLD, Text = title, TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })
        local lblSub = new("TextLabel", { Parent = btn, Size = UDim2.new(1, -30, 0, 10), Position = UDim2.new(0, 28, 0, 14),
            BackgroundTransparency = 1, Font = FONT, Text = sub, TextColor3 = Theme.SubText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 0.6 }):Play()
            TweenService:Create(icon, TweenInfo.new(0.18), { ImageColor3 = Theme.Text }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(icon, TweenInfo.new(0.18), { ImageColor3 = Theme.SubText }):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            if url and setclipboard then
                pcall(function() setclipboard(url) end)
            end
            showToast("Discord Link Copied")
        end)
    end
    addFooterLink(config.DiscordIcon or Icons.Discord, config.DiscordTitle or "Discord", config.Discord or "discord.gg/vrzg9YaNPj", config.DiscordUrl or "https://discord.gg/vrzg9YaNPj")

    -- Key detection from nr_loader_key.txt
    local keyTitleText = "nrlscript"
    local keyTitleColor = Theme.Text
    local keyTitleFont = FONT_BOLD

    pcall(function()
        local rawKey = nil
        if typeof(isfile) == "function" and isfile("nr_loader_key.txt") and typeof(readfile) == "function" then
            rawKey = readfile("nr_loader_key.txt")
        end
        if rawKey and rawKey ~= "" then
            local lower = rawKey:lower()
            if lower:find("lifetime") then
                keyTitleText = "Lifetime"
                keyTitleColor = Color3.fromRGB(0, 180, 255) -- Ocean Blue
                keyTitleFont = FONT_BOLD
            elseif lower:find("premium") then
                keyTitleText = "Premium"
                keyTitleColor = Color3.fromRGB(255, 215, 0) -- Gold / Yellow
                keyTitleFont = FONT_BOLD
            elseif lower:find("gold") then
                keyTitleText = "Gold"
                keyTitleColor = Color3.fromRGB(255, 215, 0) -- Gold / Yellow
                keyTitleFont = FONT_BOLD
            else
                local keyStr = rawKey:match("^([^|\r\n]+)") or rawKey
                keyTitleText = keyStr
                keyTitleColor = Color3.fromRGB(255, 255, 255) -- White
                keyTitleFont = FONT_BOLD
            end
        end
    end)

    local UserCard = new("Frame", { Parent = FooterFrame, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 2, BackgroundColor3 = Theme.Control,
        BackgroundTransparency = 0.5, ZIndex = 13 }, { corner(8), stroke(Theme.Border, 1) })
    local Av = new("Frame", { Parent = UserCard, Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 6, 0.5, -12),
        BackgroundColor3 = Theme.Border, ClipsDescendants = true, ZIndex = 14 }, { corner(12) })
    
    local AvImg = new("ImageLabel", { Parent = Av, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=48&h=48",
        ScaleType = Enum.ScaleType.Fit, ZIndex = 15 })

    -- Fallback avatar fetch jika rbxthumb perlu async
    task.spawn(function()
        pcall(function()
            local thumb = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            if thumb and AvImg then AvImg.Image = thumb end
        end)
    end)

    new("TextLabel", { Parent = UserCard, Size = UDim2.new(1, -38, 0, 13), Position = UDim2.new(0, 36, 0, 4),
        BackgroundTransparency = 1, Font = keyTitleFont, Text = keyTitleText, TextColor3 = keyTitleColor, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14 })
    new("TextLabel", { Parent = UserCard, Size = UDim2.new(1, -38, 0, 11), Position = UDim2.new(0, 36, 0, 18),
        BackgroundTransparency = 1, Font = FONT, Text = "Signed In", TextColor3 = Theme.SubText, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14 })

    local TOGGLE_TWEEN = TweenInfo.new(0.16, Enum.EasingStyle.Quad)
    local NAV_TWEEN    = TweenInfo.new(0.22, Enum.EasingStyle.Quad)
    local PAGE_TWEEN   = TweenInfo.new(0.24, Enum.EasingStyle.Quint)

    local Pages, NavButtons = {}, {}
    local NavCallbacks = {}
    local activeNav

    -- Highlight geser (tween tetap ada). Posisi dihitung LANGSUNG dari konstanta layout
    -- NavList (padding atas 4, padding kiri/kanan 6, tinggi item 32, jarak 3) + LayoutOrder
    -- tombolnya. Dulu dihitung dari AbsolutePosition + CanvasPosition + bagi UIScale — tiga
    -- nilai yang bisa belum settle -> kotaknya meleset dari baris (misalign). Cara ini
    -- deterministik: ga peduli layout udah settle, nav lagi di-scroll, atau window di-resize.
    local NAV_PAD_TOP, NAV_PAD_X, NAV_ITEM_H, NAV_ITEM_GAP = 4, 6, 32, 3
    local function moveHighlightTo(btn, animate)
        if not btn or not btn.Parent then return end
        NavHighlight.Visible = true
        local idx = math.max(1, btn.LayoutOrder)
        local y = NAV_PAD_TOP + (idx - 1) * (NAV_ITEM_H + NAV_ITEM_GAP)
        local pos = UDim2.new(0, NAV_PAD_X, 0, y)
        local size = UDim2.new(1, -NAV_PAD_X * 2, 0, NAV_ITEM_H)
        if animate then TweenService:Create(NavHighlight, NAV_TWEEN, { Position = pos, Size = size }):Play()
        else NavHighlight.Position = pos; NavHighlight.Size = size end
    end

    local activePageName = nil
    local SubNavCallbacks = {}
    local activeSubNavPage = nil
    local MenuControllers = {}
    local currentOpenMenu = nil
    local ColDivider, ContentHost
    local openContentWindow, closeContentWindow

    local function selectSubNav(pageName)
        activeSubNavPage = pageName
        for pn, cb in pairs(SubNavCallbacks) do
            cb(pn == pageName, true)
        end
    end

    local function clearActiveSubItem()
        activeSubNavPage = nil
        for _, cb in pairs(SubNavCallbacks) do
            cb(false, true)
        end
    end

    local function activateMenu(name)
        local ctrl = MenuControllers[name]
        if not ctrl then return end

        if currentOpenMenu == name then
            if ctrl.hasSub then
                -- Menu with sub-items: toggle dropdown open / close
                if ctrl.isDropdownOpen then
                    -- Currently open -> collapse dropdown
                    ctrl.setDropdown(false, true)
                    clearActiveSubItem()
                    if isContentOpen then
                        closeContentWindow()
                    end
                else
                    -- Currently collapsed -> open dropdown
                    ctrl.setDropdown(true, true)
                end
            else
                -- Direct menu clicked again -> toggle close
                ctrl.close(true)
                currentOpenMenu = nil
                if isContentOpen then
                    closeContentWindow()
                end
            end
        else
            -- Clicked different menu -> close previous completely
            if currentOpenMenu and MenuControllers[currentOpenMenu] then
                MenuControllers[currentOpenMenu].close(true)
            end
            clearActiveSubItem()

            currentOpenMenu = name
            ctrl.open(true)

            if not ctrl.hasSub then
                openContentWindow(ctrl.pageName or name)
            else
                if isContentOpen then
                    closeContentWindow()
                end
            end
        end
    end

    local function switchPage(name)
        if UI and UI.OnPageSwitch then
            pcall(UI.OnPageSwitch, name, Pages)
        end
        if name == "The Rift Event" and not Pages["The Rift Event"] then
            local loader = (UI and UI.loadRiftModule) or (UIX and UIX.loadRiftModule)
            if loader then loader() end
        elseif name == "Ride Guard" and not Pages["Ride Guard"] then
            local loader = (UI and UI.loadRideGuardModule) or (UIX and UIX.loadRideGuardModule)
            if loader then loader() end
        end
        activePageName = name
        for pn, pg in pairs(Pages) do if pn ~= name then pg.Visible = false end end
        local target = Pages[name]
        if target then
            target.Position = UDim2.new(0, 18, 0, 0); target.Visible = true
            TweenService:Create(target, PAGE_TWEEN, { Position = UDim2.new(0, 0, 0, 0) }):Play()
            if name == "Predict" and UIX and UIX.refreshPredict then
                task.spawn(UIX.refreshPredict)
            end
        end

        -- Sync center nav top bar indicator
        if setTopActiveTab then
            if name == "Settings" then setTopActiveTab(1)
            elseif name == "Steal" or name == "Steal Tools" then setTopActiveTab(2)
            elseif name == "FPS Boost" then setTopActiveTab(3)
            end
        end
    end

    openContentWindow = function(pageName)
        isContentOpen = true
        if ColDivider then ColDivider.Visible = true end
        if ContentHost then
            ContentHost.Visible = true
            ContentHost.Position = UDim2.new(0, 240, 0, 46)
        end

        if UI and UI.OnPageSwitch then
            pcall(UI.OnPageSwitch, pageName, Pages)
        end
        if pageName == "The Rift Event" and not Pages["The Rift Event"] then
            local loader = (UI and UI.loadRiftModule) or (UIX and UIX.loadRiftModule)
            if loader then loader() end
        elseif pageName == "Ride Guard" and not Pages["Ride Guard"] then
            local loader = (UI and UI.loadRideGuardModule) or (UIX and UIX.loadRideGuardModule)
            if loader then loader() end
        end

        switchPage(pageName)

        local cam = workspace.CurrentCamera
        local vp = (cam and cam.ViewportSize) or Vector2.new(800, 600)
        local s = math.min((vp.X - 20) / WIN_CONTENT_W, (vp.Y - 20) / WIN_H)
        if UserInputService.TouchEnabled then s = s * 0.88 end
        local finalScale = math.clamp(s, 0.25, pcFullSize and PC_ZOOM or 0.88)
        WindowScale:SetAttribute("TargetScale", finalScale)
        TweenService:Create(WindowScale, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Scale = finalScale }):Play()

        local winTween = TweenInfo.new(0.32, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        TweenService:Create(Window, winTween, { Size = UDim2.new(0, WIN_CONTENT_W, 0, WIN_H) }):Play()
        if ContentHost then
            TweenService:Create(ContentHost, winTween, { Position = UDim2.new(0, 270, 0, 46) }):Play()
        end
    end

    closeContentWindow = function()
        if not isContentOpen then return end
        isContentOpen = false
        activePageName = nil

        local cam = workspace.CurrentCamera
        local vp = (cam and cam.ViewportSize) or Vector2.new(800, 600)
        local s = math.min((vp.X - 20) / WIN_MENU_W, (vp.Y - 20) / WIN_H)
        if UserInputService.TouchEnabled then s = s * 0.88 end
        local finalScale = math.clamp(s, 0.25, pcFullSize and PC_ZOOM or 0.88)
        WindowScale:SetAttribute("TargetScale", finalScale)
        TweenService:Create(WindowScale, TweenInfo.new(0.26, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Scale = finalScale }):Play()

        local winTween = TweenInfo.new(0.28, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        TweenService:Create(Window, winTween, { Size = UDim2.new(0, WIN_MENU_W, 0, WIN_H) }):Play()
        if ContentHost then
            TweenService:Create(ContentHost, winTween, { Position = UDim2.new(0, 240, 0, 46) }):Play()
        end

        task.delay(0.28, function()
            if not isContentOpen then
                if ContentHost then ContentHost.Visible = false end
                if ColDivider then ColDivider.Visible = false end
            end
        end)
    end

    CenterNav.Visible = false
    local function navItem(text, pageName, order, icon, subText, subItems)
        local hasSub = subItems and #subItems > 0
        local btn = new("TextButton", { Parent = NavList, Name = text .. "Btn", Size = UDim2.new(1, 0, 0, 32), LayoutOrder = order,
            BackgroundColor3 = Color3.fromRGB(24, 32, 44), BackgroundTransparency = 1, AutoButtonColor = false, Text = "",
            ClipsDescendants = true, ZIndex = 15 }, {
            corner(14),
            stroke(Color3.fromRGB(65, 88, 122), 1.1)
        })

        local btnStroke = btn:FindFirstChildOfClass("UIStroke")
        if btnStroke then btnStroke.Transparency = 1 end

        local btnGrad = new("UIGradient", { Parent = btn, Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 56, 74)),
                ColorSequenceKeypoint.new(0.35, Color3.fromRGB(28, 36, 48)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 20, 28))
            }),
            Enabled = false
        })

        -- Top specular highlight hairline (seen on top of active card in image 2)
        local topBevel = new("Frame", { Parent = btn, Size = UDim2.new(1, -20, 0, 1.5), Position = UDim2.new(0, 10, 0, 1),
            BackgroundColor3 = Color3.fromRGB(215, 235, 255), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 16 }, {
            corner(1),
            new("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.2, 0.2),
                    NumberSequenceKeypoint.new(0.8, 0.2),
                    NumberSequenceKeypoint.new(1, 1)
                })
            })
        })

        -- Circular badge on the right (with arrow icon)
        local badge = new("Frame", { Parent = btn, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -40, 0.5, -14),
            BackgroundColor3 = Color3.fromRGB(34, 44, 60), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 16 }, {
            corner(14),
            stroke(Color3.fromRGB(75, 95, 128), 1)
        })
        local badgeStroke = badge:FindFirstChildOfClass("UIStroke")
        if badgeStroke then badgeStroke.Transparency = 1 end
        local badgeScale = new("UIScale", { Parent = badge, Scale = 0.6 })
        local badgeArrow = new("TextLabel", { Parent = badge, Size = UDim2.fromScale(1, 1), Position = UDim2.new(0, 0, 0, -1),
            BackgroundTransparency = 1, Font = FONT_BOLD, Text = "→", TextSize = 13, TextColor3 = Color3.fromRGB(225, 240, 255), TextTransparency = 1, ZIndex = 17 })

        local lbl = new("TextLabel", { Parent = btn, Name = "Label", Size = UDim2.new(1, -32, 0, 20), Position = UDim2.new(0, 16, 0.5, -10),
            BackgroundTransparency = 1, Font = FONT_BOLD, Text = text, TextSize = 15, TextColor3 = Color3.fromRGB(130, 148, 172),
            ZIndex = 16, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })

        local subLbl = new("TextLabel", { Parent = btn, Name = "SubLabel", Size = UDim2.new(1, -64, 0, 13), Position = UDim2.new(0, 16, 0, 34),
            BackgroundTransparency = 1, Font = FONT, Text = subText or "", TextSize = 11, TextColor3 = Color3.fromRGB(135, 152, 175), TextTransparency = 1,
            ZIndex = 16, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Visible = false })

        local isCurrentActive = false

        local function setActiveState(active, animate)
            isCurrentActive = active
            if active then
                lbl.Font = FONT_BOLD
                lbl.TextSize = 14.5
                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                btnGrad.Enabled = true
                topBevel.Visible = true
                subLbl.Visible = true
                badge.Visible = true

                if animate then
                    TweenService:Create(btn, TweenInfo.new(0.24, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, 56),
                        BackgroundTransparency = 0
                    }):Play()
                    if btnStroke then
                        TweenService:Create(btnStroke, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
                            Transparency = 0.15
                        }):Play()
                    end
                    TweenService:Create(topBevel, TweenInfo.new(0.24, Enum.EasingStyle.Quad), {
                        BackgroundTransparency = 0.35
                    }):Play()
                    TweenService:Create(lbl, TweenInfo.new(0.24, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 16, 0, 9),
                        Size = UDim2.new(1, -64, 0, 16),
                        TextColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                    subLbl.Position = UDim2.new(0, 16, 0, 34)
                    subLbl.TextTransparency = 1
                    TweenService:Create(subLbl, TweenInfo.new(0.24, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 16, 0, 29),
                        TextTransparency = 0
                    }):Play()
                    badgeScale.Scale = 0.5
                    badge.BackgroundTransparency = 1
                    badgeArrow.TextTransparency = 1
                    if badgeStroke then badgeStroke.Transparency = 1 end
                    TweenService:Create(badgeScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Scale = 1.0
                    }):Play()
                    TweenService:Create(badge, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
                        BackgroundTransparency = 0.3
                    }):Play()
                    TweenService:Create(badgeArrow, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
                        TextTransparency = 0
                    }):Play()
                    if badgeStroke then
                        TweenService:Create(badgeStroke, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
                            Transparency = 0.2
                        }):Play()
                    end
                else
                    btn.Size = UDim2.new(1, 0, 0, 56)
                    btn.BackgroundTransparency = 0
                    if btnStroke then
                        btnStroke.Transparency = 0.15
                        btnStroke.Color = Color3.fromRGB(65, 88, 122)
                    end
                    topBevel.BackgroundTransparency = 0.35
                    lbl.Position = UDim2.new(0, 16, 0, 9)
                    lbl.Size = UDim2.new(1, -64, 0, 16)
                    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    subLbl.Position = UDim2.new(0, 16, 0, 29)
                    subLbl.TextTransparency = 0
                    badgeScale.Scale = 1.0
                    badge.BackgroundTransparency = 0.3
                    badgeArrow.TextTransparency = 0
                    if badgeStroke then badgeStroke.Transparency = 0.2 end
                end
            else
                lbl.Font = FONT_BOLD
                lbl.TextSize = 15

                if animate then
                    TweenService:Create(btn, TweenInfo.new(0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, 32),
                        BackgroundTransparency = 1
                    }):Play()
                    if btnStroke then
                        TweenService:Create(btnStroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                            Transparency = 1
                        }):Play()
                    end
                    TweenService:Create(topBevel, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                        BackgroundTransparency = 1
                    }):Play()
                    TweenService:Create(lbl, TweenInfo.new(0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 16, 0.5, -10),
                        Size = UDim2.new(1, -32, 0, 20),
                        TextColor3 = Color3.fromRGB(130, 148, 172)
                    }):Play()
                    TweenService:Create(subLbl, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                        Position = UDim2.new(0, 16, 0, 34),
                        TextTransparency = 1
                    }):Play()
                    TweenService:Create(badgeScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        Scale = 0.6
                    }):Play()
                    TweenService:Create(badge, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                        BackgroundTransparency = 1
                    }):Play()
                    TweenService:Create(badgeArrow, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                        TextTransparency = 1
                    }):Play()
                    if badgeStroke then
                        TweenService:Create(badgeStroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                            Transparency = 1
                        }):Play()
                    end
                    task.delay(0.22, function()
                        if not isCurrentActive then
                            topBevel.Visible = false
                            subLbl.Visible = false
                            badge.Visible = false
                            btnGrad.Enabled = false
                        end
                    end)
                else
                    btn.Size = UDim2.new(1, 0, 0, 32)
                    btn.BackgroundTransparency = 1
                    btnGrad.Enabled = false
                    if btnStroke then btnStroke.Transparency = 1 end
                    topBevel.Visible = false
                    topBevel.BackgroundTransparency = 1
                    lbl.Position = UDim2.new(0, 16, 0.5, -10)
                    lbl.Size = UDim2.new(1, -32, 0, 20)
                    lbl.TextColor3 = Color3.fromRGB(130, 148, 172)
                    subLbl.Visible = false
                    subLbl.TextTransparency = 1
                    badge.Visible = false
                    badgeScale.Scale = 1.0
                    badge.BackgroundTransparency = 1
                    badgeArrow.TextTransparency = 1
                    if badgeStroke then badgeStroke.Transparency = 1 end
                end
            end
        end

        -- Sub-menu accordion container
        local subContainer = nil
        local isAccordionOpen = false
        local targetSubH = 0

        if hasSub then
            targetSubH = #subItems * 30 + 4
            subContainer = new("Frame", { Parent = NavList, Name = text .. "SubList",
                Size = UDim2.new(1, 0, 0, 0), LayoutOrder = order + 1, Visible = false,
                BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 14 }, {
                new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }),
                new("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2),
                    PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 10) })
            })

            for subIdx, subData in ipairs(subItems) do
                local subBtn = new("TextButton", { Parent = subContainer, Name = subData.title,
                    Size = UDim2.new(1, 0, 0, 26), LayoutOrder = subIdx,
                    BackgroundColor3 = Color3.fromRGB(24, 34, 50), BackgroundTransparency = 1,
                    AutoButtonColor = false, Text = "", ClipsDescendants = true, ZIndex = 15 }, {
                    corner(8)
                })

                local bullet = new("Frame", { Parent = subBtn, Size = UDim2.fromOffset(5, 5),
                    Position = UDim2.new(0, 8, 0.5, -2.5), BackgroundColor3 = Color3.fromRGB(80, 110, 150),
                    BorderSizePixel = 0, ZIndex = 16 }, {
                    corner(3)
                })

                local subLabel = new("TextLabel", { Parent = subBtn, Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Font = FONT_BOLD,
                    Text = subData.title, TextSize = 13.5, TextColor3 = Color3.fromRGB(130, 148, 172),
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 16 })

                local isSubActive = false

                local function setSubActive(active, animate)
                    isSubActive = active
                    if active then
                        subLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        bullet.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
                        if animate then
                            TweenService:Create(subBtn, TweenInfo.new(0.18), { BackgroundTransparency = 0.35 }):Play()
                        else
                            subBtn.BackgroundTransparency = 0.35
                        end
                    else
                        subLabel.TextColor3 = Color3.fromRGB(130, 148, 172)
                        bullet.BackgroundColor3 = Color3.fromRGB(80, 110, 150)
                        if animate then
                            TweenService:Create(subBtn, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
                        else
                            subBtn.BackgroundTransparency = 1
                        end
                    end
                end

                subBtn.MouseEnter:Connect(function()
                    if not isSubActive then
                        TweenService:Create(subLabel, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(220, 238, 255) }):Play()
                        TweenService:Create(bullet, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(130, 175, 230) }):Play()
                    end
                end)

                subBtn.MouseLeave:Connect(function()
                    if not isSubActive then
                        TweenService:Create(subLabel, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(130, 148, 172) }):Play()
                        TweenService:Create(bullet, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(80, 110, 150) }):Play()
                    end
                end)

                subBtn.MouseButton1Click:Connect(function()
                    selectSubNav(subData.page)
                    openContentWindow(subData.page)
                end)

                SubNavCallbacks[subData.page] = setSubActive
            end

        end

        MenuControllers[text] = {
            hasSub = hasSub,
            pageName = pageName,
            isDropdownOpen = false,
            setActiveCard = function(active, animate)
                setActiveState(active, animate)
                if not active then
                    if hasSub and subContainer then
                        subContainer.Size = UDim2.new(1, 0, 0, 0)
                        subContainer.Visible = false
                        badgeArrow.Text = "→"
                    end
                    MenuControllers[text].isDropdownOpen = false
                end
            end,
            setDropdown = function(open, animate)
                if not hasSub or not subContainer then return end
                MenuControllers[text].isDropdownOpen = open
                badgeArrow.Text = open and "↓" or "→"
                if open then
                    subContainer.Visible = true
                    if animate then
                        TweenService:Create(subContainer, TweenInfo.new(0.24, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, 0, 0, targetSubH)
                        }):Play()
                    else
                        subContainer.Size = UDim2.new(1, 0, 0, targetSubH)
                    end
                else
                    if animate then
                        local tw = TweenService:Create(subContainer, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
                            Size = UDim2.new(1, 0, 0, 0)
                        })
                        tw:Play()
                        task.delay(0.2, function()
                            if not MenuControllers[text].isDropdownOpen then
                                subContainer.Visible = false
                            end
                        end)
                    else
                        subContainer.Size = UDim2.new(1, 0, 0, 0)
                        subContainer.Visible = false
                    end
                end
            end,
            open = function(animate)
                MenuControllers[text].setActiveCard(true, animate)
                if hasSub then
                    MenuControllers[text].setDropdown(true, animate)
                else
                    badgeArrow.Text = "→"
                end
            end,
            close = function(animate)
                MenuControllers[text].setActiveCard(false, animate)
            end
        }

        btn.MouseEnter:Connect(function()
            if not isCurrentActive then
                TweenService:Create(lbl, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { TextColor3 = Color3.fromRGB(215, 235, 255) }):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if not isCurrentActive then
                TweenService:Create(lbl, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { TextColor3 = Color3.fromRGB(130, 148, 172) }):Play()
            end
        end)

        btn.MouseButton1Click:Connect(function()
            activateMenu(text)
        end)

        NavCallbacks[pageName] = setActiveState
        NavButtons[pageName] = btn
        setActiveState(false, false)
        return btn
    end

    ColDivider = new("Frame", { Name = "ColDivider", Parent = Window, Size = UDim2.new(0, 1, 1, -46),
        Position = UDim2.new(0, 270, 0, 46), BackgroundColor3 = Color3.fromRGB(36, 48, 68), BackgroundTransparency = 0.2,
        BorderSizePixel = 0, ZIndex = 21, Visible = false })

    ContentHost = new("Frame", { Name = "Content", Parent = Window, Size = UDim2.new(1, -270, 1, -46),
        Position = UDim2.new(0, 270, 0, 46), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 10, Visible = false })

    CollapseBtn.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        local targetW = isCollapsed and 46 or SIDEBAR_W
        TweenService:Create(Sidebar, TweenInfo.new(0.28, Enum.EasingStyle.Cubic), { Size = UDim2.new(0, targetW, 1, -40) }):Play()
        CollapseBtn.Text = isCollapsed and ">" or "<"
    end)
    new("UIPadding", { Parent = ContentHost, PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 14), PaddingBottom = UDim.new(0, 12) })

    local function makePage(name)
        local page = new("ScrollingFrame", { Name = name, Parent = ContentHost, Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, Visible = false, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Border, ScrollBarImageTransparency = 0.3 })
        new("UIListLayout", { Parent = page, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
        new("UIPadding", { Parent = page, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 8) })

        -- Floating Scroll Pill Indicator untuk Halaman Menu
        local pageHint = new("TextButton", { Parent = ContentHost, Size = UDim2.new(0, 95, 0, 22), Position = UDim2.new(1, -105, 1, -28),
            BackgroundColor3 = Theme.Window, BackgroundTransparency = 0.15, AutoButtonColor = false, Text = "", ZIndex = 30, Visible = false }, {
            corner(11), stroke(Theme.Border, 1)
        })
        local pageHintIcon = new("TextLabel", { Parent = pageHint, Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1, Font = FONT_BOLD, Text = "v", TextColor3 = Theme.Text, TextSize = 13, ZIndex = 31 })
        local pageHintLabel = new("TextLabel", { Parent = pageHint, Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 22, 0, 0),
            BackgroundTransparency = 1, Font = FONT, Text = "Scroll Down", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31 })

        local function updatePageScrollHint()
            if not page.Visible then pageHint.Visible = false; return end
            local maxScroll = math.max(0, page.AbsoluteCanvasSize.Y - page.AbsoluteWindowSize.Y)
            if maxScroll > 20 then
                pageHint.Visible = true
                if page.CanvasPosition.Y >= maxScroll - 12 then
                    pageHintIcon.Text = "^"
                    pageHintLabel.Text = "Scroll Up"
                    pageHint.Position = UDim2.new(1, -105, 0, 10)
                else
                    pageHintIcon.Text = "v"
                    pageHintLabel.Text = "Scroll Down"
                    pageHint.Position = UDim2.new(1, -105, 1, -28)
                end
            else
                pageHint.Visible = false
            end
        end

        trackConn(page:GetPropertyChangedSignal("CanvasPosition"):Connect(updatePageScrollHint))
        trackConn(page:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updatePageScrollHint))
        trackConn(page:GetPropertyChangedSignal("Visible"):Connect(updatePageScrollHint))

        pageHint.MouseButton1Click:Connect(function()
            local maxScroll = math.max(0, page.AbsoluteCanvasSize.Y - page.AbsoluteWindowSize.Y)
            local targetY = (page.CanvasPosition.Y >= maxScroll - 12) and 0 or maxScroll
            TweenService:Create(page, TweenInfo.new(0.28, Enum.EasingStyle.Quad), { CanvasPosition = Vector2.new(0, targetY) }):Play()
        end)


        -- Object-oriented chaining helpers attached directly to page instance:
        function page:AddSection(title, order)
            return createSection(page, title, order)
        end
        function page:AddToggle(labelOrOpts, defaultVal, onChange, desc, order)
            if type(labelOrOpts) == "table" then
                return toggleRow(page, labelOrOpts.Name or labelOrOpts.Title or labelOrOpts.label or "Toggle", labelOrOpts.Order or order, labelOrOpts.Callback or labelOrOpts.onChange, labelOrOpts.Default or labelOrOpts.initial, labelOrOpts.Description or labelOrOpts.desc)
            else
                return toggleRow(page, labelOrOpts, order, onChange, defaultVal, desc)
            end
        end
        function page:AddToggleDual(opt1, opt2, order)
            return toggleDual(page, order, opt1, opt2)
        end
        function page:AddButton(labelOrOpts, onClick, desc, order)
            if type(labelOrOpts) == "table" then
                return buttonRow(page, labelOrOpts.Name or labelOrOpts.Title or labelOrOpts.label or "Button", labelOrOpts.Order or order, labelOrOpts.Callback or labelOrOpts.onClick)
            else
                return buttonRow(page, labelOrOpts, order, onClick)
            end
        end
        function page:AddSlider(labelOrOpts, minVal, maxVal, defaultVal, onChange, suffix, order)
            if type(labelOrOpts) == "table" then
                return sliderRow(page, labelOrOpts.Name or labelOrOpts.label or "Slider", labelOrOpts.Order or order, labelOrOpts.Min or labelOrOpts.min or 1, labelOrOpts.Max or labelOrOpts.max or 100, labelOrOpts.Default or labelOrOpts.default, labelOrOpts.Callback or labelOrOpts.onChange, labelOrOpts.Suffix or labelOrOpts.suffix)
            else
                return sliderRow(page, labelOrOpts, order, minVal, maxVal, defaultVal, onChange, suffix)
            end
        end
        function page:AddInput(labelOrOpts, defaultText, placeholder, onCommit, order)
            if type(labelOrOpts) == "table" then
                return inputRow(page, labelOrOpts.Name or labelOrOpts.label or "Input", labelOrOpts.Order or order, labelOrOpts.Default or labelOrOpts.default, labelOrOpts.Placeholder or labelOrOpts.placeholder, labelOrOpts.Callback or labelOrOpts.onCommit)
            else
                return inputRow(page, labelOrOpts, order, defaultText, placeholder, onCommit)
            end
        end
        function page:AddDropdown(labelOrOpts, items, defaultVal, onSelect, order)
            if type(labelOrOpts) == "table" then
                return dropdownSingle(page, labelOrOpts.Name or labelOrOpts.label or "Dropdown", labelOrOpts.Order or order, labelOrOpts.Items or labelOrOpts.options or labelOrOpts.getItems, labelOrOpts.Callback or labelOrOpts.onSelect, labelOrOpts.Default or labelOrOpts.initialKey, labelOrOpts.AllowClear)
            else
                return dropdownSingle(page, labelOrOpts, order, items, onSelect, defaultVal)
            end
        end
        function page:AddDropdownMulti(labelOrOpts, getItems, setRef, onChange, withPriority, order)
            if type(labelOrOpts) == "table" then
                return dropdownMulti(page, labelOrOpts.Name or labelOrOpts.label or "Multi Dropdown", labelOrOpts.Order or order, labelOrOpts.Items or labelOrOpts.getItems, labelOrOpts.Selected or labelOrOpts.setRef or {}, labelOrOpts.Callback or labelOrOpts.onChange, labelOrOpts.WithPriority)
            else
                return dropdownMulti(page, labelOrOpts, order, getItems, setRef, onChange, withPriority)
            end
        end
        function page:AddDropdownDual(opt1, opt2, order)
            return dropdownDual(page, order, opt1, opt2)
        end
        function page:AddLabel(text, color, order)
            return textRow(page, text, order, color)
        end
        Pages[name] = page
        return page
    end

    local pageActiveCards = {}

    local function createSection(page, sectionTitle, order)
        local head = new("Frame", { Parent = page, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = order or 1, BackgroundTransparency = 1, ZIndex = 12 }, {
            new("Frame", { Size = UDim2.new(0, 3, 0, 14), Position = UDim2.new(0, 0, 0.5, -7), BackgroundColor3 = Color3.fromRGB(180, 225, 255), BorderSizePixel = 0, ZIndex = 13 }, { corner(2) }),
            new("TextLabel", { Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Font = FONT_BOLD, Text = sectionTitle, TextColor3 = Color3.fromRGB(250, 252, 255), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })
        })

        local card = new("Frame", { Parent = page, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = (order or 1) + 1,
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(16, 20, 30), BorderSizePixel = 0, ZIndex = 12 }, {
            corner(14),
            stroke(Color3.fromRGB(34, 44, 65), 1),
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }),
            new("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }),
        })

        pageActiveCards[page] = card
        return card
    end

    local function sectionLabel(page, text, order)
        return createSection(page, text, order)
    end

    local function getCurrentCard(page, order)
        if pageActiveCards[page] and pageActiveCards[page].Parent == page then
            return pageActiveCards[page]
        end
        return createSection(page, "General", order or 1)
    end

    local function textRow(page, text, order, color)
        local target = page:IsA("ScrollingFrame") and getCurrentCard(page, order) or page
        return new("TextLabel", { Parent = target, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = order,
            BackgroundTransparency = 1, Font = FONT, Text = text, TextColor3 = color or Theme.TextSecondary,
            TextSize = 14.5, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true })
    end

    local function buttonRow(page, label, order, onClick)
        local target = page:IsA("ScrollingFrame") and getCurrentCard(page, order) or page
        local btn = new("TextButton", { Parent = target, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = order,
            BackgroundColor3 = Color3.fromRGB(225, 240, 255), BackgroundTransparency = 0, AutoButtonColor = false,
            Font = FONT_BOLD, Text = label, TextColor3 = Color3.fromRGB(12, 16, 24), TextSize = 13.5 },
            {
                corner(19),
                stroke(Color3.fromRGB(255, 255, 255), 1),
                new("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(252, 254, 255)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(225, 238, 252)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 195, 225))
                    }),
                    Rotation = 90
                })
            })
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 0.15 }):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 0 }):Play() end)
        btn.MouseButton1Click:Connect(function()
            local ok, err = pcall(onClick, btn); if not ok then warn("[UI] button error: " .. tostring(err)) end
        end)
        return btn
    end

    local function toggleRow(page, label, order, onChange, initial, desc)
        local target = page:IsA("ScrollingFrame") and getCurrentCard(page, order) or page
        local row = new("Frame", { Parent = target, Size = UDim2.new(1, 0, 0, desc and 38 or 30), LayoutOrder = order, BackgroundTransparency = 1 })
        local state = not not initial
        local lbl = new("TextLabel", { Parent = row, Size = UDim2.new(1, -52, 0, 16), Position = UDim2.new(0, 0, 0, desc and 2 or 7),
            BackgroundTransparency = 1, Font = state and FONT_BOLD or FONT, Text = label,
            TextColor3 = state and Color3.fromRGB(245, 250, 255) or Color3.fromRGB(195, 210, 230), TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left })
        if desc then
            new("TextLabel", { Parent = row, Size = UDim2.new(1, -52, 0, 14), Position = UDim2.new(0, 0, 0, 21),
                BackgroundTransparency = 1, Font = FONT, Text = desc, TextColor3 = Color3.fromRGB(120, 145, 175), TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left })
        end

        local togglePill = new("TextButton", { Parent = row, Size = UDim2.fromOffset(38, 20), Position = UDim2.new(1, -40, 0.5, -10),
            BackgroundColor3 = state and Color3.fromRGB(238, 246, 255) or Color3.fromRGB(24, 30, 44), BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 13 }, {
            corner(10),
            stroke(state and Color3.fromRGB(190, 225, 255) or Color3.fromRGB(55, 70, 95), 1),
        })

        local knob = new("Frame", { Parent = togglePill, Size = UDim2.fromOffset(16, 16),
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = state and Color3.fromRGB(14, 18, 26) or Color3.fromRGB(115, 135, 165), BorderSizePixel = 0, ZIndex = 14 }, { corner(8) })

        local function render()
            local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local targetPillColor = state and Color3.fromRGB(238, 246, 255) or Color3.fromRGB(24, 30, 44)
            local targetKnobColor = state and Color3.fromRGB(14, 18, 26) or Color3.fromRGB(115, 135, 165)
            local targetStrokeColor = state and Color3.fromRGB(190, 225, 255) or Color3.fromRGB(55, 70, 95)
            TweenService:Create(knob, TweenInfo.new(0.18), { Position = targetPos, BackgroundColor3 = targetKnobColor }):Play()
            TweenService:Create(togglePill, TweenInfo.new(0.18), { BackgroundColor3 = targetPillColor }):Play()
            local pillStroke = togglePill:FindFirstChildOfClass("UIStroke")
            if pillStroke then
                TweenService:Create(pillStroke, TweenInfo.new(0.18), { Color = targetStrokeColor }):Play()
            end
            lbl.TextColor3 = state and Color3.fromRGB(245, 250, 255) or Color3.fromRGB(195, 210, 230)
            lbl.Font = state and FONT_BOLD or FONT
        end

        local function toggle()
            state = not state; render()
            if onChange then onChange(state) end
        end

        local clickRow = new("TextButton", { Parent = row, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Text = "", ZIndex = 12 })
        clickRow.MouseButton1Click:Connect(toggle)
        togglePill.MouseButton1Click:Connect(toggle)

        return {
            Set = function(v) state = not not v; render() end,
            Get = function() return state end,
            Row = row,
        }
    end

    local function toggleDual(page, order, opt1, opt2)
        local target = page:IsA("ScrollingFrame") and getCurrentCard(page, order) or page
        local row = new("Frame", { Parent = target, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = order, BackgroundTransparency = 1 })
        
        local function createHalf(opt, isRight)
            if not opt then return end
            local half = new("Frame", { Parent = row, Size = UDim2.new(0.5, -8, 1, 0), Position = isRight and UDim2.new(0.5, 8, 0, 0) or UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
            local state = not not opt.initial

            local lbl = new("TextLabel", { Parent = half, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1, Font = state and FONT_BOLD or FONT, Text = opt.label,
                TextColor3 = state and Theme.Text or Color3.fromRGB(195, 210, 230), TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })

            local togglePill = new("TextButton", { Parent = half, Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -34, 0.5, -9),
                BackgroundColor3 = state and Theme.Text or Color3.fromRGB(24, 30, 44), BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 13 }, {
                corner(9),
                stroke(state and Color3.fromRGB(190, 225, 255) or Color3.fromRGB(55, 70, 95), 1),
            })

            local knob = new("Frame", { Parent = togglePill, Size = UDim2.fromOffset(14, 14),
                Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = state and Theme.Background or Color3.fromRGB(115, 135, 165), BorderSizePixel = 0, ZIndex = 14 }, { corner(7) })

            local function render()
                local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                local targetPillColor = state and Theme.Text or Color3.fromRGB(24, 30, 44)
                local targetKnobColor = state and Theme.Background or Color3.fromRGB(115, 135, 165)
                local targetStrokeColor = state and Color3.fromRGB(190, 225, 255) or Color3.fromRGB(55, 70, 95)
                TweenService:Create(knob, TweenInfo.new(0.18), { Position = targetPos, BackgroundColor3 = targetKnobColor }):Play()
                TweenService:Create(togglePill, TweenInfo.new(0.18), { BackgroundColor3 = targetPillColor }):Play()
                local pillStroke = togglePill:FindFirstChildOfClass("UIStroke")
                if pillStroke then
                    TweenService:Create(pillStroke, TweenInfo.new(0.18), { Color = targetStrokeColor }):Play()
                end
                lbl.TextColor3 = state and Theme.Text or Color3.fromRGB(195, 210, 230)
                lbl.Font = state and FONT_BOLD or FONT
            end

            local function toggle()
                state = not state; render()
                if opt.onChange then opt.onChange(state) end
            end

            local clickHalf = new("TextButton", { Parent = half, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1, Text = "", ZIndex = 12 })
            clickHalf.MouseButton1Click:Connect(toggle)
            togglePill.MouseButton1Click:Connect(toggle)

            return {
                Set = function(v) state = not not v; render() end,
                Get = function() return state end,
            }
        end

        local c1 = createHalf(opt1, false)
        local c2 = createHalf(opt2, true)
        return { c1 = c1, c2 = c2, Row = row }
    end

    local function toggleGrid(page, order)
        local grid = new("Frame", { Parent = page, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = order,
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
        new("UIGridLayout", { Parent = grid, CellSize = UDim2.new(0.5, -4, 0, 32), CellPadding = UDim2.new(0, 8, 0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder })
        return grid
    end

    local function toggleCell(grid, label, order, onChange)
        local btn = new("TextButton", { Parent = grid, LayoutOrder = order, BackgroundColor3 = Theme.Control,
            BackgroundTransparency = 0.4, AutoButtonColor = false, Text = "" },
            { corner(8), stroke(Theme.Border, 1) })
        local ind = new("Frame", { Parent = btn, Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 8, 0.5, -3),
            BackgroundColor3 = Theme.SubText }, { corner(3) })
        local lbl = new("TextLabel", { Parent = btn, Size = UDim2.new(1, -22, 1, 0), Position = UDim2.new(0, 18, 0, 0),
            BackgroundTransparency = 1, Font = FONT, Text = label, TextColor3 = Theme.SubText, TextSize = 14.5,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
        local state = false
        local function render()
            TweenService:Create(btn, TOGGLE_TWEEN, { BackgroundColor3 = state and Theme.AccentDim or Theme.Control }):Play()
            TweenService:Create(ind, TOGGLE_TWEEN, { BackgroundColor3 = state and Theme.Accent or Theme.SubText }):Play()
            lbl.TextColor3 = state and Theme.Text or Theme.SubText
        end
        btn.MouseButton1Click:Connect(function()
            state = not state; render()
            if onChange then onChange(state) end
        end)
        return {
            Set = function(v) state = not not v; render() end,
            Get = function() return state end,
        }
    end

    local function sliderRow(page, label, order, minV, maxV, default, onChange, suffix)
        local target = page:IsA("ScrollingFrame") and getCurrentCard(page, order) or page
        minV, maxV = minV or 1, maxV or 100
        local sfx = suffix or ""
        local value = math.clamp(default or minV, minV, maxV)
        local row = new("Frame", { Parent = target, Size = UDim2.new(1, 0, 0, 46), LayoutOrder = order, BackgroundTransparency = 1 })
        new("TextLabel", { Parent = row, Size = UDim2.new(0.7, 0, 0, 16), Position = UDim2.new(0, 0, 0, 3),
            BackgroundTransparency = 1, Font = FONT, Text = label, TextColor3 = Color3.fromRGB(225, 235, 250), TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left })
        local valBadge = new("Frame", { Parent = row, Size = UDim2.new(0, 54, 0, 20), Position = UDim2.new(1, -54, 0, 1),
            BackgroundColor3 = Color3.fromRGB(22, 28, 42), BorderSizePixel = 0, ZIndex = 13 }, {
            corner(6),
            stroke(Color3.fromRGB(45, 60, 85), 1)
        })
        local valLbl = new("TextLabel", { Parent = valBadge, Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, Font = FONT_BOLD, Text = tostring(value) .. sfx,
            TextColor3 = Color3.fromRGB(180, 230, 255), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center })
        local track = new("Frame", { Parent = row, Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 0, 28),
            BackgroundColor3 = Color3.fromRGB(24, 30, 44), BorderSizePixel = 0, ZIndex = 13 }, { corner(3) })
        local fracInit = math.clamp((value - minV) / (maxV - minV), 0, 1)
        local fill = new("Frame", { Parent = track, Size = UDim2.new(fracInit, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(230, 245, 255), BorderSizePixel = 0, ZIndex = 14 }, {
            corner(3),
            new("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 205, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 252, 255))
                })
            })
        })
        local knob = new("Frame", { Parent = track, Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(fracInit, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 16 }, {
            corner(7), stroke(Color3.fromRGB(14, 18, 26), 1.8)
        })
        local dragBtn = new("TextButton", { Parent = track, Size = UDim2.new(1, 12, 1, 16), Position = UDim2.new(0, -6, 0, -8),
            BackgroundTransparency = 1, Text = "", ZIndex = 17 })

        local dragging = false
        local function applyX(absX)
            local frac = math.clamp((absX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(minV + (maxV - minV) * frac + 0.5)
            fill.Size = UDim2.new(frac, 0, 1, 0)
            knob.Position = UDim2.new(frac, 0, 0.5, 0)
            valLbl.Text = tostring(value) .. sfx
            if onChange then onChange(value) end
        end
        dragBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; applyX(input.Position.X)
            end
        end)
        trackConn(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                applyX(input.Position.X)
            end
        end))
        trackConn(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
        return {
            Set = function(v)
                value = math.clamp(v, minV, maxV)
                local frac = (value - minV) / (maxV - minV)
                fill.Size = UDim2.new(frac, 0, 1, 0)
                valLbl.Text = tostring(value) .. sfx
            end,
            Get = function() return value end,
        }
    end

    local function inputRow(page, label, order, default, placeholder, onCommit)
        local target = page:IsA("ScrollingFrame") and getCurrentCard(page, order) or page
        local row = new("Frame", { Parent = target, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = order, BackgroundTransparency = 1 })
        new("TextLabel", { Parent = row, Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Font = FONT, Text = label, TextColor3 = Theme.TextSecondary, TextSize = 14.5,
            TextXAlignment = Enum.TextXAlignment.Left })
        local box = new("TextBox", { Parent = row, Size = UDim2.new(0.6, 0, 0, 26), Position = UDim2.new(0.4, 0, 0.5, -13),
            BackgroundColor3 = Color3.fromRGB(22, 28, 42), BackgroundTransparency = 0, Font = FONT, Text = default or "",
            PlaceholderText = placeholder or "...", TextColor3 = Color3.fromRGB(245, 250, 255),
            PlaceholderColor3 = Color3.fromRGB(100, 115, 140), TextSize = 13.5, ClearTextOnFocus = false },
            { corner(8), stroke(Color3.fromRGB(42, 55, 80), 1) })
        new("UIPadding", { Parent = box, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
        box.FocusLost:Connect(function(enter) if onCommit then onCommit(box.Text, enter) end end)
        return {
            Set = function(t) box.Text = tostring(t) end,
            Get = function() return box.Text end,
        }
    end

    local function multiSelectList(page, order, height, getItems, setRef, onChange)
        local frame = new("ScrollingFrame", { Parent = page, Size = UDim2.new(1, 0, 0, height or 120),
            LayoutOrder = order, BackgroundColor3 = Theme.Control, BackgroundTransparency = 0.5,
            BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Border },
            { corner(8), stroke(Theme.Border, 1) })
        new("UIListLayout", { Parent = frame, Padding = UDim.new(0, 2) })
        new("UIPadding", { Parent = frame, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })
        local function refresh()
            for _, c in ipairs(frame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            local items = getItems()
            for _, item in ipairs(items) do
                local key, label = item, item
                if type(item) == "table" then key, label = item.key or item[1], item.label or item[2] or item.key or item[1] end
                local on = setRef[key] == true
                local row = new("TextButton", { Parent = frame, Size = UDim2.new(1, 0, 0, 24),
                    BackgroundColor3 = on and Theme.AccentDim or Theme.Control,
                    BackgroundTransparency = on and 0.2 or 0.7, AutoButtonColor = false, Text = "" },
                    { corner(6) })
                local box = new("Frame", { Parent = row, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 6, 0.5, -6),
                    BackgroundColor3 = on and Theme.Accent or Theme.Border }, { corner(3) })
                new("TextLabel", { Parent = row, Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 24, 0, 0),
                    BackgroundTransparency = 1, Font = FONT, Text = tostring(label),
                    TextColor3 = on and Theme.Text or Theme.SubText, TextSize = 14.5,
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
                row.MouseButton1Click:Connect(function()
                    setRef[key] = not setRef[key]
                    if not setRef[key] then setRef[key] = nil end
                    refresh()
                    if onChange then onChange(setRef) end
                end)
            end
        end
        refresh()
        return { Refresh = refresh, Frame = frame }
    end

    -- onResize(tinggiContainer) opsional: dipakai dropdownDual buat ngatur tinggi baris manual
    local function dropdownMulti(page, label, order, getItems, setRef, onChange, withPriority, onResize)
        local target = page:IsA("ScrollingFrame") and getCurrentCard(page, order) or page
        local isExpanded = false

        local container = new("Frame", { Parent = target, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = order,
            BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 12 }, { corner(6) })

        local headerBtn = new("TextButton", { Parent = container, Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 13 })

        new("TextLabel", { Parent = headerBtn, Size = UDim2.new(0.45, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Font = FONT, Text = label, TextColor3 = Theme.TextSecondary, TextSize = 14.5,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })

        local valLbl = new("TextLabel", { Parent = headerBtn, Size = UDim2.new(0.55, -24, 1, 0), Position = UDim2.new(0.45, 0, 0, 0),
            BackgroundTransparency = 1, Font = FONT, Text = "All", TextColor3 = Theme.TextSecondary, TextSize = 14.5,
            TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14 })

        local chevron = new("TextLabel", { Parent = headerBtn, Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -16, 0.5, -8),
            BackgroundTransparency = 1, Font = FONT_BOLD, Text = "v", TextColor3 = Theme.TextSecondary, TextSize = 12, ZIndex = 14 })

        -- kotak pencarian (muncul cuma pas dropdown kebuka)
        local searchFrame = new("Frame", { Parent = container, Size = UDim2.new(1, -8, 0, 26), Position = UDim2.new(0, 4, 0, 34),
            BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 0.35, BorderSizePixel = 0, Visible = false, ZIndex = 13 },
            { corner(5) })
        local searchBox = new("TextBox", { Parent = searchFrame, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1, Font = FONT, PlaceholderText = "Search...", Text = "",
            TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextSecondary, TextSize = 13,
            ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })

        local optList = new("ScrollingFrame", { Parent = container, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 64),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 13 }, {
            new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
            new("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 4) })
        })

        local function updateSummary()
            local picked = {}
            for k, v in pairs(setRef) do if v then table.insert(picked, tostring(k)) end end
            if #picked == 0 then
                valLbl.Text = "All (none)"
                valLbl.TextColor3 = Theme.TextSecondary
            else
                valLbl.Text = table.concat(picked, ", ")
                valLbl.TextColor3 = Theme.Text
            end
        end
        updateSummary()

        local function populate()
            for _, c in ipairs(optList:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
            end
            local raw = getItems() or {}
            local q = string.lower(tostring(searchBox.Text or ""))

            -- Susun daftar tampil: entri { header = "Nama Area" } jadi judul grup, sisanya opsi.
            -- Judul grup cuma ikut tampil kalau ada minimal 1 anggota yang lolos pencarian.
            local items = {}
            local pendingHeader = nil
            for _, it in ipairs(raw) do
                if type(it) == "table" and it.header then
                    pendingHeader = it.header
                else
                    local k = type(it) == "table" and (it.key or it[1]) or it
                    local t = type(it) == "table" and (it.label or it[2] or k) or k
                    if q == "" or string.find(string.lower(tostring(t)), q, 1, true) then
                        if pendingHeader then
                            items[#items + 1] = { header = pendingHeader }
                            pendingHeader = nil
                        end
                        items[#items + 1] = { key = k, label = t }
                    end
                end
            end

            local usedHeight = 6
            for i, it in ipairs(items) do
                if it.header then
                    new("TextLabel", { Parent = optList, Size = UDim2.new(1, -8, 0, 20), LayoutOrder = i,
                        BackgroundTransparency = 1, Font = FONT_BOLD, Text = string.upper(tostring(it.header)),
                        TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15 })
                    usedHeight = usedHeight + 22
                    continue
                end
                usedHeight = usedHeight + 28
                local key = it.key
                local title = it.label
                local on = setRef[key] == true

                local optBtn = new("TextButton", { Parent = optList, LayoutOrder = i, Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = on and Theme.CardActive or Theme.CardHover,
                    BackgroundTransparency = on and 0.2 or 0.8, BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 14 }, { corner(5) })

                local chk = new("Frame", { Parent = optBtn, Size = UDim2.new(0, 11, 0, 11), Position = UDim2.new(0, 8, 0.5, -5),
                    BackgroundColor3 = on and Theme.Text or Theme.BorderLight, ZIndex = 15 }, { corner(2) })

                local optText = new("TextLabel", { Parent = optBtn, Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 28, 0, 0),
                    BackgroundTransparency = 1, Font = on and FONT_BOLD or FONT, Text = tostring(title),
                    TextColor3 = on and Theme.Text or Theme.TextSecondary, TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 15 })

                optBtn.MouseButton1Click:Connect(function()
                    setRef[key] = not setRef[key]
                    if not setRef[key] then setRef[key] = nil end
                    local nowOn = setRef[key] == true
                    chk.BackgroundColor3 = nowOn and Theme.Text or Theme.BorderLight
                    optBtn.BackgroundColor3 = nowOn and Theme.CardActive or Theme.CardHover
                    optBtn.BackgroundTransparency = nowOn and 0.2 or 0.8
                    optText.TextColor3 = nowOn and Theme.Text or Theme.TextSecondary
                    optText.Font = nowOn and FONT_BOLD or FONT
                    updateSummary()
                    if onChange then onChange(setRef) end
                end)
            end
            if #items == 0 then
                new("TextLabel", { Parent = optList, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 1,
                    BackgroundTransparency = 1, Font = FONT, Text = "tidak ada hasil",
                    TextColor3 = Theme.TextSecondary, TextSize = 13, ZIndex = 15 })
                usedHeight = usedHeight + 26
            end
            local listHeight = math.min(usedHeight, 200)
            optList.Size = UDim2.new(1, 0, 0, listHeight)
            return listHeight
        end

        local function setContainerH(h)
            container.Size = UDim2.new(1, 0, 0, h)
            if onResize then pcall(onResize, h) end
        end
        local function relayout()
            local listH = populate()
            setContainerH(34 + 30 + listH + 6)
        end
        -- ketik di kotak cari -> daftar langsung ke-filter
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            if isExpanded then relayout() end
        end)

        headerBtn.MouseButton1Click:Connect(function()
            isExpanded = not isExpanded
            chevron.Text = isExpanded and "^" or "v"
            searchFrame.Visible = isExpanded
            if isExpanded then
                relayout()
            else
                searchBox.Text = ""
                setContainerH(34)
            end
        end)

        return { Update = updateSummary, Row = container }
    end

    -- Dua dropdownMulti bersebelahan (kiri | kanan). Row + tiap kolom pakai AutomaticSize.Y
    -- biar tingginya ikut nyesuain waktu salah satu dropdown dibuka/ditutup.
    -- spec = { label = "...", getItems = fn/tabel, setRef = tabel, onChange = fn }
    -- Baris 2 kolom generik. buildLeft/buildRight = function(hostFrame, reportHeight).
    -- Tinggi baris DIATUR MANUAL dari callback tinggi tiap kolom (ambil yang tertinggi).
    -- Sebelumnya pakai AutomaticSize bertingkat (row -> kolom -> dropdown) — ga reliable di
    -- Roblox kalau anaknya diposisikan manual: baris melar tapi isi dropdown ga ke-render.
    local function dualRow(page, order, buildLeft, buildRight)
        local target = page:IsA("ScrollingFrame") and getCurrentCard(page, order) or page
        local row = new("Frame", { Parent = target, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = order,
            BackgroundTransparency = 1, ZIndex = 12 })
        local hL, hR = 34, 34
        local function syncRow() row.Size = UDim2.new(1, 0, 0, math.max(hL, hR)) end
        local function makeHalf(isRight)
            return new("Frame", { Parent = row, Size = UDim2.new(0.5, -5, 1, 0),
                Position = isRight and UDim2.new(0.5, 5, 0, 0) or UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1, ZIndex = 12 })
        end
        if buildLeft then buildLeft(makeHalf(false), function(h) hL = h; syncRow() end) end
        if buildRight then buildRight(makeHalf(true), function(h) hR = h; syncRow() end) end
        return row
    end

    -- Dua dropdownMulti bersebelahan (pakai dualRow di atas).
    local function dropdownDual(page, order, spec1, spec2)
        return dualRow(page, order,
            spec1 and function(host, onH)
                dropdownMulti(host, spec1.label, 1, spec1.getItems, spec1.setRef, spec1.onChange, nil, onH)
            end or nil,
            spec2 and function(host, onH)
                dropdownMulti(host, spec2.label, 1, spec2.getItems, spec2.setRef, spec2.onChange, nil, onH)
            end or nil)
    end

    local function dropdownSingle(page, label, order, getItems, onSelect, initialKey, allowClear, onResize)
        local target = page:IsA("ScrollingFrame") and getCurrentCard(page, order) or page
        local isExpanded = false
        local selectedKey = initialKey
        local function reportH(h) if onResize then pcall(onResize, h) end end

        local container = new("Frame", { Parent = target, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = order,
            BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 12 }, { corner(6) })

        local headerBtn = new("TextButton", { Parent = container, Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 13 })

        new("TextLabel", { Parent = headerBtn, Size = UDim2.new(0.45, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Font = FONT, Text = label, TextColor3 = Theme.TextSecondary, TextSize = 14.5,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })

        local valLbl = new("TextLabel", { Parent = headerBtn, Size = UDim2.new(0.55, -24, 1, 0), Position = UDim2.new(0.45, 0, 0, 0),
            BackgroundTransparency = 1, Font = FONT, Text = tostring(initialKey or "Select..."), TextColor3 = initialKey and Theme.Text or Theme.TextSecondary,
            TextSize = 14.5, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14 })

        local chevron = new("TextLabel", { Parent = headerBtn, Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -16, 0.5, -8),
            BackgroundTransparency = 1, Font = FONT_BOLD, Text = "v", TextColor3 = Theme.TextSecondary, TextSize = 12, ZIndex = 14 })

        local optList = new("Frame", { Parent = container, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 34),
            BackgroundTransparency = 1, ZIndex = 13 }, {
            new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
        })

        local function populate()
            for _, c in ipairs(optList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            local items = getItems() or {}
            for i, it in ipairs(items) do
                local key = type(it) == "table" and (it.key or it[1]) or it
                local title = type(it) == "table" and (it.label or it[2] or key) or key
                local isLocked = type(it) == "table" and it.locked
                local on = (selectedKey == key)

                local optBtn = new("TextButton", { Parent = optList, Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = on and Theme.CardActive or Theme.CardHover,
                    BackgroundTransparency = on and 0.2 or 0.8, BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 14 }, { corner(5) })

                new("TextLabel", { Parent = optBtn, Size = UDim2.new(1, isLocked and -40 or -16, 1, 0), Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1, Font = on and FONT_BOLD or FONT, Text = tostring(title),
                    TextColor3 = isLocked and Theme.SubText or (on and Theme.Text or Theme.TextSecondary), TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 15 })

                if isLocked then
                    new("TextLabel", { Parent = optBtn, Size = UDim2.new(0, 28, 1, 0), Position = UDim2.new(1, -30, 0, 0),
                        BackgroundTransparency = 1, Font = FONT_BOLD, Text = "🔒", TextColor3 = Color3.fromRGB(255, 216, 92),
                        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 15 })
                end

                optBtn.MouseButton1Click:Connect(function()
                    if isLocked then
                        if it.onLockClick then
                            it.onLockClick()
                        else
                            showToast(tostring(title) .. " is locked (Gold/Lifetime Key required)")
                        end
                        return
                    end
                    selectedKey = key
                    valLbl.Text = tostring(title)
                    valLbl.TextColor3 = Theme.Text
                    isExpanded = false
                    chevron.Text = "v"
                    TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Cubic), { Size = UDim2.new(1, 0, 0, 34) }):Play()
                    reportH(34)
                    if onSelect then onSelect(type(it) == "table" and it or { key = key, label = title }) end
                end)
            end
            local totalH = #items * 28
            optList.Size = UDim2.new(1, 0, 0, totalH)
            return totalH
        end

        headerBtn.MouseButton1Click:Connect(function()
            isExpanded = not isExpanded
            chevron.Text = isExpanded and "^" or "v"
            if isExpanded then
                local totalH = populate()
                TweenService:Create(container, TweenInfo.new(0.24, Enum.EasingStyle.Cubic), { Size = UDim2.new(1, 0, 0, 34 + totalH + 6) }):Play()
                reportH(34 + totalH + 6)
            else
                TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Cubic), { Size = UDim2.new(1, 0, 0, 34) }):Play()
                reportH(34)
            end
        end)

        return {
            Set = function(k, lbl) selectedKey = k; valLbl.Text = tostring(lbl or k or "None"); valLbl.TextColor3 = k and Theme.Text or Theme.TextSecondary end,
            Get = function() return selectedKey end,
            Row = container,
        }
    end
    local function destroyPanel()
        panelAlive = false
        for _, c in ipairs(PanelConns) do pcall(function() c:Disconnect() end) end
        PanelConns = {}
        if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
    end

    -- Window dragging
    local dragging, dragStart, startPos = false, nil, nil
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local s = WindowScale.Scale; if s <= 0 then s = 1 end
        Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (delta.X / s), startPos.Y.Scale, startPos.Y.Offset + (delta.Y / s))
    end
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    trackConn(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end))

    -- ================= FLOATING TOGGLE BUBBLE (MINIMIZE TARGET) =================
    local FloatingToggle = new("ImageButton", {
        Name = "FloatingToggle", Parent = ScreenGui, Size = UDim2.fromOffset(42, 42),
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Theme.Control, BorderSizePixel = 0, AutoButtonColor = false, Image = "",
        ZIndex = 300, Active = true, Draggable = false, Visible = false,
    }, {
        corner(21),
        stroke(Theme.Border, 1.2),
    })

    local FloatingScale = new("UIScale", { Parent = FloatingToggle })

    local FloatingLogoIcon = new("ImageLabel", {
        Parent = FloatingToggle, Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1, Image = Icons.Logo, ImageColor3 = Theme.Text,
        ZIndex = 301,
    })

    -- Posisi bubble terakhir hasil drag (nil = belum pernah digeser -> ikut posisi Window)
    local bubbleLastPos = nil

    local function openWindow()
        FloatingToggle.Visible = false
        Window.Visible = true
        local targetScale = WindowScale:GetAttribute("TargetScale") or 0.88
        WindowScale.Scale = targetScale * 0.85
        Window.BackgroundTransparency = 1
        TweenService:Create(WindowScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = targetScale }):Play()
        TweenService:Create(Window, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 0 }):Play()
    end

    if dismissAnnouncement then
        dismissAnnouncement = function()
            if not AnnounceModal or not AnnounceModal.Parent then return end
            local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
            TweenService:Create(AnnounceScale, tInfo, { Scale = 0.85 }):Play()
            TweenService:Create(AnnounceModal, tInfo, { BackgroundTransparency = 1 }):Play()
            task.delay(0.22, function()
                if AnnounceModal and AnnounceModal.Parent then AnnounceModal:Destroy() end
            end)
            openWindow()
        end
    end

    local function minimizeWindow()
        local targetScale = WindowScale:GetAttribute("TargetScale") or 0.88
        TweenService:Create(WindowScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Scale = targetScale * 0.85 }):Play()
        TweenService:Create(Window, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
        task.delay(0.18, function()
            Window.Visible = false
            -- Pakai posisi bubble TERAKHIR hasil drag. Dulu selalu di-set ke Window.Position
            -- -> tiap minimize bubble balik ke tengah walau udah digeser.
            FloatingToggle.Position = bubbleLastPos or Window.Position
            FloatingToggle.Visible = true
            FloatingScale.Scale = 0.5
            TweenService:Create(FloatingScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
            showToast("Window Minimized - Click bubble to restore")
        end)
    end

    -- DRAG bubble (implementasi sendiri, ganti properti Draggable yang deprecated).
    -- Posisi hasil geser disimpan ke bubbleLastPos, dipakai lagi tiap minimize.
    local btnPressPos = nil
    local bubbleDragging, bubbleDragStart, bubbleStartPos = false, nil, nil
    FloatingToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            btnPressPos = FloatingToggle.AbsolutePosition
            bubbleDragging = true
            bubbleDragStart = input.Position
            bubbleStartPos = FloatingToggle.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    bubbleDragging = false
                    bubbleLastPos = FloatingToggle.Position   -- INGAT posisi terakhir
                end
            end)
        end
    end)
    trackConn(UserInputService.InputChanged:Connect(function(input)
        if bubbleDragging and bubbleDragStart and
           (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - bubbleDragStart
            -- bubble di-parent langsung ke ScreenGui (ga kena WindowScale), jadi ga usah dibagi skala
            FloatingToggle.Position = UDim2.new(
                bubbleStartPos.X.Scale, bubbleStartPos.X.Offset + d.X,
                bubbleStartPos.Y.Scale, bubbleStartPos.Y.Offset + d.Y)
        end
    end))
    -- jaga-jaga: kalau layar berubah ukuran & bubble jadi di luar layar, tarik balik ke dalam
    trackConn(FloatingToggle:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if bubbleDragging or not FloatingToggle.Visible then return end
        local cam = workspace.CurrentCamera
        local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
        local ap, sz = FloatingToggle.AbsolutePosition, FloatingToggle.AbsoluteSize
        if ap.X + sz.X < 8 or ap.Y + sz.Y < 8 or ap.X > vp.X - 8 or ap.Y > vp.Y - 8 then
            FloatingToggle.Position = UDim2.new(0.5, 0, 0.5, 0)
            bubbleLastPos = FloatingToggle.Position
        end
    end))

    FloatingToggle.MouseButton1Click:Connect(function()
        if btnPressPos then
            local delta = (FloatingToggle.AbsolutePosition - btnPressPos).Magnitude
            btnPressPos = nil
            if delta > 3 then return end
        end
        openWindow()
    end)

    FloatingToggle.MouseEnter:Connect(function()
        TweenService:Create(FloatingToggle, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { BackgroundColor3 = Theme.AccentDim }):Play()
        TweenService:Create(FloatingScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { Scale = 1.08 }):Play()
    end)
    FloatingToggle.MouseLeave:Connect(function()
        TweenService:Create(FloatingToggle, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { BackgroundColor3 = Theme.Control }):Play()
        TweenService:Create(FloatingScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { Scale = 1.0 }):Play()
    end)

    BackBtn.MouseEnter:Connect(function()
        TweenService:Create(BackBtn, TweenInfo.new(0.18), { TextColor3 = Color3.fromRGB(250, 252, 255) }):Play()
    end)
    BackBtn.MouseLeave:Connect(function()
        TweenService:Create(BackBtn, TweenInfo.new(0.18), { TextColor3 = Color3.fromRGB(160, 185, 215) }):Play()
    end)

    MinButton.MouseButton1Click:Connect(function()
        if isContentOpen then
            closeContentWindow()
            if clearActiveSubItem then clearActiveSubItem() end
            if currentOpenMenu and MenuControllers[currentOpenMenu] then
                MenuControllers[currentOpenMenu].close(true)
            end
            currentOpenMenu = nil
        else
            minimizeWindow()
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        destroyPanel()
        if FloatingToggle and FloatingToggle.Parent then FloatingToggle:Destroy() end
    end)

    trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
            if Window.Visible then
                minimizeWindow()
            else
                openWindow()
            end
        end
    end))

    UI = {
        makePage = makePage,
        navItem = navItem,
        sectionLabel = sectionLabel,
        createSection = createSection,
        getCurrentCard = getCurrentCard,
        textRow = textRow,
        buttonRow = buttonRow,
        toggleRow = toggleRow,
        toggleDual = toggleDual,
        toggleGrid = toggleGrid,
        toggleCell = toggleCell,
        sliderRow = sliderRow,
        inputRow = inputRow,
        multiSelectList = multiSelectList,
        dropdownMulti = dropdownMulti,
        dropdownDual = dropdownDual,
        dualRow = dualRow,
        dropdownSingle = dropdownSingle,
        showToast = showToast,
        showActivityToast = showActivityToast,
        hideActivityToast = hideActivityToast,
        showCenterModalWarning = showCenterModalWarning,
        destroyPanel = destroyPanel,
        Theme = Theme,
        Icons = Icons,
        isAlive = function() return panelAlive end,
        trackConn = trackConn,
        FONT = FONT,
        FONT_BOLD = FONT_BOLD,
        Pages = Pages,
        NavButtons = NavButtons,
        switchPage = switchPage,
        moveHighlightTo = moveHighlightTo,
        new = new,
        corner = corner,
        stroke = stroke,
        ScreenGui = ScreenGui,
        Window = Window,
        PillLabel = PillLabel,
        -- Mode ukuran window. Dipanggil dari blok utama lewat UI.setWindowMode(...) —
        -- sengaja LEWAT TABEL, bukan di-import jadi local, karena blok utama udah mepet
        -- batas 200 lokal aktif punya Luau.
        setWindowMode = function(pc)
            pcFullSize = not not pc
            fitWindow()
            centerWindow()
        end,
        getWindowMode = function() return pcFullSize end,
        setDefaultMenu = function(name)
            local ctrl = MenuControllers[name]
            if ctrl then
                currentOpenMenu = name
                ctrl.setActiveCard(true, false)
                ctrl.setDropdown(false, false)
            end
        end,
        openWindow = openWindow,
        minimizeWindow = minimizeWindow,
        centerWindow = centerWindow,
        fitWindow = fitWindow,
        WIN_T = 0,
        CTRL_T = 0,
    }
    end

    pcall(function()
        (getgenv and getgenv() or _G).__CompactModernUI = UI
    end)

    return UI
end

CompactModern.new = CompactModern.CreateWindow
CompactModern.Init = CompactModern.CreateWindow

setmetatable(CompactModern, {
    __call = function(self, config)
        return self.CreateWindow(config)
    end
})

return CompactModern
