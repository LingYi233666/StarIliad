local PopupDialogScreen = require "screens/redux/popupdialog"

local StarIliadKeyConfigDialog = Class(PopupDialogScreen,
    function(self, owner, target_skill_name)
        PopupDialogScreen._ctor(self, STRINGS.STARILIAD_UI.KEY_CONFIG_DIALOG.TITLE,
            STRINGS.STARILIAD_UI.KEY_CONFIG_DIALOG.TEXT_BEFORE, {
                -- Buttons:
                {
                    text = STRINGS.STARILIAD_UI.KEY_CONFIG_DIALOG.DO_SET_SKILL_KEY,
                    cb = function()
                        if self.selected_button then
                            self.owner.replica.blythe_skiller:SetInputHandler(
                                self.selected_button, self.target_skill_name, true)
                            self.owner.replica.blythe_skiller:PrintInputHandler()
                            self.owner:PushEvent("blythe_skiller_ui_update")
                        else
                            print("key_select_ui No setting !")
                        end
                        TheFrontEnd:PopScreen(self)
                    end
                }, {
                text = STRINGS.STARILIAD_UI.KEY_CONFIG_DIALOG.CLEAR_SKILL_KEY,
                cb = function()
                    self.owner.replica.blythe_skiller:RemoveInputHandler(
                        self.target_skill_name, true)
                    self.owner.replica.blythe_skiller:PrintInputHandler()
                    self.owner:PushEvent("blythe_skiller_ui_update")
                    TheFrontEnd:PopScreen(self)
                end
            }, {
                text = STRINGS.STARILIAD_UI.KEY_CONFIG_DIALOG.SET_KEY_CANCEL,
                cb = function() TheFrontEnd:PopScreen(self) end
            }
            })

        self.owner = owner
        self.selected_button = nil
        self.target_skill_name = target_skill_name
    end)

function StarIliadKeyConfigDialog:OnRawKey(key, down)
    if down then
        local key_str = STRINGS.UI.CONTROLSSCREEN.INPUTS[1][key]
        if key_str then
            self.selected_button = key
            self.dialog.body:SetString(string.format(STRINGS.STARILIAD_UI
                .KEY_CONFIG_DIALOG
                .TEXT_AFTER, key_str))
        end
    end

    if StarIliadKeyConfigDialog._base.OnRawKey(self, key, down) then return true end
end

function StarIliadKeyConfigDialog:OnMouseButton(mousebutton, down, x, y)
    local valid_mousebuttons = {
        -- MOUSEBUTTON_LEFT,
        -- MOUSEBUTTON_RIGHT,
        MOUSEBUTTON_MIDDLE, -- MOUSEBUTTON_MIDDLE
        1005,               -- "Mouse Button 4",
        1006                -- "Mouse Button 5",
    }

    if down and table.contains(valid_mousebuttons, mousebutton) then
        local button_str = STRINGS.UI.CONTROLSSCREEN.INPUTS[1][mousebutton]
        if button_str then
            self.selected_button = mousebutton
            self.dialog.body:SetString(string.format(STRINGS.STARILIAD_UI
                .KEY_CONFIG_DIALOG
                .TEXT_AFTER, button_str))
        end
    end

    if StarIliadKeyConfigDialog._base.OnMouseButton(self, mousebutton, down, x, y) then
        return true
    end
end

return StarIliadKeyConfigDialog
