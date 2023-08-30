# Custom-Lighting-System
Here's the Lighting System that I use with my games in Unity URP.

I made this in order to circumvent Unity's wacky lighting system. I didnt like how Unity's lights were super bright near the center and super dim near the end of the radius. Even drastically increasing the range didnt help. This lighting system lets you get a more sylized lighting effect and harder shadows.

By default, Unity's universal render pipeline ignores the range on a light when it comes to distance attenuation. Despite the documentation stating that you can change this, at the time of writing this, that is not possible. This lighting system bypasses that system and lets you change the fall-off to whatever the user desires. This is neccesary for games that are going for a more stylized lighting system with harder lights and shadows.

CustomLighting.hlsl is the shader code
CustomLighting.shadersubgraph is used in the shader graphs that deal with lighting.
TestLighting.shadergraph is the shader for lighting materials.
TestLighting.mat is a sample material. You can add textures, change the falloff, tiling, smoothness, etc. Falloff was the big thing I wanted to change.


![LightingComparison](https://github.com/thadmuchnok64/Custom-Lighting-System/assets/58534647/a542bd58-07a4-49a9-9bfa-596b0b73e218)


:D
