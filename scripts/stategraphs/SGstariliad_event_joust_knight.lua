local clockwork_common = require("prefabs/clockwork_common")
require("stategraphs/commonstates")



local events =
{
	CommonHandlers.OnHop(),
	CommonHandlers.OnLocomote(false, true),
	CommonHandlers.OnDeath(),

	EventHandler("ontalk", function(inst, data)
		if not inst.sg:HasStateTag("talking") and not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState("talk", data.noanim)
		end
	end),
}

local function AreDifferentPlatforms(inst, target)
	if inst.components.locomotor.allow_platform_hopping then
		return inst:GetCurrentPlatform() ~= target:GetCurrentPlatform()
	end
	return false
end

local LANCE_PADDING = 0.6
local JOUSTING_TAGS = { "jousting" }

local function should_collide(guy, inst)
	return DiffAngle(inst.Transform:GetRotation(), guy.Transform:GetRotation()) > 44
end

local function DoJoustAoe(inst, targets)
	local x, y, z = inst.Transform:GetWorldPosition()

	--lance start and end points (NOTE: 2d vector using x,y,0)
	local p1 = Vector3(0.05, -0.43, 0)             --base of lance
	local p2 = Vector3(2.6 - LANCE_PADDING, -0.06, 0) --tip of lance

	--rotate to match our facing
	local theta = -inst.Transform:GetRotation() * DEGREES
	local cos_theta = math.cos(theta)
	local sin_theta = math.sin(theta)
	local tempx = p1.x
	p1.x = x + tempx * cos_theta - p1.y * sin_theta
	p1.y = z + p1.y * cos_theta + tempx * sin_theta
	tempx = p2.x
	p2.x = x + tempx * cos_theta - p2.y * sin_theta
	p2.y = z + p2.y * cos_theta + tempx * sin_theta

	local cx = (p1.x + p2.x) * 0.5
	local cz = (p1.y + p2.y) * 0.5
	local radius = math.sqrt(distsq(p1.x, p1.y, cx, cz))
	local lsq = Dist2dSq(p1, p2)
	local t = GetTime()

	local function should_hit(guy, inst)
		local last_t = targets[guy]
		if last_t == nil or last_t + 0.75 < t then
			local p3 = guy:GetPosition()
			p3.y, p3.z = p3.z, 0 --convert x,0,z -> x,y,0
			local range = LANCE_PADDING + guy:GetPhysicsRadius(0)
			--if DistPointToSegmentXYSq(p3, p1, p2) < range * range then
			--V2C: modified becasue we don't want to hit anything behind the back point
			local dot = (p3.x - p1.x) * (p2.x - p1.x) + (p3.y - p1.y) * (p2.y - p1.y)
			if dot >= 0 then
				dot = dot / lsq
				local dsq =
					dot >= 1 and
					Dist2dSq(p3, p2) or
					Dist2dSq(p3, Vector3(p1.x + dot * (p2.x - p1.x), p1.y + dot * (p2.y - p1.y), 0))
				if dsq < range * range then
					targets[guy] = t
					return true
				end
			end
		end
		return false
	end

	local collided = false
	inst.components.combat.ignorehitrange = true
	clockwork_common.FindAOETargetsAtXZ(inst, cx, cz, radius + LANCE_PADDING + 3,
		function(guy, inst)
			if should_hit(guy, inst) then
				if guy:HasTag("jousting") and should_collide(guy, inst) then
					guy:PushEventImmediate("joust_collide")
					collided = true
				else
					inst.components.combat:DoAttack(guy)
					guy:PushEvent("knockback", { knocker = inst, radius = 6.5, forcelanded = true })
				end
			end
		end)
	inst.components.combat.ignorehitrange = false

	local knight_rad = inst:GetPhysicsRadius(0)
	for i, v in ipairs(TheSim:FindEntities(cx, 0, cz, radius + LANCE_PADDING + knight_rad, JOUSTING_TAGS)) do
		if v ~= inst and should_hit(v, inst) and should_collide(v, inst) then
			v:PushEventImmediate("joust_collide")
			collided = true
		end
	end

	if collided then
		inst:PushEventImmediate("joust_collide")
	end
end

local function CreateTalkTimeline(max_duration)
	-- FrameEvent(7, function(inst)
	-- 	inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/bounce")
	-- end),
	-- FrameEvent(19, function(inst)
	-- 	inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/land")
	-- end),

	local timeline = {}

	local anim_len = 22 * FRAMES
	local i = 0
	while true do
		if i * anim_len >= max_duration then
			break
		end

		table.insert(timeline,
			TimeEvent(i * anim_len + 7 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/bounce")
			end)
		)
		table.insert(timeline,
			TimeEvent(i * anim_len + 19 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/land")
			end)
		)

		i = i + 1
	end

	return timeline
end

local states =
{
	State {
		name = "idle",
		tags = { "idle", "canrotate" },

		onenter = function(inst, playanim)
			inst.components.locomotor:StopMoving()
			if playanim then
				inst.AnimState:PlayAnimation(playanim)
				inst.AnimState:PushAnimation("idle_loop")
			else
				inst.AnimState:PlayAnimation("idle_loop", true)
			end
		end,

		timeline =
		{
			TimeEvent(21 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" ..
					inst.kind .. "/idle")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	State {
		name = "talk",
		tags = { "idle", "talking" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("walk_pre")
			inst.AnimState:PushAnimation("walk_loop", true)

			-- DoTalkSound(inst)
			-- inst.sg:SetTimeout(2 + math.random() * .5)
			inst.sg:SetTimeout(5.5 + math.random() * .5)
		end,

		timeline = CreateTalkTimeline(10),

		ontimeout = function(inst)
			inst.sg:GoToState("idle", "walk_pst")
		end,

		events =
		{
			EventHandler("donetalking", function(inst)
				inst.sg:GoToState("idle", "walk_pst")
			end),
		},

		onexit = function(inst)

		end,
	},

	State {
		name = "taunt",
		tags = { "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:StopMoving()
			if target and target:IsValid() then
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
			inst.Transform:SetSixFaced() --best model for facing target with an unfaced anim
			inst.AnimState:PlayAnimation("taunt")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/voice")

			inst.sg.statemem.target = target
		end,

		timeline =
		{
			TimeEvent(10 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" ..
					inst.kind .. "/pawground")
			end),
			TimeEvent(28 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" ..
					inst.kind .. "/pawground")
			end),
			FrameEvent(30, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(48, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
						inst.sg:GoToState("joust_pre", inst.sg.statemem.target)
					else
						inst.sg:GoToState("idle")
					end
				end
			end),
		},

		onexit = function(inst)
			inst.Transform:SetFourFaced()
		end,
	},

	State {
		name = "hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("hit")
		end,

		timeline =
		{
			FrameEvent(0, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind ..
					"/hurt")
			end),
			FrameEvent(11, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	State {
		name = "attack",
		tags = { "attack", "busy" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("atk")
			inst.components.combat:StartAttack()
		end,

		timeline =
		{
			FrameEvent(14, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/attack")
				inst.components.combat:DoAttack()
			end),
			FrameEvent(28, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	State {
		name = "joust_pre",
		tags = { "attack", "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:StopMoving()
			inst.Transform:SetEightFaced()
			inst.AnimState:PlayAnimation("joust_pre")
			-- inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/voice")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/attack")


			inst:ForceFacePoint(target:GetPosition())
		end,

		timeline =
		{
			FrameEvent(18, function(inst)
				inst.sg:AddStateTag("jumping")

				-- local theta = ReduceAngle(inst.sg.statemem.dir - inst.Transform:GetRotation()) * DEGREES
				-- local speed = TUNING.YOTH_KNIGHT_JOUST_SPEED * inst.components.locomotor:GetSpeedMultiplier()
				-- inst.Physics:SetMotorVelOverride(speed * math.cos(theta), 0, -speed * math.sin(theta))


				local speed = TUNING.YOTH_KNIGHT_JOUST_SPEED * inst.components.locomotor:GetSpeedMultiplier()
				inst.Physics:SetMotorVelOverride(speed, 0, 0)
			end),
			FrameEvent(21, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" ..
					inst.kind .. "/bounce")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.jousting = true
					inst.sg:GoToState("joust_loop")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.jousting then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State {
		name = "joust_loop",
		tags = { "attack", "busy", "jumping" },

		onenter = function(inst, data)
			ToggleOffCharacterCollisions(inst)
			inst.Transform:SetEightFaced()
			if not inst.AnimState:IsCurrentAnimation("joust_loop") then
				inst.AnimState:PlayAnimation("joust_loop", true)
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
			inst:AddTag("jousting")
		end,

		onupdate = function(inst, dt)
			local speed = TUNING.YOTH_KNIGHT_JOUST_SPEED * inst.components.locomotor:GetSpeedMultiplier()
			inst.Physics:SetMotorVelOverride(speed, 0, 0)
		end,

		timeline =
		{
			FrameEvent(0, function(inst)
				if not (inst.sg.laststate and inst.sg.laststate.name == "joust_pre") then
					inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/bounce")
				end
			end),
			FrameEvent(15, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind ..
					"/land")
			end),
		},

		ontimeout = function(inst)
			inst.sg.statemem.jousting = true
			inst.sg:GoToState("joust_loop")
		end,

		events =
		{
			-- EventHandler("joust_collide", function(inst)
			-- 	inst.sg:GoToState("joust_collide")
			-- end),
		},

		onexit = function(inst)
			if not (inst.sg.statemem.jousting or inst.sg.statemem.stopping) then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.Transform:SetFourFaced()
			end
			if not inst.sg.statemem.jousting then
				ToggleOnCharacterCollisions(inst)
				inst:RemoveTag("jousting")
			end
		end,
	},

	State {
		name = "joust_pst",
		tags = { "busy", "jumping" },

		onenter = function(inst)
			inst.Transform:SetEightFaced()
			inst.AnimState:PlayAnimation("joust_pst1")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/attack")
			local _
			inst.sg.statemem.vx, _, inst.sg.statemem.vz = inst.Physics:GetMotorVel()
			inst.Physics:SetMotorVelOverride(inst.sg.statemem.vx * 0.64, 0, inst.sg.statemem.vz * 0.64)
		end,

		timeline =
		{
			FrameEvent(2, function(inst)
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.vx * 0.32, 0,
					inst.sg.statemem.vz * 0.32)
			end),
			FrameEvent(4, function(inst)
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.vx * 0.16, 0,
					inst.sg.statemem.vz * 0.16)
			end),
			FrameEvent(6, function(inst)
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.vx * 0.08, 0,
					inst.sg.statemem.vz * 0.08)
			end),
			FrameEvent(8, function(inst)
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.vx * 0.04, 0,
					inst.sg.statemem.vz * 0.04)
			end),
			FrameEvent(10, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.sg:RemoveStateTag("jumping")
			end),
			FrameEvent(22, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(28, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if inst.sg:HasStateTag("jumping") then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end
			inst.Transform:SetFourFaced()
		end,
	},

	-- State {
	-- 	name = "joust_collide",
	-- 	tags = { "busy", "jumping", "nosleep" },

	-- 	onenter = function(inst)
	-- 		inst.Transform:SetEightFaced()
	-- 		inst.AnimState:PlayAnimation("joust_pst2")
	-- 		inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/attack")
	-- 		local _
	-- 		inst.sg.statemem.vx, _, inst.sg.statemem.vz = inst.Physics:GetMotorVel()
	-- 		inst.Physics:SetMotorVelOverride(inst.sg.statemem.vx * -0.6, 0, inst.sg.statemem.vz * -0.5)
	-- 	end,

	-- 	timeline =
	-- 	{
	-- 		FrameEvent(16, function(inst)
	-- 			inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/hurt")
	-- 			inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/land")
	-- 		end),
	-- 		FrameEvent(17, function(inst)
	-- 			inst.Physics:SetMotorVelOverride(inst.sg.statemem.vx * -0.24, 0,
	-- 				inst.sg.statemem.vz * -0.2)
	-- 		end),
	-- 		FrameEvent(18, function(inst)
	-- 			inst.Physics:SetMotorVelOverride(inst.sg.statemem.vx * -0.12, 0,
	-- 				inst.sg.statemem.vz * -0.1)
	-- 		end),
	-- 		FrameEvent(19, function(inst)
	-- 			inst.Physics:SetMotorVelOverride(inst.sg.statemem.vx * -0.06, 0,
	-- 				inst.sg.statemem.vz * -0.05)
	-- 		end),
	-- 		FrameEvent(20, function(inst)
	-- 			inst.Physics:ClearMotorVelOverride()
	-- 			inst.Physics:Stop()
	-- 			inst.sg:RemoveStateTag("jumping")
	-- 		end),
	-- 		FrameEvent(22, function(inst)
	-- 			inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind ..
	-- 				"/land")
	-- 		end),
	-- 		FrameEvent(40, function(inst)
	-- 			inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" ..
	-- 				inst.kind .. "/pawground")
	-- 		end),
	-- 		CommonHandlers.OnNoSleepFrameEvent(41, function(inst)
	-- 			inst.sg:RemoveStateTag("nosleep")
	-- 			inst.sg:RemoveStateTag("busy")
	-- 		end),
	-- 	},

	-- 	events =
	-- 	{
	-- 		EventHandler("animover", function(inst)
	-- 			if inst.AnimState:AnimDone() then
	-- 				inst.sg:GoToState("idle")
	-- 			end
	-- 		end),
	-- 	},

	-- 	onexit = function(inst)
	-- 		if inst.sg:HasStateTag("jumping") then
	-- 			inst.Physics:ClearMotorVelOverride()
	-- 			inst.Physics:Stop()
	-- 		end
	-- 		inst.Transform:SetFourFaced()
	-- 	end,
	-- },


	State {
		name = "death2",
		tags = { "busy" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("death")
			RemovePhysicsColliders(inst)

			inst.components.lootdropper:DropLoot()
		end,

		timeline = {
			FrameEvent(0,
				function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/death") end),
		},
	}
}

CommonStates.AddWalkStates(states,
	{
		walktimeline =
		{
			FrameEvent(0, function(inst)
				inst.components.locomotor:StopMoving()
			end),
			FrameEvent(7, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/bounce")
				inst.components.locomotor:WalkForward()
			end),
			FrameEvent(19, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/land")
				inst.components.locomotor:StopMoving()
			end),
		},
	},
	nil, --anims
	true, --softstop
	true --delaystart
)


CommonStates.AddHopStates(states, true,
	{ pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst" },
	{
		hop_pst =
		{
			FrameEvent(3, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/land")
			end)
		},
	},
	nil,
	nil,
	{
		start_embarking_pre_frame = 8 * FRAMES,
	},
	{
		pre_onenter = function(inst)
			inst.components.locomotor:StopMoving()
		end,

		pre_ontimeout = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/knight" .. inst.kind .. "/bounce")
		end,
	})

return StateGraph("knight", states, events, "idle")
