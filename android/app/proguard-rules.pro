-keep class com.mintops.taala.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.play.core.**

# HERE SDK — R8 fix (https://issuetracker.google.com/issues/282544776)
-dontwarn com.here.sdk.R$id
-dontwarn com.here.sdk.R$layout
-dontwarn com.here.sdk.R$string
-dontwarn com.here.sdk.R$styleable
