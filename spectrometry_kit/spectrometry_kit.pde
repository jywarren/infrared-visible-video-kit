//import processing.opengl.*;
import processing.video.*;

Capture video;

int res = 1;
int samplesize = 10;
int samplerow = int (height*(3/4.00));

public void setup() {
  size(1280, 720, P2D);
  //size(640, 480, P2D);
  //size(320, 240, P2D);
  // Or run full screen, more fun! Use with Sketch -> Present
  //size(screen.width, screen.height, OPENGL);

  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, width, height, 30);
  video.settings();
}

public void captureEvent(Capture c) {
  c.read();
}

void draw() {
  loadPixels();
  background(0);

  int index = int (video.width*samplerow); //the middle horizontal strip

  for (int x = 0; x < int (width); x+=res) {
    
    //int r = 0, g = 0, b = 0;
    
//    for (int xoff = int (samplesize/-2); xoff < int (samplesize/2); xoff+=1) {      
//      int pixelColor = pixels[index+ int (width*xoff)];
//       // Faster method of calculating r, g, b than red(), green(), blue() 
//       println((pixelColor >> 16) & 0xff);
//       r = r+((pixelColor >> 16) & 0xff);
//       g = g+((pixelColor >> 8) & 0xff);
//       b = b+(pixelColor & 0xff);
//    }    
//    
//    r = r/samplesize;
//    g = g/samplesize;
//    b = b/samplesize;
//    

      int pixelColor = video.pixels[index];
       int r = (pixelColor >> 16) & 0xff;
       int g = (pixelColor >> 8) & 0xff;
       int b = pixelColor & 0xff;

    for (int y = 0; y < int (video.height); y+=res) {
      pixels[(y*video.width)+x] = color(r,g,b);
    }
        
    index++;
  }
updatePixels();
}

