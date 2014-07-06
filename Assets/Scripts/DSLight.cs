﻿using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[RequireComponent(typeof(Light))]
public class DSLight : MonoBehaviour
{
	static HashSet<DSLight> _instances;
	public static HashSet<DSLight> instances
	{
		get
		{
			if (_instances == null) { _instances = new HashSet<DSLight>(); }
			return _instances;
		}
	}

	void OnEnable()
	{
		instances.Add(this);
	}

	void OnDisable()
	{
		instances.Remove(this);
	}

	static public Mesh sphereMesh;
	static public Material matPointLight;
	static public Material matDirectionalLight;

	static public void RenderLights()
	{
		foreach(DSLight l in instances) {
			if (l.lit.type == LightType.Point)
			{
				Matrix4x4 trans = Matrix4x4.TRS(l.transform.position, Quaternion.identity, Vector3.one);
				Vector4 color = l.lit.color;
				Vector4 range = Vector4.zero;
				Vector4 shadow = Vector4.zero;
				range.x = l.lit.range;
				range.y = 1.0f / range.x;
				shadow.x = l.castShadow ? 1.0f : 0.0f;
				shadow.y = (float)l.shadowSteps;
				matPointLight.SetVector("_LightColor", color);
				matPointLight.SetVector("_LightPosition", l.transform.position);
				matPointLight.SetVector("_LightRange", range);
				matPointLight.SetVector("_ShadowParams", shadow);
				matPointLight.SetPass(0);
				Graphics.DrawMeshNow(sphereMesh, trans);
			}
			else if (l.lit.type == LightType.Directional)
			{
				Vector4 color = l.lit.color;
				Vector4 shadow = Vector4.zero;
				shadow.x = l.castShadow ? 1.0f : 0.0f;
				shadow.y = (float)l.shadowSteps;
				matDirectionalLight.SetVector("_LightColor", color);
				matDirectionalLight.SetVector("_ShadowParams", shadow);
				matDirectionalLight.SetPass(0);
				GL.Begin(GL.QUADS);
				GL.TexCoord2(0, 0); GL.Vertex3(0.0f, 0.0f, 0.1f);
				GL.TexCoord2(1, 0); GL.Vertex3(1.0f, 0.0f, 0.1f);
				GL.TexCoord2(1, 1); GL.Vertex3(1.0f, 1.0f, 0.1f);
				GL.TexCoord2(0, 1); GL.Vertex3(0.0f, 1.0f, 0.1f);
				GL.End();
			}
		}
	}

	public bool castShadow = true;
	public int shadowSteps = 10;
	public Light lit;

	void Start ()
	{
		lit = GetComponent<Light>();
	}
	
	void Update ()
	{
	
	}
}
