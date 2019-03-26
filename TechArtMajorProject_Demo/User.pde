class User {
  PImage imgs[];
  int currImgIdx;
  int lastDrawn;
  int numImgs;
  Rectangle boundingRect;
  Rectangle faces[];
  boolean consented;
  String str;
  
  User(Rectangle _boundingRect, int _numImgs, int _drawPeriod) {
    boundingRect = _boundingRect;
    numImgs = _numImgs;
    drawPeriod = _drawPeriod;
    str = "";

    currImgIdx = 0;
    lastDrawn = millis();

    imgs = new PImage[numImgs];
    faces = new Rectangle[numImgs];
    for (int imgId = 0; imgId < numImgs; imgId++) {
      imgs[imgId] = new PImage();
      faces[imgId] = null;
    }
  }
  
  void loadImages(PImage imgBuff[], boolean _consented, String _str) {

    consented = _consented;
    lastDrawn = millis() - drawPeriod;
    str = _str;
    
    // This loop saves every image in the buffer to the appropriate cache.
    for (int imgId = 0; imgId < numImgs; imgId++) {
  
      if (imgBuff[imgId] == null) {
        println("Error: No images in buffer yet");
        return;
      }
  
      // Copy the image from the buffer.
      PImage tmp = imgBuff[imgId].copy();

      // Resize image to correct width and height.
      tmp.resize(boundingRect.width, boundingRect.height);
      
      // If no consent was given, blur and grey the images.
      if (!consented) {
        tmp.filter(BLUR, 5);
        tmp.filter(GRAY);
      }
  
      // Save image to the cache.
      imgs[imgId] = tmp;
  
      if (consented) {
        // Detecting faces:
        opencv.loadImage(imgBuff[imgId]);
        Rectangle[] detectedFaces = opencv.detect();
        
        // If faces are present, save the last face in the list.
        if (detectedFaces.length >= 1) {
          Rectangle face = detectedFaces[detectedFaces.length - 1];
          if (face != null) {
            face.x *= float(boundingRect.width)/imgBuff[imgId].width;
            face.y *= float(boundingRect.height)/imgBuff[imgId].height;
            face.x += boundingRect.x;
            face.y += boundingRect.y;
  
            face.width *= float(boundingRect.width)/imgBuff[imgId].width;
            face.height *= float(boundingRect.height)/imgBuff[imgId].height;
          }
          faces[imgId] = face;
        }
        // Otherwise save null.
        else {
          faces[imgId] = null;
        }
      }
    }
  }
  
  void drawUser() {
    if (millis() - lastDrawn >= drawPeriod) {
      // Draw the image.
      image(imgs[currImgIdx], boundingRect.x, boundingRect.y);
    
      // If a face rectange exists for this image, draw the rectangle.
      if (faces[currImgIdx] != null) {
        noFill();
        strokeWeight(3);
        stroke(255,0,0);
        Rectangle face = faces[currImgIdx];
        rect(face.x, face.y, face.width, face.height);
      }
      
      fill(255);
      textSize(8);
      text(str, boundingRect.x+5, boundingRect.y+boundingRect.height-5);
    
      // Update the data for this cache.
      currImgIdx = (currImgIdx+1) % numImgs;
      lastDrawn = lastDrawn + int(drawPeriod);
    }
  }
};
