Shader "CZW/URP/SimplesUnlitShader 0"
{
    Properties
    {
        _Color("Color(RGB)",Color) = (1,1,1,1)
        _BaseMap("MainTex",2D) = "gary"{}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Scale", Range(0,2)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry+0"
        }
        
        Pass
        {
            Name "Pass"
            Tags 
            { 
                
            }
            
            Blend One Zero, One Zero
            Cull Back
            ZTest LEqual
            ZWrite On
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing
            

			#define _NORMALMAP  
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            CBUFFER_END
            

			TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;

 

			TEXTURE2D(_BumpMap);            SAMPLER(sampler_BumpMap);
			float4 _BumpMap_ST;
			half _BumpScale;
            
            #define smp SamplerState_Point_Repeat
            SAMPLER(smp);
            struct Attributes
            {
                float3 positionOS : POSITION;
				float3 normalOS     : NORMAL;
				float4 tangentOS    : TANGENT;
                float2 uv :TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv :TEXCOORD0;
				float3 normalWS :TEXCOORD1;
			#ifdef _NORMALMAP
				float3 tangentWS:TEXCOORD2;
				float3 bitangentWS:TEXCOORD3;
			#endif

            };
            
            Varyings vert(Attributes i)
            {
				Varyings o = (Varyings)0;
				o.uv =  i.uv ;
				o.positionCS = TransformObjectToHClip(i.positionOS);
				
				//float3 positionWS = TransformObjectToWorld(i.positionOS.xyz);
				//float3 normalWS = TransformObjectToWorldNormal(i.normalOS);
				VertexNormalInputs normalInput = GetVertexNormalInputs(i.normalOS, i.tangentOS);
			#ifdef _NORMALMAP
				o.normalWS = half3(normalInput.normalWS);
				o.tangentWS = half3(normalInput.tangentWS);
				o.bitangentWS = half3(normalInput.bitangentWS);
				
			#else
				o.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
			#endif
                return o;
            }

            half4 frag(Varyings i) : SV_TARGET 
            {    


				#ifdef _NORMALMAP
					half4 _n = SAMPLE_TEXTURE2D(_BumpMap,sampler_BumpMap,TRANSFORM_TEX(i.uv,_BumpMap)  );
					half3 normalTS = UnpackNormalScale(_n, _BumpScale);
					half3 normalWorld = TransformTangentToWorld(normalTS, half3x3(i.tangentWS.xyz, i.bitangentWS.xyz, i.normalWS.xyz));
					normalWorld = NormalizeNormalPerPixel(normalWorld);
				#else
					half3 normalWorld = NormalizeNormalPerPixel(i.normalWS);
				#endif
				 

				half3 lightColor = _MainLightColor.rgb;
				half3 lightDirection = normalize(_MainLightPosition.xyz);
				half ndotl = saturate(dot(lightDirection,normalWorld));
				
                half4 mainTex = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,TRANSFORM_TEX(i.uv,_BaseMap)  );
				
                half4 c = _Color * mainTex *ndotl;
                return c;
            }
            
            ENDHLSL
        }
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}