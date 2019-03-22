import gab.opencv.*;
import processing.video.*;
import java.awt.*;

// We have one cache per person.
// Each cache contains a number of images that we loop through.
int NUM_CACHES = 8;
int NUM_IMGS_PER_CACHE = 6;

// Each image cache contains all of the images that we loop through.
// The cacheIdx data contains which image in the cache we are currently displaying.
// The lastDraw data contains when the image was last updated.
PImage imgCaches[][];
int cacheIdxs[];
int lastDraw[];

// The image buffer contains the last few frames that were taken by the camera ('cam').
// This buffer is copied into the correct image cache when 'y' or 'n' is clicked.
PImage imgBuff[];
int bufferLocation = 0;
Capture cam;

// Rectanges containing the bounding boxes for each face in every cache.
Rectangle faces[][];
OpenCV opencv;

int userCount;

// Draw period contains the number of milliseconds between each subsequent frame in the cache.
int drawPeriod = 250;
// Number of times slower that images are displayed than they are taken.
float displaySpeedRatio = 1.9;

// Dimensions of images and borders.
float xSpace = 10;
float ySpace = 10;
int imgWidth = 350;
int imgHeight = 262;
int captureWidth = 400;
int captureHeight = 300;

int numCols = 4;

void setup() {
  fullScreen();
  background(255);
  cam = new Capture(this, captureWidth, captureHeight, 1000/drawPeriod);

  opencv = new OpenCV(this, captureWidth, captureHeight);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  cam.start();
  
  // Initialize the Image Buffer
  imgBuff = new PImage[NUM_IMGS_PER_CACHE];
  for (int i = 0; i < NUM_IMGS_PER_CACHE; i++) {
    imgBuff[i] = null;
  }
  
  // Initialize the cache data
  cacheIdxs = new int[NUM_CACHES];
  lastDraw = new int[NUM_CACHES];
  imgCaches = new PImage[NUM_CACHES][NUM_IMGS_PER_CACHE];
  faces = new Rectangle[NUM_CACHES][NUM_IMGS_PER_CACHE];
  for (int i = 0; i < NUM_CACHES; i++) {
    cacheIdxs[i] = 0;
    lastDraw[i] = millis();
    for (int j = 0; j < NUM_IMGS_PER_CACHE; j++) {
      imgCaches[i][j] = new PImage();
      faces[i][j] = null;
    }
  }

  userCount = 0;
}

void captureEvent(Capture cam) {
  if (cam.available()) {
    cam.read();
    imgBuff[bufferLocation] = cam.copy();
    bufferLocation = (bufferLocation+1) % NUM_IMGS_PER_CACHE;
  }
}

// On key press, copy the buffer into a cache
// to be displayed on the screen for viewing.
void keyPressed() {
  if (key != 'y' && key != 'n') {
    println("Error: Invalid key press");
    return;
  }
  
  int userId = userCount % NUM_CACHES;

  // This loop saves every image in the buffer to the appropriate cache.
  for (int imgId = 0; imgId < NUM_IMGS_PER_CACHE; imgId++) {

    if (imgBuff[imgId] == null) {
      println("Error: No images in buffer yet");
      return;
    }

    // Copy the image from the buffer.
    PImage tmp = imgBuff[imgId].copy();
    // Resize image to correct width and height.
    tmp.resize(imgWidth, imgHeight);
    
    // If no consent was given, blur and grey the images.
    if (key == 'n') {
      tmp.filter(BLUR, 5);
      tmp.filter(GRAY);
    }

    // Save image to the cache.
    imgCaches[userId][imgId] = tmp;


    // Detecting faces:
    opencv.loadImage(imgBuff[imgId]);
    Rectangle[] detected_faces = opencv.detect();
    
    // If faces are present, save the last face in the list.
    if (detected_faces.length >= 1) {
      Rectangle face = detected_faces[detected_faces.length - 1];
      if (face != null) {
        face.x *= float(imgWidth)/captureWidth;
        face.y *= float(imgHeight)/captureHeight;
        face.width *= float(imgWidth)/captureWidth;
        face.height *= float(imgHeight)/captureHeight;
      }
      faces[userId][imgId] = face;
    }
    // Otherwise save null.
    else {
      faces[userId][imgId] = null;
    }
  }

  userCount++;
}

void drawImage(int imgIdx) {
  // Determine where to draw the image.
  int row = imgIdx / numCols;
  int col = imgIdx % numCols;
  float imgXLocation = (col+1) * xSpace + col * imgWidth;
  float imgYLocation = (row+1) * ySpace + row * imgHeight;

  // Draw the image.
  image(imgCaches[imgIdx][cacheIdxs[imgIdx]], imgXLocation, imgYLocation);

  // If a face rectange exists for this image, draw the rectangle.
  if (faces[imgIdx][cacheIdxs[imgIdx]] != null) {
    noFill();
    strokeWeight(5);
    stroke(255,0,0);
    Rectangle face = faces[imgIdx][cacheIdxs[imgIdx]];
    rect(imgXLocation + face.x, imgYLocation + face.y, face.width, face.height);
  }
}

void draw() {
  // Draw all of the caches if sufficient time has passed
  // since they were last drawn.
  for (int i = 0; i < NUM_CACHES; i++) {
    if (millis() - lastDraw[i] >= displaySpeedRatio * drawPeriod) {
      
      // Draw the image.
      drawImage(i);
    
      // Update the data for this cache.
      cacheIdxs[i] = (cacheIdxs[i]+1) % NUM_IMGS_PER_CACHE;
      lastDraw[i] = lastDraw[i] + int(displaySpeedRatio * drawPeriod);
    }
  }
}
