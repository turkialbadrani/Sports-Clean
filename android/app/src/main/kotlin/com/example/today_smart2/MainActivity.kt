package com.example.today_smart2

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // إنشاء قناة إشعارات (مطلوبة من أندرويد 8.0 وأعلى)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "high_importance_channel", // 👈 نفس اللي حطيناه في AndroidManifest.xml
                "High Importance Notifications",
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = "This channel is used for important notifications."

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
