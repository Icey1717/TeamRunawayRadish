using System.Collections.Generic;
using UnityEngine;
using BansheeGz.BGSpline.Curve;

[RequireComponent(typeof(BGCurve))]
[ExecuteInEditMode]
public class SplinePaint : MonoBehaviour
{
    public GameObject[] prefabs;
    public float spacing = 1;

    private List<GameObject> objectsToDelete = new List<GameObject>();

    void OnValidate()
    {
        RefreshObjects();
    }

    public void RefreshObjects()
    {
        RemoveChildren();
        SpawnRandomPrefabs();
    }

    void SpawnRandomPrefab(Vector3 position)
    {
        Instantiate(prefabs[Random.Range(0, prefabs.Length)], position, Quaternion.identity, transform);
    }

    void SpawnRandomPrefabs()
    {
        var mathComponent = GetComponent<BGCurveMathI>();
        var maxDistance = mathComponent.GetDistance();

        for (float distance = 0f; distance <= maxDistance; distance += spacing)
        {
            SpawnRandomPrefab(mathComponent.CalcPositionByDistance(distance));
        }
    }

    void Update()
    {
        foreach (var spawnedObject in objectsToDelete)
            DestroyImmediate(spawnedObject);

        objectsToDelete.Clear();
    }

    void RemoveChildren()
    {
        for (int i = 0; i < transform.childCount; i += 1)
            objectsToDelete.Add(transform.GetChild(i).gameObject);
    }
}
