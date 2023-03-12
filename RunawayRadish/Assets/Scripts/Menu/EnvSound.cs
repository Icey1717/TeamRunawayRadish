using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnvSound : MonoBehaviour
{
	public static EnvSound instance;

	private void Awake()
	{
		if (instance == null)
		{
			instance = this;
			DontDestroyOnLoad(this.gameObject);
		}
		
		else
		{
			Destroy(this.gameObject);
		}
	}
}
