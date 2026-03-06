package com.antigravity.zenith;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;
import org.json.JSONArray;
import org.json.JSONObject;

public class ZenithWidgetProvider extends AppWidgetProvider {

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.zenith_widget);

        // Access the same SharedPreferences used by the home_widget package
        SharedPreferences prefs = context.getSharedPreferences("HomeWidgetPrefs", Context.MODE_PRIVATE);
        String tasksJson = prefs.getString("tasks_json", "[]");

        try {
            JSONArray tasks = new JSONArray(tasksJson);
            int count = Math.min(tasks.length(), 3);

            if (count == 0) {
                views.setViewVisibility(R.id.empty_view, android.view.View.VISIBLE);
                views.setViewVisibility(R.id.task1_container, android.view.View.GONE);
                views.setViewVisibility(R.id.task2_container, android.view.View.GONE);
                views.setViewVisibility(R.id.task3_container, android.view.View.GONE);
            } else {
                views.setViewVisibility(R.id.empty_view, android.view.View.GONE);
                
                if (count >= 1) {
                    JSONObject task1 = tasks.getJSONObject(0);
                    views.setViewVisibility(R.id.task1_container, android.view.View.VISIBLE);
                    views.setTextViewText(R.id.task1_title, task1.getString("title"));
                    views.setTextViewText(R.id.task1_time, task1.getString("time"));
                } else {
                    views.setViewVisibility(R.id.task1_container, android.view.View.GONE);
                }

                if (count >= 2) {
                    JSONObject task2 = tasks.getJSONObject(1);
                    views.setViewVisibility(R.id.task2_container, android.view.View.VISIBLE);
                    views.setTextViewText(R.id.task2_title, task2.getString("title"));
                    views.setTextViewText(R.id.task2_time, task2.getString("time"));
                } else {
                    views.setViewVisibility(R.id.task2_container, android.view.View.GONE);
                }

                if (count >= 3) {
                    JSONObject task3 = tasks.getJSONObject(2);
                    views.setViewVisibility(R.id.task3_container, android.view.View.VISIBLE);
                    views.setTextViewText(R.id.task3_title, task3.getString("title"));
                    views.setTextViewText(R.id.task3_time, task3.getString("time"));
                } else {
                    views.setViewVisibility(R.id.task3_container, android.view.View.GONE);
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
