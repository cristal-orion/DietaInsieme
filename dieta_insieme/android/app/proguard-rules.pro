# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Flutter's HTTP client and networking classes
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Google Play Core (deferred components) - ignore missing classes
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Dart HTTP / Networking
-keep class dart.** { *; }
-dontwarn dart.**

# Google Generative AI SDK
-keep class com.google.ai.** { *; }
-keep class com.google.generativeai.** { *; }
-dontwarn com.google.ai.**
-dontwarn com.google.generativeai.**

# OkHttp (used by many HTTP clients)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Retrofit (if used)
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# Gson (JSON parsing)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep generic signatures for type tokens (important for JSON parsing)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep exception names for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# SSL/TLS - Critical for HTTPS on Android 16
-keep class javax.net.ssl.** { *; }
-keep class javax.security.** { *; }
-keep class java.security.** { *; }
-keep class javax.crypto.** { *; }
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# Android HTTP
-keep class android.net.** { *; }
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**
-dontwarn android.net.**

# Cronet (Android's HTTP stack)
-keep class org.chromium.net.** { *; }
-dontwarn org.chromium.net.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
