local BlytheUnlockSkill = Class(function(self, inst)
    self.inst = inst


    self.skill_name = nil
    self.encrypted  = false


    self.already_learn_callback = nil
end)

function BlytheUnlockSkill:SetSkillName(name)
    self.skill_name = name
end

function BlytheUnlockSkill:SetEncrypted(val)
    self.encrypted = val
end

function BlytheUnlockSkill:Teach(player)
    if not self.skill_name or not StarIliadBasic.GetSkillDefine(self.skill_name) then
        return false
    end

    if not (player and player:IsValid() and player.components.blythe_skiller) then
        return false
    end

    if self.encrypted then
        if player:IsNearDanger() then
            print("Danger nearby, skip encrypted anim")
        else
            self:TriggerEncryptedAnim(player)
        end
        return true
    end

    if player.components.blythe_skiller:IsLearned(self.skill_name) then
        if self.already_learn_callback then
            return self.already_learn_callback(self.inst, player)
        end
        return false, "LEARNED"
    end

    player.components.blythe_skiller:Learn(self.skill_name)

    if player:IsNearDanger() then
        print("Danger nearby, skip learned anim")
    else
        self:TriggerLearnedAnim(player)
    end

    if self.inst.components.stackable then
        self.inst.components.stackable:Get():Remove()
    else
        self.inst:Remove()
    end

    return true
end

function BlytheUnlockSkill:TriggerEncryptedAnim(player)
    -- local sound = "stariliad_sfx/hud/item_acquired_dread"
    local sound = "stariliad_sfx/hud/item_acquired_unknown"
    local title = STRINGS.STARILIAD_UI.ITEM_ACQUIRED.ENCRYPTED.TITLE
    local desc = STRINGS.STARILIAD_UI.ITEM_ACQUIRED.ENCRYPTED.DESC

    SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["play_skill_learning_anim"], player.userid, title, desc, sound,
        4.5)
end

function BlytheUnlockSkill:TriggerLearnedAnim(player)
    local sound = "stariliad_sfx/hud/item_acquired_dread"
    local title = STRINGS.STARILIAD_UI.ITEM_ACQUIRED.FOUND:format(STRINGS.STARILIAD_UI.SKILL_DETAIL
        [self.skill_name:upper()].NAME)
    SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["play_skill_learning_anim"], player.userid, title, nil, sound, 6,
        self.skill_name)
end

return BlytheUnlockSkill
