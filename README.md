# Custom-Lighting-System
Here's the Lighting System that I use in my games in Unity URP.

I made this in order to circumvent Unity's wacky lighting system. I didnt like how Unity's lights were super bright near the center and super dim near the end of the radius. Even drastically increasing the range didnt help. This lighting system lets you get a more sylized lighting effect and harder shadows.

CustomLighting.hlsl is the shader code
CustomLighting.shadersubgraph is used in the shader graphs that deal with lighting.
TestLighting.shadergraph is the shader for lighting materials.
TestLighting.mat is a sample material. You can add textures, change the falloff, tiling, smoothness, etc. Falloff was the big thing I wanted to change.

:D
