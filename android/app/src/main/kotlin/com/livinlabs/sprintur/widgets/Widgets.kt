package com.livinlabs.sprintur.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.net.Uri
import android.widget.RemoteViews
import com.livinlabs.sprintur.MainActivity
import com.livinlabs.sprintur.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

// The app writes already formatted text (lib/app/home_widgets.dart), so these
// providers only fill in views. Tapping a widget opens the app; the Next up
// widget's Start button starts that workout.

private fun SharedPreferences.text(key: String, fallback: String) =
    getString(key, null) ?: fallback

private fun open(context: Context, uri: String) =
    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(uri))

class NextUpWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_next_up).apply {
                setTextViewText(R.id.next_title, widgetData.text("next_title", "6 × 30 m"))
                setTextViewText(R.id.next_name, widgetData.text("next_name", "Acceleration"))
                setOnClickPendingIntent(R.id.root, open(context, "sprintur://home"))
                setOnClickPendingIntent(R.id.start, open(context, "sprintur://start"))
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

class BestWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_best).apply {
                setTextViewText(R.id.best_label, widgetData.text("best_label", "30 m PB"))
                setTextViewText(R.id.best_time, widgetData.text("best_time", "–"))
                setTextViewText(R.id.best_note, widgetData.text("best_note", "Time a rep to set one"))
                setOnClickPendingIntent(R.id.root, open(context, "sprintur://history"))
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

class WeekWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val days = widgetData.text("week_days", "0,0,0,0,0,0,0")
            .split(",").map { it.toIntOrNull() ?: 0 }
        val today = widgetData.getInt("week_today", -1)
        val bars = weekBars(context, days, today)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_week).apply {
                setTextViewText(R.id.week_metres, widgetData.text("week_metres", "0 m"))
                setTextViewText(R.id.week_note, widgetData.text("week_note", "0 sessions"))
                setImageViewBitmap(R.id.week_bars, bars)
                setOnClickPendingIntent(R.id.root, open(context, "sprintur://history"))
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

/** Seven rounded bars, lime where there was running, today outlined. */
private fun weekBars(context: Context, days: List<Int>, today: Int): Bitmap {
    val density = context.resources.displayMetrics.density
    val w = (132 * density).toInt()
    val h = (40 * density).toInt()
    val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    val lime = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = 0xFFD4FF3A.toInt() }
    val empty = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = 0xFF2A2E35.toInt() }
    val ring = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xFF9AA1AC.toInt()
        style = Paint.Style.STROKE
        strokeWidth = 1.5f * density
    }
    val max = (days.maxOrNull() ?: 0).coerceAtLeast(1)
    val gap = 6 * density
    val bar = (w - gap * 6) / 7f
    val r = 3 * density
    val minH = 4 * density
    for (i in 0 until 7) {
        val metres = days.getOrElse(i) { 0 }
        val bh = if (metres > 0) minH + (h - minH) * metres / max else minH
        val left = i * (bar + gap)
        val rect = RectF(left, h - bh, left + bar, h.toFloat())
        canvas.drawRoundRect(rect, r, r, if (metres > 0) lime else empty)
        if (i == today && metres == 0) {
            canvas.drawRoundRect(RectF(rect.left + 1, rect.top - 1, rect.right - 1, rect.bottom - 1), r, r, ring)
        }
    }
    return bitmap
}
