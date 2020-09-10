package com.example.flutterhello;


import android.os.Build;

import androidx.annotation.RequiresApi;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.Date;

public class Player {

    private int id;
    private String name;
    private String position;
    private int height;
    private long timestamp;

    public Player() {
    }

    public Player(int id, String name, String position, int height) {
        this.id = id;
        this.name = name;
        this.position = position;
        this.height = height;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setTimestamp(String timestamp)  {
        timestamp = timestamp.replace('T',' ');

        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        try {
            Date date = format.parse(timestamp);
        this.timestamp = date.getTime();
        } catch (ParseException e) {
            e.printStackTrace();
        }
    }

    public String getPosition() {
        return position;
    }

    public long getTimestamp() {
        return this.timestamp;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public int getHeight() {
        return height;
    }

    public void setHeight(int height) {
        this.height = height;
    }

    @Override
    public String toString() {
        return name + " - " + position + " - " + height + " cm";
    }


}
