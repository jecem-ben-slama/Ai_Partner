# Keep OkHttp (required by uCrop)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep uCrop
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**