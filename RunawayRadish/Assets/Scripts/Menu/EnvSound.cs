using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnvSound : MonoBehaviour
{
	private void Awake()
	{
		DontDestroyOnLoad(transform.gameObject);
	}
}
