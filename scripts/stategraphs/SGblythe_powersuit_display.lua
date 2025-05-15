local BlytheSkillActiveFX = require "widgets/blythe_skill_active_fx"

local events =
{
    EventHandler("play_skill_learning_anim", function(inst, data)
        print("event !!")
        inst.sg:GoToState("skill_learning", data)
    end),
}

local function MakeGrayItem(item)
    item.text_button:SetColour(0.3, 0.3, 0.3, 1)
    item.text_button:SetClickable(false)
    item.block:SetTint(255 / 255, 70 / 255, 52 / 255, 1)
end

local function MakeActivateItem(item, spawn_fx, shinning)
    if spawn_fx then
        local active_fx = item.block:AddChild(BlytheSkillActiveFX())
        active_fx:SetPosition(0, 15)
    end

    item:RefreshText()

    if shinning then
        item.block:StartShinning()
    end
end

local function FindItem(self, skill_name)
    local skill_def = StarIliadBasic.GetSkillDefine(skill_name)
    if not skill_def or not skill_def.dtype then
        print("Def not found !")
        return
    end

    local target_list = self.lists[skill_def.dtype]

    if not target_list then
        print("List not found !")
        return
    end

    local target_item = target_list:GetItemBySkillName(skill_name)
    if not target_item then
        print("Item not found !")
        return
    end

    return target_item
end

local states =
{
    State {
        name = "idle",
        onenter = function(inst)

        end,
    },

    State {
        name = "skill_learning",
        onenter = function(inst, data)
            print("skill_learning !!")

            inst.sg.statemem.skill_names = data.skill_names
            inst.sg.statemem.period = data.period or (15 * FRAMES)
            inst.sg.statemem.index = 1
            inst.sg.statemem.elapse = 0

            inst.sg.statemem.items = {}
            for _, skill_name in pairs(data.skill_names) do
                local item = FindItem(inst.widget, skill_name)
                if item then
                    MakeGrayItem(item)
                    table.insert(inst.sg.statemem.items, item)
                end
            end

            inst.sg:SetTimeout(inst.sg.statemem.period * (#inst.sg.statemem.items + 2))
        end,

        onupdate = function(inst, dt)
            if inst.sg.statemem.index > # inst.sg.statemem.items then
                return
            end

            inst.sg.statemem.elapse = inst.sg.statemem.elapse + dt
            while inst.sg.statemem.elapse > inst.sg.statemem.period do
                inst.sg.statemem.elapse = inst.sg.statemem.elapse - inst.sg.statemem.period

                MakeActivateItem(inst.sg.statemem.items[inst.sg.statemem.index], true, true)

                inst.sg.statemem.index = inst.sg.statemem.index + 1
            end
        end,

        ontimeout = function(inst)
            if #inst.sg.statemem.items == 1 then

            end
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            -- for _, item in pairs(inst.sg.statemem.items) do
            --     MakeActivateItem(item)
            -- end
        end,
    },


}

return StateGraph("SGblythe_powersuit_display", states, events, "idle")
