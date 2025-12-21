local SMOKE_TEXTURE = "fx/animsmoke2.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME = "cane_victorian_colourenvelope"
local SCALE_ENVELOPE_NAME = "cane_victorian_scaleenvelope"

local assets =
{
	Asset("IMAGE", SMOKE_TEXTURE),
	Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
	return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
	local g = 8
	EnvelopeManager:AddColourEnvelope(
		COLOUR_ENVELOPE_NAME,
		{
			{ 0,  IntColour(g, g, g, 0) },
			{ .2, IntColour(g, g, g, 60) },
			{ .8, IntColour(g, g, g, 30) },
			{ 1,  IntColour(g, g, g, 0) },
		}
	)

	local smoke_max_scale = 1.9
	-- local smoke_max_scale = 2.3
	-- EnvelopeManager:AddVector2Envelope(
	-- 	SCALE_ENVELOPE_NAME,
	-- 	{
	-- 		{ 0,   { smoke_max_scale * .2, smoke_max_scale * .2 } },
	-- 		{ .40, { smoke_max_scale * .7, smoke_max_scale * .7 } },
	-- 		{ .60, { smoke_max_scale * .8, smoke_max_scale * .8 } },
	-- 		{ .75, { smoke_max_scale * .9, smoke_max_scale * .9 } },
	-- 		{ 1,   { smoke_max_scale, smoke_max_scale } },
	-- 	}
	-- )

	EnvelopeManager:AddVector2Envelope(
		SCALE_ENVELOPE_NAME,
		{
			{ 0,    { smoke_max_scale, smoke_max_scale } },
			{ 0.4,  { smoke_max_scale * .9, smoke_max_scale * .9 } },
			{ .60,  { smoke_max_scale * .8, smoke_max_scale * .8 } },
			{ 0.75, { smoke_max_scale * .7, smoke_max_scale * .7 } },
			{ 1,    { smoke_max_scale * .2, smoke_max_scale * .2 } },
		}
	)

	InitEnvelope = nil
	IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 1.75

local function emit_smoke_fn(effect, sphere_emitter)
	-- local vx, vy, vz = 1.5 * UnitRand(), 2.0 + .02 * UnitRand(), 1.5 * UnitRand()
	local vx, vy, vz = 0.01 * UnitRand(), GetRandomMinMax(0.05, 0.1), 0.01 * UnitRand()
	local lifetime = MAX_LIFETIME * (.9 + UnitRand() * .1)
	local px, py, pz = sphere_emitter()
	--offset the flame particles upwards a bit so they can be used on a torch

	local u_offset = math.random(0, 3) * .25
	local v_offset = math.random(0, 3) * .25

	effect:AddRotatingParticleUV(
		0,
		lifetime,      -- lifetime
		px, py, pz,    -- position
		vx, vy, vz,    -- velocity
		math.random() * 360, --* TWOPI, -- angle
		UnitRand(),    -- angle velocity
		u_offset, v_offset -- uv offset
	)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.entity:SetPristine()

	inst.persists = false

	--Dedicated server does not need to spawn local particle fx
	if TheNet:IsDedicated() then
		return inst
	elseif InitEnvelope ~= nil then
		InitEnvelope()
	end

	local effect = inst.entity:AddVFXEffect()
	effect:InitEmitters(1)

	--SMOKE
	effect:SetRenderResources(0, SMOKE_TEXTURE, REVEAL_SHADER)
	effect:SetMaxNumParticles(0, 128)
	effect:SetRotationStatus(0, true)
	effect:SetMaxLifetime(0, MAX_LIFETIME)
	effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
	effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
	effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
	effect:EnableBloomPass(0, true)
	effect:SetUVFrameSize(0, 0.25, 0.25)
	-- effect:SetSortOrder(0, 1)
	effect:SetSortOffset(0, 1)
	-- effect:SetAcceleration(0, 0, -13, 0)
	-- effect:SetDragCoefficient(0, .05)

	-----------------------------------------------------

	local num_to_emit = 1
	local sphere_emitter = CreateSphereEmitter(.05)

	EmitterManager:AddEmitter(inst, nil, function()
		num_to_emit = num_to_emit + 1
		while num_to_emit > 1 do
			emit_smoke_fn(effect, sphere_emitter)
			num_to_emit = num_to_emit - 1
		end
	end)

	return inst
end

return Prefab("stariliad_smoke_trail", fn, assets)
