# Prevent R8 from stripping Agora video/audio core libraries
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# Specifically suppress missing desugar runtime helper warnings causing your crash
-dontwarn com.google.devtools.build.android.desugar.runtime.**

# Keep essential Flutter and Native engine classes intact
-keep class io.flutter.plugin.** { *; }

# Required by media_store_plus, which uses Gson internally.
-keep class com.snnafi.media_store_plus.** { *; }
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
