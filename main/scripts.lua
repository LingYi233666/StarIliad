AddGlobalClassPostConstruct("entityscript", "EntityScript", function(self)
    local old_FacePoint = self.FacePoint

    self.FacePoint = function(self, ...)
        if self.sg ~= nil and self.sg:HasStateTag("stariliad_no_face_point") then
            return
        end

        return old_FacePoint(self, ...)
    end
end)

AddGlobalClassPostConstruct("behaviours/useshield", "UseShield", function(self)
    local old_TimeToEmerge = self.TimeToEmerge
    local old_ShouldShield = self.ShouldShield

    self.TimeToEmerge = function(self, ...)
        if self.inst
            and self.inst:IsValid()
            and self.inst.components.debuffable
            and self.inst.components.debuffable:HasDebuff("stariliad_debuff_shield_break") then
            return true
        end
        return old_TimeToEmerge(self, ...)
    end

    self.ShouldShield = function(self, ...)
        if self.inst
            and self.inst:IsValid()
            and self.inst.components.debuffable
            and self.inst.components.debuffable:HasDebuff("stariliad_debuff_shield_break") then
            return false
        end
        return old_ShouldShield(self, ...)
    end
end)

-- StarIliadTip = Class(function(self, inst, data_or_str, duration, on_push, on_pop, events)
--     self.inst = inst
--     if type(data_or_str) == "string" then
--         self.str = data_or_str
--         self.duration = duration
--         self.on_push = on_push
--         self.on_pop = on_pop
--         self.events = events
--     elseif type(data_or_str) == "table" then
--         self.str = data_or_str.str
--         self.duration = data_or_str.duration
--         self.on_push = data_or_str.on_push
--         self.on_pop = data_or_str.on_pop
--         self.events = data_or_str.events
--     else
--         assert(false, "Wrong data_or_str param type:" .. type(data_or_str))
--     end
-- end)

-- GLOBAL.StarIliadTip = StarIliadTip

-- Skins
GLOBAL.blythe_backpack_init_fn = function(inst, build_name)
    basic_init_fn(inst, build_name, "blythe_backpack")

    inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. build_name .. ".xml"
    inst.components.inventoryitem:ChangeImageName(build_name)
end

GLOBAL.blythe_backpack_clear_fn = function(inst)
    basic_clear_fn(inst, "blythe_backpack")

    inst.components.inventoryitem.atlasname = "images/inventoryimages/blythe_backpack.xml"
    inst.components.inventoryitem:ChangeImageName("blythe_backpack")
end

GLOBAL.blythe_blaster_init_fn = function(inst, build_name)
    basic_init_fn(inst, build_name, "blythe_blaster")

    inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. build_name .. ".xml"
    inst.components.inventoryitem:ChangeImageName(build_name)
end

GLOBAL.blythe_blaster_clear_fn = function(inst)
    basic_clear_fn(inst, "blythe_blaster")

    inst.components.inventoryitem.atlasname = "images/inventoryimages/blythe_blaster.xml"
    inst.components.inventoryitem:ChangeImageName("blythe_blaster")
end

RegisterInventoryItemAtlas(resolvefilepath("images/inventoryimages/ms_blythe_blaster_avgn.xml"),
    "ms_blythe_blaster_avgn.tex")

RegisterInventoryItemAtlas(resolvefilepath("images/inventoryimages/ms_blythe_backpack_avgn.xml"),
    "ms_blythe_backpack_avgn.tex")
