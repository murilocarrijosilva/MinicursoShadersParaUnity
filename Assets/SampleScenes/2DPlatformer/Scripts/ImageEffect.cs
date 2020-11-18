using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ImageEffect : MonoBehaviour {

    public Material material;
    public RenderTexture renderTexture;

    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Shader.SetGlobalTexture("_ImageEffectLayer", renderTexture);
        Graphics.Blit(source, destination, material);
    }
}
