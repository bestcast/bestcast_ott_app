# Keep Razorpay classes
-keep class com.razorpay.** { *; }

# Keep proguard annotation classes
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }

# Don’t warn about missing proguard.annotation
-dontwarn proguard.annotation.**

# Don’t warn about missing Google Pay classes
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**

# Google Play Core In-App Update
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.install.** { *; }
-keep class de.ffuf.in_app_update.** { *; }

