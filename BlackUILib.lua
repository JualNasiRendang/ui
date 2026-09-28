--[[
    ============================================================================
    BLACK UI DESIGN SYSTEM & LIBRARY (STANDALONE MODULE)
    ============================================================================
    Architecture: Decoupled UI Module
    Author: NRL Script
    Export: returns UI table with all window, styling, and widget builders
    
    COMPONENTS & METHODS:
    - UI.Window, UI.ScreenGui, UI.Theme, UI.Icons, UI.PillLabel
    - UI.makePage(name, iconId) -> returns ScrollingFrame page
    - UI.navItem(name, iconId, page, order)
    - UI.createSection(page, title, order)
    - UI.sectionLabel(page, text, order)
    - UI.toggleRow(page, label, order, defaultVal, callback, desc)
    - UI.toggleDual(page, label1, def1, cb1, label2, def2, cb2, order)
    - UI.toggleGrid(page, order, numCols, gap)
    - UI.toggleCell(grid, label, defaultVal, callback)
    - UI.sliderRow(page, label, order, min, max, defaultVal, callback, suffix)
    - UI.inputRow(page, label, order, defaultText, callback, placeholder)
    - UI.dropdownSingle(page, label, order, items, defaultVal, callback)
    - UI.dropdownMulti(page, label, order, getItems, setRef, onChange, withPriority)
    - UI.dropdownDual(page, label1, getItems1, setRef1, cb1, label2, getItems2, setRef2, cb2, order)
    - UI.dualRow(page, order, setupCol1, setupCol2)
    - UI.multiSelectList(page, order, getItems, setRef, onChange)
    - UI.buttonRow(page, label, order, callback, desc)
    - UI.textRow(page, label, order, desc)
    - UI.showToast(title, message, duration)
    - UI.showCenterModalWarning(opts)
    - UI.setWindowMode(isFullSize)
    - UI.getWindowMode()
    - UI.destroyPanel()
    - UI.isAlive()
    ============================================================================
]]

-- Services
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local SoundService      = game:GetService("SoundService")
local LocalPlayer       = Players.LocalPlayer

local UI
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
        Background    = Color3.fromRGB(10, 10, 12),       -- #0A0A0C
        Window        = Color3.fromRGB(10, 10, 12),
        TopBar        = Color3.fromRGB(10, 10, 12),
        Sidebar       = Color3.fromRGB(13, 13, 16),       -- #0D0D10
        Card          = Color3.fromRGB(18, 18, 23),       -- #121217
        Control       = Color3.fromRGB(18, 18, 23),
        CardHover     = Color3.fromRGB(25, 25, 33),       -- #191921
        CardActive    = Color3.fromRGB(30, 30, 40),       -- #1E1E28
        Border        = Color3.fromRGB(30, 30, 38),       -- #1E1E26
        BorderLight   = Color3.fromRGB(48, 48, 62),       -- #30303E
        Text          = Color3.fromRGB(255, 255, 255),
        SubText       = Color3.fromRGB(145, 145, 160),   -- #9191A0
        TextSecondary = Color3.fromRGB(145, 145, 160),
        TextDisabled  = Color3.fromRGB(85, 85, 100),     -- #555564
        Accent        = Color3.fromRGB(255, 255, 255),
        AccentDim     = Color3.fromRGB(24, 24, 32),
        Money         = Color3.fromRGB(48, 209, 88),      -- #30D158
        Success       = Color3.fromRGB(48, 209, 88),
        Danger        = Color3.fromRGB(255, 69, 58),
    }

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

    local guiTag = "SAE_GUI_TAG"
    do
        local seen, roots = {}, { CoreParent }
        pcall(function() if gethui then roots[#roots + 1] = gethui() end end)
        pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
        for _, root in ipairs(roots) do
            if root and not seen[root] then
                seen[root] = true
                pcall(function()
                    for _, g in ipairs(root:GetChildren()) do
                        if g:GetAttribute(guiTag) or g.Name == "StealFix_Panel" then pcall(function() g:Destroy() end) end
                    end
                end)
            end
        end
    end

    local randomGuiName = ""
    for _ = 1, 16 do randomGuiName = randomGuiName .. string.char(math.random(97, 122)) end

    local ScreenGui = new("ScreenGui", { Name = randomGuiName, Parent = CoreParent, ResetOnSpawn = false,
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
    local WIN_COMPACT = Vector2.new(650, 390)   -- HP / layar kecil (perilaku lama)
    local WIN_PC      = Vector2.new(860, 700)   -- PC: ukuran LAYOUT (ruang buat baris)
    -- Zoom render PC. Dipisah dari WIN_PC dengan sengaja:
    --   WIN_PC  = berapa banyak yang MUAT  (ubah ini kalau mau nambah/kurangin isi)
    --   PC_ZOOM = seberapa BESAR keliatan  (ubah ini kalau cuma mau gedein/kecilin)
    -- Motong lebar WIN_PC buat ngecilin itu jebakan: konten Steal pernah keukur 798 unit
    -- di lebar 650 dan cuma 562 di lebar 860 — barisnya numpuk ke bawah kalau sempit,
    -- jadi ngecilin lewat lebar malah munculin scroll lagi. Zoom gak ngubah layout.
    local PC_ZOOM     = 0.80                    -- 860x700 -> render 688x560
    -- Default ikut perangkat: PC (bukan touch) langsung full size.
    local pcFullSize  = not UserInputService.TouchEnabled

    local Window = new("Frame", { Name = "Window", Parent = ScreenGui, AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, WIN_COMPACT.X, 0, WIN_COMPACT.Y), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = Theme.Window,
        BackgroundTransparency = 0, BorderSizePixel = 0, Active = true, ClipsDescendants = true, Visible = false }, {
        corner(14), stroke(Theme.Border, 1.2)
    })

    -- ===================== ANNOUNCEMENT POP-UP (BEFORE MAIN WINDOW) =====================
    -- Konfigurasi Pengumuman: sangat mudah diubah teks & fiturnya di masa depan
    local ANNOUNCEMENT_CONFIG = {
        title = "TRACK YOUR INVENTORY ON OUR WEBSITE FREE!",
        linkPrefix = "visit : ",
        url = "www.nrlscript.com/monitor",
        linkSuffix = "\nand input your key! Click here to copy links!",
        featuresHeader = "New Features :",
        features = {
            "+ Added Anti-afk (Auto)",
            "+ Added Live Web Monitor",
            "+ Fixed Auto Steal",
            "+ Added Discord Webhook",
        },
        buttonText = "Enter Script",
    }

    local AnnounceModal = new("Frame", {
        Name = "AnnouncementModal", Parent = ScreenGui, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 480, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Window, BackgroundTransparency = 0.02, BorderSizePixel = 0,
        Active = true, ClipsDescendants = true, ZIndex = 500,
    }, {
        corner(14),
        stroke(Theme.BorderLight, 1.4),
        new("UIPadding", { PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 18), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20) }),
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
    })

    local AnnounceScale = new("UIScale", { Parent = AnnounceModal })
    local function fitAnnounce()
        local cam = workspace.CurrentCamera
        local vp = (cam and cam.ViewportSize) or Vector2.new(800, 600)
        local s = math.min((vp.X - 20) / 480, (vp.Y - 20) / 380)
        if UserInputService.TouchEnabled then s = s * 0.9 end
        AnnounceScale.Scale = math.clamp(s, 0.3, 1.0)
    end
    fitAnnounce()
    trackConn(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(fitAnnounce))

    -- Header Top Bar (Title & Top Close 'X' Button)
    local AnnounceTopBar = new("Frame", { Parent = AnnounceModal, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, LayoutOrder = 1 }, {
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }),
    })
    new("ImageLabel", { Parent = AnnounceTopBar, Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Image = Icons.Logo, ImageColor3 = Theme.Text, LayoutOrder = 1 })
    new("TextLabel", { Parent = AnnounceTopBar, Size = UDim2.new(1, -56, 1, 0), Position = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1, Font = FONT_BOLD, Text = "ANNOUNCEMENT", TextColor3 = Theme.Text, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2 })
    
    local TopCloseBtn = new("TextButton", { Parent = AnnounceTopBar, Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 0.5, Font = FONT_BOLD, Text = "✕",
        TextColor3 = Theme.SubText, TextSize = 13, AutoButtonColor = false, LayoutOrder = 3 }, { corner(6) })

    -- Main Header Message (Upper Case)
    new("TextLabel", { Parent = AnnounceModal, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Font = FONT_BOLD, Text = ANNOUNCEMENT_CONFIG.title,
        TextColor3 = Color3.fromRGB(255, 215, 95), TextSize = 15.5, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = 2 })

    -- Clickable Visit & Copy Link Card
    local LinkCard = new("TextButton", { Parent = AnnounceModal, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.3, AutoButtonColor = false, Text = "",
        LayoutOrder = 3 }, {
        corner(8),
        stroke(Theme.Border, 1),
        new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }),
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
    })
    
    local linkTextLabel = new("TextLabel", { Parent = LinkCard, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Font = FONT,
        Text = ANNOUNCEMENT_CONFIG.linkPrefix .. ANNOUNCEMENT_CONFIG.url .. ANNOUNCEMENT_CONFIG.linkSuffix,
        TextColor3 = Theme.Text, TextSize = 13.5, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = 1 })

    local function copyUrl()
        pcall(function()
            if typeof(setclipboard) == "function" then
                setclipboard("https://" .. ANNOUNCEMENT_CONFIG.url)
            elseif typeof(toclipboard) == "function" then
                toclipboard("https://" .. ANNOUNCEMENT_CONFIG.url)
            end
        end)
        linkTextLabel.Text = "✓ URL Copied to Clipboard!\n(" .. ANNOUNCEMENT_CONFIG.url .. ")"
        linkTextLabel.TextColor3 = Theme.Success
        task.delay(2.5, function()
            if linkTextLabel and linkTextLabel.Parent then
                linkTextLabel.Text = ANNOUNCEMENT_CONFIG.linkPrefix .. ANNOUNCEMENT_CONFIG.url .. ANNOUNCEMENT_CONFIG.linkSuffix
                linkTextLabel.TextColor3 = Theme.Text
            end
        end)
    end
    LinkCard.MouseButton1Click:Connect(copyUrl)
    LinkCard.MouseEnter:Connect(function()
        TweenService:Create(LinkCard, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundColor3 = Theme.CardHover }):Play()
    end)
    LinkCard.MouseLeave:Connect(function()
        TweenService:Create(LinkCard, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundColor3 = Theme.Card }):Play()
    end)

    -- Console-like Box for New Features
    local consoleCard = new("Frame", { Parent = AnnounceModal, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(12, 12, 16), BackgroundTransparency = 0.1, BorderSizePixel = 0,
        LayoutOrder = 4 }, {
        corner(8),
        stroke(Color3.fromRGB(38, 38, 48), 1),
        new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Left }),
    })

    new("TextLabel", { Parent = consoleCard, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
        Font = Enum.Font.Code, Text = ANNOUNCEMENT_CONFIG.featuresHeader, TextColor3 = Color3.fromRGB(130, 210, 255),
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1 })

    for idx, featureText in ipairs(ANNOUNCEMENT_CONFIG.features) do
        new("TextLabel", { Parent = consoleCard, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Font = Enum.Font.Code, Text = featureText, TextColor3 = Color3.fromRGB(170, 235, 170),
            TextSize = 12.5, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1 + idx })
    end

    -- Bottom Close / Enter Button with 7s Countdown
    local autoEnterSeconds = 10
    local isDismissed = false

    local EnterButton = new("TextButton", { Parent = AnnounceModal, Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(245, 245, 245), AutoButtonColor = false, Font = FONT_BOLD,
        Text = string.format("%s (%ds)", ANNOUNCEMENT_CONFIG.buttonText, autoEnterSeconds),
        TextColor3 = Color3.fromRGB(15, 15, 20), TextSize = 14.5,
        LayoutOrder = 5 }, { corner(8) })

    EnterButton.MouseEnter:Connect(function()
        TweenService:Create(EnterButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundColor3 = Color3.fromRGB(215, 215, 225) }):Play()
    end)
    EnterButton.MouseLeave:Connect(function()
        TweenService:Create(EnterButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundColor3 = Color3.fromRGB(245, 245, 245) }):Play()
    end)

    local dismissAnnouncement
    dismissAnnouncement = function()
        if isDismissed then return end
        isDismissed = true
        if not AnnounceModal or not AnnounceModal.Parent then return end
        local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
        TweenService:Create(AnnounceScale, tInfo, { Scale = 0.85 }):Play()
        TweenService:Create(AnnounceModal, tInfo, { BackgroundTransparency = 1 }):Play()
        task.delay(0.22, function()
            if AnnounceModal and AnnounceModal.Parent then AnnounceModal:Destroy() end
        end)
        if typeof(openWindow) == "function" then
            openWindow()
        else
            Window.Visible = true
            Window.BackgroundTransparency = 0
        end
    end

    TopCloseBtn.MouseButton1Click:Connect(function() dismissAnnouncement() end)
    EnterButton.MouseButton1Click:Connect(function() dismissAnnouncement() end)

    -- Auto-enter countdown thread (7 detik)
    task.spawn(function()
        for sec = autoEnterSeconds, 1, -1 do
            if isDismissed or not AnnounceModal.Parent then break end
            EnterButton.Text = string.format("%s (%ds)", ANNOUNCEMENT_CONFIG.buttonText, sec)
            task.wait(1)
        end
        if not isDismissed and AnnounceModal and AnnounceModal.Parent then
            dismissAnnouncement()
        end
    end)

    local WindowScale = new("UIScale", { Parent = Window })
    local function fitWindow()
        local base = pcFullSize and WIN_PC or WIN_COMPACT
        Window.Size = UDim2.new(0, base.X, 0, base.Y)
        local cam = workspace.CurrentCamera
        local vp = (cam and cam.ViewportSize) or Vector2.new(800, 600)
        -- CATATAN: dulu pembaginya hardcode 640/360 padahal Window-nya 650/390 — gak
        -- sinkron. Sekarang selalu ngikut base yang lagi aktif.
        local s = math.min((vp.X - 20) / base.X, (vp.Y - 20) / base.Y)
        if UserInputService.TouchEnabled then s = s * 0.88 end
        -- Ceiling PC = PC_ZOOM: di layar lega panelnya berhenti di situ, gak makin gede
        -- ngikut monitor. Di layar sempit `s` yang lebih kecil tetep menang, jadi masih
        -- ngecil sendiri biar gak kepotong. Touch tetep 0.88 kayak sebelumnya.
        local finalScale = math.clamp(s, 0.25, pcFullSize and PC_ZOOM or 0.88)
        WindowScale:SetAttribute("TargetScale", finalScale)
        WindowScale.Scale = finalScale
    end
    -- AnchorPoint-nya (0.5,0.5) jadi window membesar dari titik tengahnya. Kalau tadinya
    -- di-drag mepet pinggir, pas gede bisa nyembul keluar layar — makanya balikin ke
    -- tengah tiap ganti mode.
    local function centerWindow()
        Window.Position = UDim2.new(0.5, 0, 0.5, 0)
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

    local TopBar = new("Frame", { Name = "TopBar", Parent = Window, Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.TopBar, BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 20 }, {
        corner(14),
        new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, ZIndex = 21 })
    })

    new("ImageLabel", { Parent = TopBar, Size = UDim2.fromOffset(28, 28), Position = UDim2.new(0, 14, 0.5, -14),
        BackgroundTransparency = 1, Image = Icons.Logo, ImageColor3 = Theme.Text, ScaleType = Enum.ScaleType.Fit,
        ResampleMode = Enum.ResamplerMode.Pixelated, ZIndex = 23 })
    new("TextLabel", { Parent = TopBar, Size = UDim2.new(0, 200, 0, 14), Position = UDim2.new(0, 48, 0, 6),
        BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Nasi Rendang - nrlscript.com",
        TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 23 })
    new("TextLabel", { Parent = TopBar, Size = UDim2.new(0, 200, 0, 12), Position = UDim2.new(0, 48, 0, 20),
        BackgroundTransparency = 1, Font = FONT, Text = "Steal an Egg",
        TextColor3 = Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 23 })

    local TAB_WIDTH = 32
    local TAB_GAP = 6
    local INDICATOR_WIDTH = 20
    local TAB_STEP = TAB_WIDTH + TAB_GAP

    local CenterNav = new("Frame", { Parent = TopBar, Size = UDim2.new(0, 0, 1, 0), Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, ZIndex = 22 })
    local CenterNavHolder = new("Frame", { Parent = CenterNav, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, ZIndex = 23 }, {
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, TAB_GAP) })
    })
    local SlidingIndicator = new("Frame", { Parent = CenterNav, Size = UDim2.fromOffset(INDICATOR_WIDTH, 2), Position = UDim2.new(0, 6, 1, -2),
        BackgroundColor3 = Theme.Text, BorderSizePixel = 0, ZIndex = 25 }, { corner(2) })

    local topTabButtons = {}
    local activeTopTabId = 1

    local function createTopIcon(iconAsset, onClick)
        local tabId = #topTabButtons + 1
        local isActive = (tabId == 1)

        local tabBtn = new("TextButton", { Parent = CenterNavHolder, Size = UDim2.fromOffset(TAB_WIDTH, 32),
            BackgroundColor3 = Theme.Card, BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 24 }, { corner(6) })

        local icon = new("ImageLabel", { Parent = tabBtn, Size = UDim2.fromOffset(16, 16), Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = iconAsset,
            ImageColor3 = isActive and Theme.Text or Theme.TextSecondary, ZIndex = 25 })

        tabBtn.MouseEnter:Connect(function()
            if activeTopTabId ~= tabId then
                TweenService:Create(tabBtn, TweenInfo.new(0.18), { BackgroundTransparency = 0.85 }):Play()
                TweenService:Create(icon, TweenInfo.new(0.18), { ImageColor3 = Color3.fromRGB(220, 220, 235) }):Play()
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTopTabId ~= tabId then
                TweenService:Create(tabBtn, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(icon, TweenInfo.new(0.18), { ImageColor3 = Theme.TextSecondary }):Play()
            end
        end)
        tabBtn.MouseButton1Click:Connect(function()
            activeTopTabId = tabId
            for _, b in ipairs(topTabButtons) do
                local active = (b.id == tabId)
                TweenService:Create(b.icon, TweenInfo.new(0.18), { ImageColor3 = active and Theme.Text or Theme.TextSecondary }):Play()
            end
            local targetX = (tabId - 1) * TAB_STEP + math.floor((TAB_WIDTH - INDICATOR_WIDTH) / 2)
            TweenService:Create(SlidingIndicator, TweenInfo.new(0.28, Enum.EasingStyle.Cubic), { Position = UDim2.new(0, targetX, 1, -2) }):Play()
            if onClick then onClick() end
        end)

        table.insert(topTabButtons, { btn = tabBtn, icon = icon, id = tabId })
        return tabBtn
    end

    local function setTopActiveTab(tabId)
        activeTopTabId = tabId
        for _, b in ipairs(topTabButtons) do
            local active = (b.id == tabId)
            TweenService:Create(b.icon, TweenInfo.new(0.18), { ImageColor3 = active and Theme.Text or Theme.TextSecondary }):Play()
        end
        local targetX = (tabId - 1) * TAB_STEP + math.floor((TAB_WIDTH - INDICATOR_WIDTH) / 2)
        TweenService:Create(SlidingIndicator, TweenInfo.new(0.28, Enum.EasingStyle.Cubic), { Position = UDim2.new(0, targetX, 1, -2) }):Play()
    end

    local Pill = new("Frame", { Parent = TopBar, Size = UDim2.new(0, 168, 0, 24), Position = UDim2.new(1, -264, 0.5, -12),
        BackgroundColor3 = Theme.Control, BackgroundTransparency = 0, ZIndex = 22 }, { corner(6), stroke(Theme.Border, 1) })
    new("Frame", { Parent = Pill, Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 7, 0.5, -3),
        BackgroundColor3 = Theme.Money, ZIndex = 23 }, { corner(3) })
    local PillLabel = new("TextLabel", { Parent = Pill, Size = UDim2.new(1, -18, 1, 0), Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1, Font = FONT_BOLD, Text = "0 stolen  •  -- FPS  •  0 studs",
        TextColor3 = Theme.Text, TextSize = 12.5, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 23 })

    local WindowControls = new("Frame", { Parent = TopBar, Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(1, -90, 0, 0),
        BackgroundTransparency = 1, ZIndex = 22 }, {
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4) }),
        new("UIPadding", { PaddingRight = UDim.new(0, 10) })
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

    local MinButton = createWinBtn("-")
    local ScaleButton = createWinBtn("[ ]")
    ScaleButton.MouseButton1Click:Connect(function() fitWindow(); showToast("Window Scaled to fit viewport") end)
    local CloseButton = createWinBtn("x", true)

    local Sidebar = new("Frame", { Name = "Sidebar", Parent = Window, Size = UDim2.new(0, 150, 1, -40),
        Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0,
        BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 10 }, {
        corner(14),
        new("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, ZIndex = 11 })
    })

    local CollapseBtn = new("TextButton", { Parent = Sidebar, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -26, 0, 6),
        BackgroundTransparency = 1, Text = "<", Font = FONT_BOLD, TextSize = 13, TextColor3 = Theme.SubText, ZIndex = 12 })
    local isCollapsed = false

    local NavScroll = new("ScrollingFrame", { Parent = Sidebar, Size = UDim2.new(1, 0, 1, -125), Position = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 12 })

    local NavHighlight = new("Frame", { Parent = NavScroll, BackgroundColor3 = Color3.fromRGB(22, 22, 28), BackgroundTransparency = 0,
        BorderSizePixel = 0, ZIndex = 13, Size = UDim2.new(1, -12, 0, 32), Position = UDim2.new(0, 6, 0, 4), Visible = true }, {
        corner(8),
        stroke(Theme.BorderLight, 1, 0.4)
    })

    local NavList = new("Frame", { Parent = NavScroll, Name = "NavList", Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 14 }, {
        new("UIListLayout", { Padding = UDim.new(0, 3) }),
        new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })
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

    local FooterFrame = new("Frame", { Parent = Sidebar, Size = UDim2.new(1, -12, 0, 78), Position = UDim2.new(0, 6, 1, -85),
        BackgroundTransparency = 1, ZIndex = 12 }, {
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
    addFooterLink(Icons.Discord, "Discord", "discord.gg/nasirendanglua", "https://discord.gg/nasirendanglua")

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

    local function switchPage(name)
        for pn, pg in pairs(Pages) do if pn ~= name then pg.Visible = false end end
        for nn, b in pairs(NavButtons) do
            local active = (nn == name)
            local lbl = b:FindFirstChild("Label")
            local ic = b:FindFirstChild("Icon")
            if lbl then
                lbl.TextColor3 = active and Theme.Text or Theme.TextSecondary
                lbl.Font = active and FONT_BOLD or FONT
            end
            if ic then ic.ImageColor3 = active and Theme.Text or Theme.TextSecondary end
            if not active then b.BackgroundTransparency = 1 end   -- reset sisa hover
            if active then activeNav = b end
        end
        moveHighlightTo(activeNav, true)   -- geser mulus ke baris aktif
        local target = Pages[name]
        if target then
            target.Position = UDim2.new(0, 22, 0, 0); target.Visible = true
            TweenService:Create(target, PAGE_TWEEN, { Position = UDim2.new(0, 0, 0, 0) }):Play()
            if name == "Predict" and UIX and UIX.refreshPredict then
                task.spawn(UIX.refreshPredict)
            end
        end

        -- Sync center nav top bar indicator
        if setTopActiveTab then
            if name == "Settings" then setTopActiveTab(1)
            elseif name == "Steal" then setTopActiveTab(2)
            elseif name == "FPS Boost" then setTopActiveTab(3)
            end
        end
    end

    createTopIcon(Icons.Settings, function() switchPage("Settings") end)
    createTopIcon("rbxassetid://129870722044860", function() switchPage("Steal") end)
    createTopIcon(Icons.FPS, function() switchPage("FPS Boost") end)

    local function navItem(text, pageName, order, icon)
        local btn = new("TextButton", { Parent = NavList, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = order,
            BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 15 }, { corner(8) })
        local labelX = 10
        local imgIcon
        if icon then
            imgIcon = new("ImageLabel", { Parent = btn, Name = "Icon", Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(0, 8, 0.5, -7),
                BackgroundTransparency = 1, Image = icon, ImageColor3 = Theme.TextSecondary, ScaleType = Enum.ScaleType.Fit, ZIndex = 16 })
            labelX = 30
        end
        local lbl = new("TextLabel", { Parent = btn, Name = "Label", Size = UDim2.new(1, -(labelX + 6), 1, 0), Position = UDim2.new(0, labelX, 0, 0),
            BackgroundTransparency = 1, Font = FONT, Text = text, TextSize = 14, TextColor3 = Theme.TextSecondary,
            ZIndex = 16, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
        btn.MouseEnter:Connect(function()
            if activeNav ~= btn then
                TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 0.55 }):Play()
                TweenService:Create(lbl, TweenInfo.new(0.18), { TextColor3 = Color3.fromRGB(210, 210, 225) }):Play()
                if imgIcon then TweenService:Create(imgIcon, TweenInfo.new(0.18), { ImageColor3 = Color3.fromRGB(210, 210, 225) }):Play() end
            end
        end)
        btn.MouseLeave:Connect(function()
            if activeNav ~= btn then
                TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(lbl, TweenInfo.new(0.18), { TextColor3 = Theme.TextSecondary }):Play()
                if imgIcon then TweenService:Create(imgIcon, TweenInfo.new(0.18), { ImageColor3 = Theme.TextSecondary }):Play() end
            end
        end)
        btn.MouseButton1Click:Connect(function() switchPage(pageName) end)
        NavButtons[pageName] = btn
        return btn
    end

    local ContentHost = new("Frame", { Name = "Content", Parent = Window, Size = UDim2.new(1, -150, 1, -40),
        Position = UDim2.new(0, 150, 0, 40), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 10 })

    CollapseBtn.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        local targetW = isCollapsed and 46 or 150
        TweenService:Create(Sidebar, TweenInfo.new(0.28, Enum.EasingStyle.Cubic), { Size = UDim2.new(0, targetW, 1, -40) }):Play()
        TweenService:Create(ContentHost, TweenInfo.new(0.28, Enum.EasingStyle.Cubic), {
            Size = UDim2.new(1, -targetW, 1, -40), Position = UDim2.new(0, targetW, 0, 40)
        }):Play()
        CollapseBtn.Text = isCollapsed and ">" or "<"
    end)
    new("UIPadding", { Parent = ContentHost, PaddingTop = UDim.new(0, 14), PaddingLeft = UDim.new(0, 18),
        PaddingRight = UDim.new(0, 18), PaddingBottom = UDim.new(0, 14) })

    local function makePage(name)
        local page = new("ScrollingFrame", { Name = name, Parent = ContentHost, Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, Visible = false, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Border, ScrollBarImageTransparency = 0.3 })
        new("UIListLayout", { Parent = page, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
        new("UIPadding", { Parent = page, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 24), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 8) })

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

        Pages[name] = page
        return page
    end

    local pageActiveCards = {}

    local function createSection(page, sectionTitle, order)
        local head = new("Frame", { Parent = page, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = order or 1, BackgroundTransparency = 1, ZIndex = 12 })
        new("TextLabel", { Parent = head, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, Font = FONT_BOLD, Text = sectionTitle, TextColor3 = Theme.Text, TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13 })

        local card = new("Frame", { Parent = page, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = (order or 1) + 1,
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Card, BorderSizePixel = 0, ZIndex = 12 }, {
            corner(10),
            stroke(Theme.Border, 1, 0.6),
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }),
            new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
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
        local btn = new("TextButton", { Parent = target, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = order,
            BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 0.5, AutoButtonColor = false,
            Font = FONT_BOLD, Text = label, TextColor3 = Theme.Text, TextSize = 15 },
            { corner(8), stroke(Theme.BorderLight, 1, 0.4) })
        btn.MouseButton1Click:Connect(function()
            local ok, err = pcall(onClick, btn); if not ok then warn("[UI] button error: " .. tostring(err)) end
        end)
        return btn
    end

    local function toggleRow(page, label, order, onChange, initial, desc)
        local target = page:IsA("ScrollingFrame") and getCurrentCard(page, order) or page
        local row = new("Frame", { Parent = target, Size = UDim2.new(1, 0, 0, desc and 36 or 28), LayoutOrder = order, BackgroundTransparency = 1 })
        new("TextLabel", { Parent = row, Size = UDim2.new(1, -50, 0, 16), Position = UDim2.new(0, 0, 0, desc and 2 or 6),
            BackgroundTransparency = 1, Font = FONT, Text = label, TextColor3 = Theme.TextSecondary, TextSize = 14.5,
            TextXAlignment = Enum.TextXAlignment.Left })
        if desc then
            new("TextLabel", { Parent = row, Size = UDim2.new(1, -50, 0, 14), Position = UDim2.new(0, 0, 0, 20),
                BackgroundTransparency = 1, Font = FONT, Text = desc, TextColor3 = Theme.TextDisabled, TextSize = 12.5,
                TextXAlignment = Enum.TextXAlignment.Left })
        end

        local state = not not initial
        local togglePill = new("TextButton", { Parent = row, Size = UDim2.fromOffset(32, 16), Position = UDim2.new(1, -34, 0.5, -8),
            BackgroundColor3 = state and Theme.Text or Theme.CardHover, BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 13 }, {
            corner(8),
            stroke(Theme.BorderLight, 1, 0.5),
        })

        local knob = new("Frame", { Parent = togglePill, Size = UDim2.fromOffset(12, 12),
            Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
            BackgroundColor3 = state and Theme.Background or Theme.TextSecondary, BorderSizePixel = 0, ZIndex = 14 }, { corner(6) })

        local function render()
            local targetPos = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            local targetPillColor = state and Theme.Text or Theme.CardHover
            local targetKnobColor = state and Theme.Background or Theme.TextSecondary
            TweenService:Create(knob, TweenInfo.new(0.18), { Position = targetPos, BackgroundColor3 = targetKnobColor }):Play()
            TweenService:Create(togglePill, TweenInfo.new(0.18), { BackgroundColor3 = targetPillColor }):Play()
        end

        togglePill.MouseButton1Click:Connect(function()
            state = not state; render()
            if onChange then onChange(state) end
        end)
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
            local lblText = opt.label .. (opt.locked and " 🔒" or "")
            new("TextLabel", { Parent = half, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1, Font = FONT, Text = lblText,
                TextColor3 = opt.locked and Color3.fromRGB(255, 216, 92) or Theme.TextSecondary, TextSize = 14.5,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })

            local state = (not opt.locked) and (not not opt.initial)
            local togglePill = new("TextButton", { Parent = half, Size = UDim2.fromOffset(32, 16), Position = UDim2.new(1, -32, 0.5, -8),
                BackgroundColor3 = state and Theme.Text or Theme.CardHover, BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 13 }, {
                corner(8),
                stroke(opt.locked and Color3.fromRGB(255, 216, 92) or Theme.BorderLight, 1, 0.5),
            })

            local knob = new("Frame", { Parent = togglePill, Size = UDim2.fromOffset(12, 12),
                Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                BackgroundColor3 = state and Theme.Background or Theme.TextSecondary, BorderSizePixel = 0, ZIndex = 14 }, { corner(6) })

            local function render()
                local targetPos = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                local targetPillColor = state and Theme.Text or Theme.CardHover
                local targetKnobColor = state and Theme.Background or Theme.TextSecondary
                TweenService:Create(knob, TweenInfo.new(0.18), { Position = targetPos, BackgroundColor3 = targetKnobColor }):Play()
                TweenService:Create(togglePill, TweenInfo.new(0.18), { BackgroundColor3 = targetPillColor }):Play()
            end

            togglePill.MouseButton1Click:Connect(function()
                if opt.locked then
                    if opt.onLockClick then
                        opt.onLockClick()
                    else
                        pcall(function() showToast(tostring(opt.label) .. " is locked (Lifetime/Premium/Gold required)") end)
                    end
                    return
                end
                state = not state; render()
                if opt.onChange then opt.onChange(state) end
            end)
            return {
                Set = function(v)
                    if opt.locked and v then return end
                    state = not not v; render()
                end,
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
        local row = new("Frame", { Parent = target, Size = UDim2.new(1, 0, 0, 44), LayoutOrder = order, BackgroundTransparency = 1 })
        new("TextLabel", { Parent = row, Size = UDim2.new(0.7, 0, 0, 16), Position = UDim2.new(0, 0, 0, 3),
            BackgroundTransparency = 1, Font = FONT, Text = label, TextColor3 = Theme.TextSecondary, TextSize = 14.5,
            TextXAlignment = Enum.TextXAlignment.Left })
        local valLbl = new("TextLabel", { Parent = row, Size = UDim2.new(0.3, 0, 0, 16), Position = UDim2.new(0.7, 0, 0, 3),
            BackgroundTransparency = 1, Font = FONT_BOLD, Text = tostring(value) .. sfx, TextColor3 = Theme.Text,
            TextSize = 14.5, TextXAlignment = Enum.TextXAlignment.Right })
        local track = new("Frame", { Parent = row, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0, 26),
            BackgroundColor3 = Theme.CardHover, BorderSizePixel = 0, ZIndex = 13 }, { corner(2) })
        local fracInit = math.clamp((value - minV) / (maxV - minV), 0, 1)
        local fill = new("Frame", { Parent = track, Size = UDim2.new(fracInit, 0, 1, 0),
            BackgroundColor3 = Theme.Text, BorderSizePixel = 0, ZIndex = 14 }, { corner(2) })
        local knob = new("Frame", { Parent = track, Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(fracInit, 0, 0.5, 0), BackgroundColor3 = Theme.Text, BorderSizePixel = 0, ZIndex = 16 }, {
            corner(6), stroke(Theme.Window, 1.5)
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
        local box = new("TextBox", { Parent = row, Size = UDim2.new(0.6, 0, 0, 24), Position = UDim2.new(0.4, 0, 0.5, -12),
            BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 0.5, Font = FONT, Text = default or "",
            PlaceholderText = placeholder or "...", TextColor3 = Theme.Text,
            PlaceholderColor3 = Theme.TextDisabled, TextSize = 14, ClearTextOnFocus = false },
            { corner(5), stroke(Theme.BorderLight, 1, 0.4) })
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
                    pcall(updateSummary)
                    if onChange then pcall(onChange, setRef) end
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

    MinButton.MouseButton1Click:Connect(minimizeWindow)

    CloseButton.MouseButton1Click:Connect(function()
        destroyPanel()
        if FloatingToggle and FloatingToggle.Parent then FloatingToggle:Destroy() end
    end)

    trackConn(UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
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
        WIN_T = 0,
        CTRL_T = 0,
    }
end


return UI
