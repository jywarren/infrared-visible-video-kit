//import processing.opengl.*;
import processing.video.*;

Capture video;
Capture irvideo;

float[] bright;
char[] chars;

PFont font;
float fontSize = 1.5;
PFont fontA;

public void setup() {
  //size(640, 480, P2D);
  size(320, 240, P2D);
  // Or run full screen, more fun! Use with Sketch -> Present
//  size(screen.width, screen.height, OPENGL);

  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, width, height, 30);
  video.settings();
  
  //instantiate capture source for right stereo image
  irvideo = new Capture(this, width, height, 30);        
  //select webcam from quicktime dialog
  irvideo.settings();

}

public void captureEvent(Capture c) {
  c.read();
}

int res = 1;

void draw() {
  loadPixels();
  
  background(0);

  float sum = 0.000;
  float pixcount = 0.000;

  int index = 0;
  for (int y = 0; y < int (video.height); y+=res) {

    for (int x = 0; x < int (video.width); x+=res) {
        int pixelColor = video.pixels[index];
        int irpixelColor = irvideo.pixels[index];

        // Faster method of calculating r, g, b than red(), green(), blue() 
        int r = (pixelColor >> 16) & 0xff;
        int g = (pixelColor >> 8) & 0xff;
        int b = pixelColor & 0xff;

        int irr = (irpixelColor >> 16) & 0xff;
        int irg = (irpixelColor >> 8) & 0xff;
        int irb = irpixelColor & 0xff;

        float vis = (r+b+g/3.000);
        float ir = (irr+irb+irg/3.000);
        float ndvi = 1.000*((ir-vis)/(ir+vis));
        //int pixcolor = parseInt(ndvi);

        // http://download.oracle.com/javase/1.4.2/docs/api/java/awt/Color.html
        final Color colors = java.awt.Color.getHSBColor(ndvi,1.00,1.00);
        pixels[index] = color(colors.getRed(),colors.getGreen(),colors.getBlue());

        // Render the difference image to the screen
        //pixels[index] = color(newr, newg, newb);
        // The following line does the same thing much faster, but is more technical
        //pixels[index] = 0xFF000000 | (pixcolor << 16) | (pixcolor << 8) | pixcolor;
        
        //println(ndvi);
        
        index++;
    }
  }
updatePixels();
//  fill(255,255,255);
//  text(r2,22,22);
//  text((sum/pixcount),22,122);
}

