# Keep Unity classes safe
-include ../unityLibrary/proguard-unity.txt
-keep class com.unity3d.** { *; }
-dontwarn com.unity3d.**
-keep class com.unity3d.player.UnityPlayerActivity { *; }