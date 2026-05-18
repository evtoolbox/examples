-- NOTE: EV Toolbox 3.7.0 required

local logger = set_lua_logger("example.network_model_async")

local sceneReactor		= reactorController:getReactorByName("Scene")
local modelNetReactor = reactorController:getReactorByName("ModelNetwork")
local btnNextReactor	= reactorController:getReactorByName("btn_next")
local statusReactor		= reactorController:getReactorByName("status")

local models_glb = {
	-- "ABeautifulGame/glTF-Binary-KTX-ETC1S-Draco/ABeautifulGame.glb"
	"ABeautifulGame/glTF-Binary/ABeautifulGame.glb"
,	"AlphaBlendModeTest/glTF-Binary/AlphaBlendModeTst.glb"
,	"AnimatedColorsCube/glTF-Binary/AnimatedColorsCube.glb"
,	"AnimatedMorphCube/glTF-Binary/AnimatedMorphCube.glb"
,	"AnimationPointerUVs/glTF-Binary/AnimationPointerUVs.glb"
,	"AnisotropyBarnLamp/glTF-Binary/AnisotropyBarnLamp.glb"
,	"AnisotropyDiscTest/glTF-Binary/AnisotropyDiscTest.glb"
,	"AnisotropyRotationTest/glTF-Binary/AnisotropyRotationTest.glb"
,	"AnisotropyStrengthTest/glTF-Binary/AnisotropyStrengthTest.glb"
,	"AntiqueCamera/glTF-Binary/AntiqueCamera.glb"
,	"AttenuationTest/glTF-Binary/AttenuationTest.glb"
,	"Avocado/glTF-Binary/Avocado.glb"
,	"BarramundiFish/glTF-Binary/BarramundiFish.glb"
,	"BoomBox/glTF-Binary/BoomBox.glb"
,	"Box/glTF-Binary/Box.glb"
,	"BoxAnimated/glTF-Binary/BoxAnimated.glb"
,	"BoxInterleaved/glTF-Binary/BoxInterleaved.glb"
,	"BoxTextured/glTF-Binary/BoxTextured.glb"
,	"BoxTexturedNonPowerOfTwo/glTF-Binary/BoxTexturedNonPowerOfTwo.glb"
,	"BoxVertexColors/glTF-Binary/BoxVertexColors.glb"
,	"BrainStem/glTF-Binary/BrainStem.glb"
,	"CarConcept/GLB/CarConcept.glb"
,	"CarConcept/glTF-Binary/CarConcept.glb"
,	"CarbonFibre/glTF-Binary/CarbonFibre.glb"
,	"CesiumMan/glTF-Binary/CesiumMan.glb"
,	"CesiumMilkTruck/glTF-Binary/CesiumMilkTruck.glb"
,	"ChairDamaskPurplegold/glTF-Binary/ChairDamaskPurplegold.glb"
,	"ChronographWatch/glTF-Binary/ChronographWatch.glb"
,	"ClearCoatCarPaint/glTF-Binary/ClearCoatCarPaint.glb"
,	"ClearCoatTest/glTF-Binary/ClearCoatTest.glb"
,	"ClearcoatWicker/glTF-Binary/ClearcoatWicker.glb"
,	"CommercialRefrigerator/glTF-Binary/CommercialRefrigerator.glb"
,	"CompareAlphaCoverage/glTF-Binary/CompareAlphaCoverage.glb"
,	"CompareAmbientOcclusion/glTF-Binary/CompareAmbientOcclusion.glb"
,	"CompareAnisotropy/glTF-Binary/CompareAnisotropy.glb"
,	"CompareBaseColor/glTF-Binary/CompareBaseColor.glb"
,	"CompareClearcoat/glTF-Binary/CompareClearcoat.glb"
,	"CompareDispersion/glTF-Binary/CompareDispersion.glb"
,	"CompareEmissiveStrength/glTF-Binary/CompareEmissiveStrength.glb"
,	"CompareIor/glTF-Binary/CompareIor.glb"
,	"CompareIridescence/glTF-Binary/CompareIridescence.glb"
,	"CompareMetallic/glTF-Binary/CompareMetallic.glb"
,	"CompareNormal/glTF-Binary/CompareNormal.glb"
,	"CompareRoughness/glTF-Binary/CompareRoughness.glb"
,	"CompareSheen/glTF-Binary/CompareSheen.glb"
,	"CompareSpecular/glTF-Binary/CompareSpecular.glb"
,	"CompareTransmission/glTF-Binary/CompareTransmission.glb"
,	"CompareVolume/glTF-Binary/CompareVolume.glb"
,	"Corset/glTF-Binary/Corset.glb"
,	"CubeVisibility/glTF-Binary/CubeVisibility.glb"
,	"DamagedHelmet/glTF-Binary/DamagedHelmet.glb"
,	"DiffuseTransmissionPlant/glTF-Binary/DiffuseTransmissionPlant.glb"
,	"DiffuseTransmissionTeacup/glTF-Binary/DiffuseTransmissionTeacup.glb"
,	"DiffuseTransmissionTest/glTF-Binary/DiffuseTransmissionTest.glb"
,	"DirectionalLight/glTF-Binary/DirectionalLight.glb"
,	"DispersionTest/glTF-Binary/DispersionTest.glb"
,	"DragonAttenuation/glTF-Binary/DragonAttenuation.glb"
,	"DragonDispersion/glTF-Binary/DragonDispersion.glb"
,	"Duck/glTF-Binary/Duck.glb"
,	"EmissiveStrengthTest/glTF-Binary/EmissiveStrengthTest.glb"
,	"Fox/glTF-Binary/Fox.glb"
,	"GlamVelvetSofa/glTF-Binary/GlamVelvetSofa.glb"
,	"GlassBrokenWindow/glTF-Binary/GlassBrokenWindow.glb"
,	"GlassHurricaneCandleHolder/glTF-Binary/GlassHurricaneCandleHolder.glb"
,	"GlassVaseFlowers/glTF-Binary/GlassVaseFlowers.glb"
,	"IORTestGrid/glTF-Binary/IORTestGrid.glb"
,	"InterpolationTest/glTF-Binary/InterpolationTest.glb"
,	"IridescenceAbalone/glTF-Binary/IridescenceAbalone.glb"
,	"IridescenceLamp/glTF-Binary/IridescenceLamp.glb"
,	"IridescenceSuzanne/glTF-Binary/IridescenceSuzanne.glb"
,	"IridescentDishWithOlives/glTF-Binary/IridescentDishWithOlives.glb"
,	"Lantern/glTF-Binary/Lantern.glb"
,	"LightVisibility/glTF-Binary/LightVisibility.glb"
,	"LightsPunctualLamp/glTF-Binary/LightsPunctualLamp.glb"
,	"MaterialsVariantsShoe/glTF-Binary/MaterialsVariantsShoe.glb"
,	"MetalRoughSpheres/glTF-Binary/MetalRoughSpheres.glb"
,	"MetalRoughSpheresNoTextures/glTF-Binary/MetalRoughSpheresNoTextures.glb"
,	"MorphPrimitivesTest/glTF-Binary/MorphPrimitivesTest.glb"
,	"MorphStressTest/glTF-Binary/MorphStressTest.glb"
,	"MosquitoInAmber/glTF-Binary/MosquitoInAmber.glb"
,	"MultiUVTest/glTF-Binary/MultiUVTest.glb"
,	"NegativeScaleTest/glTF-Binary/NegativeScaleTest.glb"
,	"NodePerformanceTest/glTF-Binary/NodePerformanceTest.glb"
,	"NormalTangentMirrorTest/glTF-Binary/NormalTangentMirrorTest.glb"
,	"NormalTangentTest/glTF-Binary/NormalTangentTest.glb"
,	"OrientationTest/glTF-Binary/OrientationTest.glb"
,	"PlaysetLightTest/glTF-Binary/PlaysetLightTest.glb"
,	"PointLightIntensityTest/glTF-Binary/PointLightIntensityTest.glb"
,	"PotOfCoals/glTF-Binary/PotOfCoals.glb"
,	"PotOfCoalsAnimationPointer/glTF-Binary/PotOfCoalsAnimationPointer.glb"
,	"RecursiveSkeletons/glTF-Binary/RecursiveSkeletons.glb"
,	"RiggedFigure/glTF-Binary/RiggedFigure.glb"
,	"RiggedSimple/glTF-Binary/RiggedSimple.glb"
,	"ScatteringSkull/glTF-Binary/ScatteringSkull.glb"
,	"SheenChair/glTF-Binary/SheenChair.glb"
,	"SheenTestGrid/glTF-Binary/SheenTestGrid.glb"
,	"SheenWoodLeatherSofa/glTF-Binary/SheenWoodLeatherSofa.glb"
,	"SimpleInstancing/glTF-Binary/SimpleInstancing.glb"
,	"SpecGlossVsMetalRough/glTF-Binary/SpecGlossVsMetalRough.glb"
,	"SpecularSilkPouf/glTF-Binary/SpecularSilkPouf.glb"
,	"SpecularTest/glTF-Binary/SpecularTest.glb"
,	"SunglassesKhronos/glTF-Binary/SunglassesKhronos.glb"
,	"TextureCoordinateTest/glTF-Binary/TextureCoordinateTest.glb"
,	"TextureEncodingTest/glTF-Binary/TextureEncodingTest.glb"
,	"TextureLinearInterpolationTest/glTF-Binary/TextureLinearInterpolationTest.glb"
,	"TextureSettingsTest/glTF-Binary/TextureSettingsTest.glb"
,	"TextureTransformMultiTest/glTF-Binary/TextureTransformMultiTest.glb"
,	"ToyCar/glTF-Binary/ToyCar.glb"
,	"TransmissionOrderTest/glTF-Binary/TransmissionOrderTest.glb"
,	"TransmissionRoughnessTest/glTF-Binary/TransmissionRoughnessTest.glb"
,	"TransmissionTest/glTF-Binary/TransmissionTest.glb"
,	"TransmissionThinwallTestGrid/glTF-Binary/TransmissionThinwallTestGrid.glb"
,	"Unicode❤♻Test/glTF-Binary/Unicode❤♻Test.glb"
,	"UnlitTest/glTF-Binary/UnlitTest.glb"
,	"VertexColorTest/glTF-Binary/VertexColorTest.glb"
,	"VirtualCity/glTF-Binary/VirtualCity.glb"
,	"WaterBottle/glTF-Binary/WaterBottle.glb"
,	"XmpMetadataRoundedCube/glTF-Binary/XmpMetadataRoundedCube.glb"
}


local index = 1

btnNextReactor:subscribeEvent("onDown", function()
	local url = "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/" .. models_glb[index]
	local modelNetResource = Resource(nil, ResourceKind.MODEL, url)
	resourceRepository:addResource(modelNetResource)

	modelNetReactor.asyncLoad = true
	modelNetReactor.model = modelNetResource

	statusReactor.rect.color = osg.Vec4(0.9, 0.2, 0.0, 1.0)
	statusReactor.text.value = "Загружатся:\n" .. url

	index = index + 1
	if index > #models_glb then
		index = 1
	end
end)


modelNetReactor:subscribeEvent("onModelChanged", function()
	statusReactor.rect.color = osg.Vec4(1.0, 1.0, 1.0, 1.0)
	statusReactor.text.value = modelNetReactor.model and modelNetReactor.model.filename or ""
end)
