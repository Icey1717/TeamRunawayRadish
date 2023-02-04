using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(MovingPlatform)), CanEditMultipleObjects]
public class MovingPlatformEditor : Editor
{
    protected virtual void OnSceneGUI()
    {
        MovingPlatform platform = (MovingPlatform)target;

        EditorGUI.BeginChangeCheck();
        Vector3 newTargetPosition = Handles.PositionHandle(platform.transform.position + platform.moveToPositionLocal, Quaternion.identity);
        Handles.DrawWireCube(platform.transform.position + platform.moveToPositionLocal, Vector3.one * 0.25f);
        Handles.DrawDottedLine(platform.transform.position, platform.transform.position + platform.moveToPositionLocal, 1.0f);
        if (EditorGUI.EndChangeCheck())
        {
            Undo.RecordObject(platform, "Change Look At Target Position");
            platform.moveToPositionLocal = newTargetPosition - platform.transform.position;
        }
    }
}
