# Flutter specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLite
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}
