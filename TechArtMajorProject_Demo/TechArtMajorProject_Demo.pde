import de.looksgood.ani.*;
import processing.video.*;

Capture cam;
int FCount;

PImage FaceY;
PImage FaceN;
PImage output;
float y;
float x;
float spc1 = 40;
float spc2 = 20;

void setup() {
  fullScreen();
  //background(#1E5D75);
  background(255);
  cam = new Capture(this, 640, 480);
  cam.start();
  x = spc1;
  y = spc2;

  Ani.init(this);
}

void captureEvent(Capture cam) {
  cam.read();
}

void keyPressed() {

  if (key == 'y') {
    pushMatrix();
    scale(0.5);
    translate(x, y);
    noFill();
    strokeWeight(20);
    stroke(255);
    rect(0, 0, cam.width, cam.height);
    noStroke();
    image(cam, 0, 0);
    popMatrix();
    FCount++;
    println("yes");

    if (x < width) {
      x = x + cam.width + spc2;
    } else if (y < height) {
      y = y + cam.height + spc2;
      x = spc1;
    }
  
    if (y > 3*height/4) {
      y = spc2;
    }
  //} else {
    //  background(#0098c9);
    //  x = spc1;
    //  y = spc2;
    //}
  }

  if (key == 'n') {
    pushMatrix();
    scale(0.5);
    translate(x, y);
    noFill();
    strokeWeight(20);
    stroke(255);
    rect(0, 0, cam.width, cam.height);
    noStroke();
    //cam.filter(THRESHOLD);
    cam.filter(BLUR, 2);
    cam.filter(GRAY);
    image(cam, 0, 0);
    popMatrix();
    FCount++;
    println("no");

    if (x <= width) {
      x = x + cam.width + spc2;
    } else if (y <= height) {
      y = y + cam.height + spc2;
      x = spc1;
    }
    if (y > 3*height/4) {
      y = spc2;
    }
    
    //else {
    //  background(#1E5D75);
    //  x = spc1;
    //  y = spc2;
    //}
  }
}

void draw() {
}
