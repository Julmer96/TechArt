import gab.opencv.*;
import processing.video.*;
import java.awt.*;

// We have one cache per person.
// Each cache contains a number of images that we loop through.
int NUM_IMGS_PER_USERS = 6;
User users[];
int numUsers;
int userCount;

String framesFileName = "data/frames.txt";

// The image buffer contains the last few frames that were taken by the camera ('cam').
// This buffer is copied into the correct image cache when 'y' or 'n' is clicked.
PImage imgBuff[];
int bufferLocation = 0;
Capture cam;
OpenCV opencv;

// Number of milliseconds between capturing frames
int capturePeriod = 250;
int lastCapture;

// Number of milliseconds between drawing frames
int drawPeriod = 475;

int captureWidth = 640;
int captureHeight = 480;

Rectangle[] readRectFromFile(String filename) {
  String[] lines = loadStrings(filename);
  Rectangle[] rects = new Rectangle[lines.length];

  for (int i = 0; i < lines.length; i++) {
    String[] data = lines[i].split(", ");
    rects[i] = new Rectangle(int(data[0]),int(data[1]),int(data[2]),int(data[3]));
  }
  return rects;
}

void setup() {
  fullScreen();
  background(255);

  opencv = new OpenCV(this, captureWidth, captureHeight);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  cam = new Capture(this, captureWidth, captureHeight, 1000/capturePeriod);
  cam.start();
  lastCapture = millis();
  
  // Initialize the Image Buffer
  imgBuff = new PImage[NUM_IMGS_PER_USERS];
  for (int i = 0; i < NUM_IMGS_PER_USERS; i++) {
    imgBuff[i] = null;
  }
  
  // Initialize the cache data
  Rectangle[] boundingRects = readRectFromFile(framesFileName);
  numUsers = boundingRects.length;
  users = new User[numUsers];
  for (int userId = 0; userId < numUsers; userId++) {
    users[userId] = new User(boundingRects[userId], NUM_IMGS_PER_USERS, drawPeriod);
  }

  userCount = 0;
}

void captureEvent(Capture cam) {
  if (cam.available() && millis() > lastCapture + capturePeriod) {
    cam.read();
    imgBuff[bufferLocation] = cam.copy();
    bufferLocation = (bufferLocation+1) % NUM_IMGS_PER_USERS;
    lastCapture = lastCapture + capturePeriod;
  }
}

// On key press, copy the buffer into a cache
// to be displayed on the screen for viewing.
void keyPressed() {
  if (key != 'y' && key != 'n') {
    println("Error: Invalid key press");
    return;
  }
  int userId = userCount % numUsers;
  boolean consented = key == 'y';

  users[userId].loadImages(imgBuff, consented);
  userCount++;
}

void draw() {
  for (int i = 0; i < numUsers; i++) {
    users[i].drawUser();
  }
}
