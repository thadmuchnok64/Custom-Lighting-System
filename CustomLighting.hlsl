#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

// This is a neat trick to work around a bug in the shader graph when
// enabling shadow keywords. Created by @cyanilux
#ifndef SHADERGRAPH_PREVIEW
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
    #if (SHADERPASS != SHADERPASS_FORWARD)
        #undef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
    #endif
#endif

//TODO: Add support for reflections if we want

struct CustomLightingData {
	float3 positionWS;
	float3 normalWS;
	float3 viewDirectionWS;
	float4 shadowCoord;
	//Surface stuff
	float3 albedo;
	float attenuation;
	float smoothness;
	float ambientOcclusion;

	//Baked junk
	float3 bakedGI;
	float4 shadowMask;
};

float GetSmoothnessPower(float rawSmoothness){
	return exp2(10 * rawSmoothness + 1);
	}

float AdjustedAttenuation(CustomLightingData d, Light light){
	return pow(abs(light.distanceAttenuation),d.attenuation);
	}
#ifndef SHADERGRAPH_PREVIEW
float3 CustomGlobalIllumination(CustomLightingData d){
	float3 indirectDiffuse = d.albedo* d.bakedGI * d.ambientOcclusion;
	return indirectDiffuse;
}


float3 CustomLightHandling(CustomLightingData d, Light light) {
	
	float3 radiance = light.color * (AdjustedAttenuation(d,light) * light.shadowAttenuation);

	float diffuse = saturate(dot(d.normalWS, light.direction));
	float specularDot = saturate(dot(d.normalWS, normalize(light.direction+d.viewDirectionWS)));
	float specular = pow(specularDot,GetSmoothnessPower(d.smoothness)) * diffuse;

	float3 color = d.albedo * radiance * (diffuse + specular);
	return color;
}
#endif

float3 CalculateCustomLighting(CustomLightingData d){
	#ifdef SHADERGRAPH_PREVIEW
		float3 lightDirection = float3(0.5,0.5,0);
		float intensity = saturate(dot(d.normalWS,lightDirection)) +
		pow(saturate(dot(d.normalWS,normalize(d.viewDirectionWS+lightDirection))),GetSmoothnessPower(d.smoothness));
		return d.albedo * intensity;
	#else
	//Find main lighting
	Light mainLight = GetMainLight(d.shadowCoord,d.positionWS,d.shadowMask);
	MixRealtimeAndBakedGI(mainLight,d.normalWS,d.bakedGI);
	float3 color = CustomGlobalIllumination(d);
	// Apply shading to main light
	color += CustomLightHandling(d, mainLight);

	#ifdef _ADDITIONAL_LIGHTS
	uint numAdditionalLights = GetAdditionalLightsCount();
	for(uint lightI = 0; lightI < numAdditionalLights; lightI++){
		Light light = GetAdditionalLight(lightI,d.positionWS,d.shadowMask);
		color += CustomLightHandling(d,light);
		}
	#endif
	return color;
	#endif
}

void CalculateCustomLighting_float(float3 Position, 
	float3 Normal, 
	float3 ViewDirection, 
	float3 Albedo, 
	float Smoothness, 
	float Attenuation,
	float AmbientOcclusion,
	float2 LightmapUV,
	out float3 Color){
	CustomLightingData d;
	d.attenuation = Attenuation;
	d.positionWS = Position;
	d.normalWS = Normal;
	d.viewDirectionWS = ViewDirection;
	d.albedo = Albedo;
	d.smoothness = Smoothness;
	d.ambientOcclusion = AmbientOcclusion;

	#ifdef SHADERGRAPH_PREVIEW
	d.shadowCoord = 0;
	d.bakedGI = 0;
	d.shadowMask = 0;
	#else

	float4 positionCS = TransformWorldToHClip(Position);
	#if SHADOWS_SCREEN
	d.shadowCoord = ComputeScreenPos(positionCS);
	#else
	d.shadowCoord = TransformWorldToShadowCoord(Position);
	#endif

	float2 lightmapUV;
	OUTPUT_LIGHTMAP_UV(LightmapUV,unity_LightmapST,lightmapUV);
	float3 vertexSH;
	OUTPUT_SH(Normal,vertexSH);
	d.bakedGI = SAMPLE_GI(lightmapUV,vertexSH,Normal);
	d.shadowMask = SAMPLE_SHADOWMASK(lightmapUV);
	#endif
		Color = CalculateCustomLighting(d);
}

#endif