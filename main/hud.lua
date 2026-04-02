local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local StarIliadMainMenu = require "screens/stariliad_main_menu"
local BlytheMissileStatus = require "widgets/blythe_missile_status"
local BlytheTV = require "widgets/blythe_tv"
local StarIliadTipUI = require "widgets/stariliad_tip_ui"
local StariliadShakingText = require "widgets/stariliad_shaking_text"
local StarIliadOpening = require "cutscenes/stariliad_opening/stariliad_opening"

AddClassPostConstruct("widgets/controls", function(self)
    if self.owner:HasTag("blythe") then
        self.StarIliadMenuCaller_root = self:AddChild(Widget("StarIliadMenuCaller_root"))
        self.StarIliadMenuCaller_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.StarIliadMenuCaller_root:SetHAnchor(ANCHOR_LEFT)
        self.StarIliadMenuCaller_root:SetVAnchor(ANCHOR_BOTTOM)
        self.StarIliadMenuCaller_root:SetMaxPropUpscale(MAX_HUD_SCALE)

        self.StarIliadMenuCaller = self.StarIliadMenuCaller_root:AddChild(
            TEMPLATES.StandardButton(
                function()
                    local main_menu = StarIliadMainMenu(self.owner)
                    TheFrontEnd:PushScreen(main_menu)
                end,
                STRINGS.STARILIAD_UI.MAIN_MENU.CALLER_TEXT,
                { 140, 60 }
            )
        )

        self.StarIliadMenuCaller:SetPosition(75, 28)

        -- self.StarIliadDebugButton = self.StarIliadMenuCaller_root:AddChild(
        --     TEMPLATES.StandardButton(
        --         function()
        --             TheFrontEnd:PushScreen(StarIliadOpening())
        --         end,
        --         "DEBUG BUTTON",
        --         { 140, 60 }
        --     )
        -- )

        -- self.StarIliadDebugButton:SetPosition(75, 100)


        -- Blythe TV
        self.BlytheTV = self.topright_root:AddChild(BlytheTV(self.owner))
        self.BlytheTV:SetPosition(100, -120)
        self.BlytheTV:MoveToBack()

        -- Tips
        self.StarIliadTipUI = self.bottom_root:AddChild(StarIliadTipUI(self.owner))
        self.StarIliadTipUI:SetPosition(0, 150)


        -- self.test_shaking_text = self.owner.HUD:AddChild(StariliadShakingText(TALKINGFONT, 50,
        --     STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_BOSS_GUARDIAN.DESTROY3, { 238 / 255, 69 / 255, 105 / 255, 1 }))
        -- -- self.test_shaking_text:SetPosition(0, 300)
        -- self.test_shaking_text:SetTarget(self.owner, "head_base", Vector3(0, -500, 0))
    end
end)

AddClassPostConstruct("widgets/secondarystatusdisplays", function(self)
    if self.owner:HasTag("blythe") then
        self.blythe_missile_status = self:AddChild(BlytheMissileStatus(self.owner))
        self.blythe_missile_status:SetPosition(60, -80)
        self.blythe_missile_status:MoveToFront()
    end
end)

AddClassPostConstruct("screens/redux/lobbyscreen", function(self)
    self.no_more_sound = false

    local old_self_cb = self.cb

    local old_StartLobbyMusic = self.StartLobbyMusic
    self.StartLobbyMusic = function(self, ...)
        -- print("StartLobbyMusic!!!",self.issoundplaying)
        if self.no_more_sound then
            self:StopLobbyMusic()
            return
        end
        return old_StartLobbyMusic(self, ...)
    end

    -- local old_StopLobbyMusic = self.StopLobbyMusic
    -- self.StopLobbyMusic = function(self,...)
    --     print("StopLobbyMusic!!!",self.issoundplaying)
    --     return old_StopLobbyMusic(self,...)
    -- end

    self.cb = function(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet, ...)
        -- print(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)

        -- if char == "blythe" and not ReadHaveSeenFirstPlayCG() then
        if char == "blythe" then
            self.no_more_sound = true
            self:StopLobbyMusic()

            local opening = StarIliadOpening()

            local old_OnDestroy = opening.OnDestroy
            opening.OnDestroy = function(his_self, ...)
                old_OnDestroy(his_self, ...)
                old_self_cb(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
            end

            opening.inst:DoTaskInTime(70, function()
                TheFrontEnd:PopScreen(opening)
            end)

            TheFrontEnd:PushScreen(opening)
            -- TheFrontEnd:PushScreen(GaleFirstCG(function()
            --     self.black = self:AddChild(Image("images/global.xml", "square.tex"))
            --     self.black:SetVRegPoint(ANCHOR_MIDDLE)
            --     self.black:SetHRegPoint(ANCHOR_MIDDLE)
            --     self.black:SetVAnchor(ANCHOR_MIDDLE)
            --     self.black:SetHAnchor(ANCHOR_MIDDLE)
            --     self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
            --     self.black:SetTint(0, 0, 0, 1)
            --     self.black:MoveToFront()
            --     WriteHaveSeenFirstPlayCG()
            --     old_self_cb(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
            -- end))
        else
            return old_self_cb(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet, ...)
        end
    end
end)
