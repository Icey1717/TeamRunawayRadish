using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrefabField : MonoBehaviour
{

    public GameObject prefab;

    public Vector3Int createAmount;

    public BoxCollider bounds;
    public Vector3 offset;

    // Start is called before the first frame update
    void Start()
    {
        for (int x = 0; x < createAmount.x; x++)
        {
            for (int y = 0; y < createAmount.y; y++)
            {
                for (int z = 0; z < createAmount.z; z++)
                {
                    GameObject GO = Instantiate(prefab, transform);
                    Vector3 tarPos = Vector3.zero;
                    tarPos.x = bounds.bounds.min.x + (((bounds.bounds.max.x - bounds.bounds.min.x) / createAmount.x) * x) + offset.x;
                    tarPos.y = bounds.bounds.min.y + (((bounds.bounds.max.y - bounds.bounds.min.y) / createAmount.y) * y) + offset.y;
                    tarPos.z = bounds.bounds.min.z + (((bounds.bounds.max.z - bounds.bounds.min.z) / createAmount.z) * z) + offset.z;
                    GO.transform.position = tarPos;
                }
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
