local path = MODROOT .. "shaders/stariliad_shock_wave.ksh"
table.insert(Assets, Asset("SHADER", path))

AddModShadersInit(function()
	-- 变量: [1][2]圆心 [3]外径 [4]内径
	UniformVariables.STARILIAD_SHOCK_WAVE_test = PostProcessor:AddUniformVariable("STARILIAD_SHOCK_WAVE", 4)
	UniformVariables.STARILIAD_SHOCK_WAVE_test2 = PostProcessor:AddUniformVariable("STARILIAD_SHOCK_WAVE", 4)

	PostProcessorEffects.StarIliadShockWave = PostProcessor:AddPostProcessEffect(path)

	PostProcessor:SetEffectUniformVariables(PostProcessorEffects.StarIliadShockWave,
		UniformVariables.STARILIAD_SHOCK_WAVE_test)
end)

AddModShadersSortAndEnable(function()
	PostProcessor:SetPostProcessEffectAfter(PostProcessorEffects.StarIliadShockWave, PostProcessorEffects.Lunacy)

	PostProcessor:EnablePostProcessEffect(PostProcessorEffects.StarIliadShockWave, true)

	PostProcessor:SetUniformVariable(UniformVariables.STARILIAD_SHOCK_WAVE_test, 0, 0, 0, 0)
end)

-- PostProcessor:SetUniformVariable(UniformVariables.STARILIAD_SHOCK_WAVE_test, 0.5, 0.5, 0.2, 1)
-- PostProcessor:SetUniformVariable(UniformVariables.STARILIAD_SHOCK_WAVE_test2, 0, 0, 0, 0)
