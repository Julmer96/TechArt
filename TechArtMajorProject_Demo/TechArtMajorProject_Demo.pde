import gab.opencv.*;
import processing.video.*;
import java.awt.*;

// We have one cache per person.
// Each cache contains a number of images that we loop through.
int NUM_USERS = 8;
int NUM_IMGS_PER_USERS = 6;
User users[];
int userCount;

int numCols = 4;

// The image buffer contains the last few frames that were taken by the camera ('cam').
// This buffer is copied into the correct image cache when 'y' or 'n' is clicked.
PImage imgBuff[];
int bufferLocation = 0;
Capture cam;
OpenCV opencv;

// Draw period contains the number of milliseconds between each subsequent frame in the cache.
int capturePeriod = 250;
int lastCapture;

// Number of times slower that images are displayed than they are taken.
float displaySpeedRatio = 1.9;

int captureWidth = 640;
int captureHeight = 480;

void setup() {
  fullScreen();
  background(255);

  opencv = new OpenCV(this, captureWidth, captureHeight);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  cam = new Capture(this, captureWidth, captureHeight);
  cam.start();
  lastCapture = millis();
  
  // Initialize the Image Buffer
  imgBuff = new PImage[NUM_IMGS_PER_USERS];
  for (int i = 0; i < NUM_IMGS_PER_USERS; i++) {
    imgBuff[i] = null;
  }
  
  // Set image width and image height to fit numCols images across the screen.
  int imgWidth = width / numCols;
  int imgHeight = height / numCols;
  
  // Initialize the cache data
  users = new User[NUM_USERS];
  for (int userId = 0; userId < NUM_USERS; userId++) {
    // Determine where to draw the image.
    int x = (userId % numCols) * imgWidth;
    int y = (userId / numCols) * imgHeight;
    Rectangle boundingRect = new Rectangle(x, y, imgWidth, imgHeight);

    users[userId] = new User(boundingRect, NUM_IMGS_PER_USERS);
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
  int userId = userCount % NUM_USERS;
  boolean consented = key == 'y';

  users[userId].loadImages(imgBuff, consented);
  userCount++;
}

void draw() {
  for (int i = 0; i < NUM_USERS; i++) {
    users[i].drawUser(displaySpeedRatio * capturePeriod);
  }
}
