local assets =
{
	Asset("ANIM", "anim/meteor_shadow.zip")
}

local easing = require("easing")

local function OnUpdate(inst, dt)
	if inst.timer > inst.duration then
		inst:Remove()
		return
	end

	local cur_rgba_s = {}
	for i = 1, 5 do
		local start_val = inst.start_rgba_s[i]
		local end_val = inst.end_rgba_s[i]

		local cur_val
		if i <= 4 then
			cur_val = Remap(inst.timer, 0, inst.duration, start_val, end_val)
		else
			cur_val = easing.inExpo(inst.timer, start_val, end_val - start_val, inst.duration)
		end

		table.insert(cur_rgba_s, cur_val)
	end

	inst.AnimState:SetMultColour(cur_rgba_s[1], cur_rgba_s[2], cur_rgba_s[3], cur_rgba_s[4])

	local s = cur_rgba_s[5]
	inst.Transform:SetScale(s, s, s)

	inst.timer = inst.timer + dt
end

local function StartFX(inst, duration, start_rgba_s, end_rgba_s)
	inst.timer = 0
	inst.duration = duration or 2
	inst.start_rgba_s = start_rgba_s or { 0, 0, 0, 0, 1 }
	inst.end_rgba_s = end_rgba_s or { 1, 1, 1, 1, 0.5 }

	inst.AnimState:SetMultColour(inst.start_rgba_s[1], inst.start_rgba_s[2], inst.start_rgba_s[3], inst.start_rgba_s[4])

	local s = inst.start_rgba_s[5]
	inst.Transform:SetScale(s, s, s)

	inst.components.updatelooper:AddOnUpdateFn(OnUpdate)
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("meteor_shadow")
	inst.AnimState:SetBuild("meteor_shadow")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst:AddTag("FX")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	inst.Transform:SetRotation(math.random(-180, 180))

	inst.StartFX = StartFX

	inst:AddComponent("updatelooper")

	return inst
end

return Prefab("stariliad_meteor_shadow", fn, assets)
