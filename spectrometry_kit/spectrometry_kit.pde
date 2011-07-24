import processing.video.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

Capture video;

Minim minim;
AudioInput in;
AudioOutput out;
FFT fft;
SpectrumCollector spectrum;

float[] buffer;
int bsize = 1024;

int res = 1;
int samplesize = 50;
int samplerow;

class SpectrumCollector implements AudioSignal
{
  void generate(float[] samp)
  {
    loadPixels();
    background(0);
 
    int index = int (video.width*samplerow); //the middle horizontal strip

    for (int x = 0; x < int (width); x+=res) {

      int pixelColor = video.pixels[index];
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;

      int ind = int (map(x,0,int (width),255,samp.length));
      samp[ind] = int (map((r+b+g)/3,0,0.3*255,0,1));

      index++;
    }
  }
 
  // this is a stricly mono signal
  void generate(float[] left, float[] right)
  {
    generate(left);
    generate(right);
  }
}

public void setup() {
  //size(1280, 720, P2D);
  size(640, 480, P2D);
  //size(320, 240, P2D);
  // Or run full screen, more fun! Use with Sketch -> Present
  //size(screen.width, screen.height, OPENGL);

  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, width, height, 20);
  samplerow = int (height*(3.00/4.00));
  video.settings();
  
  minim = new Minim(this);
  minim.debugOn();
  in = minim.getLineIn(Minim.MONO, 1024);
  out = minim.getLineOut(Minim.MONO, 1024);
  // create an FFT object that has a time-domain buffer 
  // the same size as jingle's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum
  // will be 512. see the online tutorial for more info.
  fft = new FFT(out.bufferSize(), out.sampleRate());
  spectrum = new SpectrumCollector();
  // adds the signal to the output
  out.addSignal(spectrum);

  buffer = new float[bsize];
}

public void captureEvent(Capture c) {
  c.read();
}

void draw() {
  loadPixels();
//  background(0);

  int index = int (video.width*samplerow); //the middle horizontal strip

  //fft.forward(in.mix);

  for (int x = 0; x < int (width); x+=res) {
    
//    int r = 0, g = 0, b = 0;
//    
//    for (int xoff = int (samplesize/-2); xoff < int (samplesize/2); xoff+=1) {      
//      int pixelColor = video.pixels[int (video.width*samplerow) + int (video.width*xoff)];
//       // Faster method of calculating r, g, b than red(), green(), blue() 
//       r = r+((pixelColor >> 16) & 0xff);
//       g = g+((pixelColor >> 8) & 0xff);
//       b = b+(pixelColor & 0xff);
//    }    
//    
//    r = int (r/samplesize);
//    g = int (g/samplesize);
//    b = int (b/samplesize);
    
      int pixelColor = video.pixels[index];
       int r = (pixelColor >> 16) & 0xff;
       int g = (pixelColor >> 8) & 0xff;
       int b = pixelColor & 0xff;

    for (int y = 0; y < int (height); y+=res) {
      pixels[(y*width)+x] = color(r,g,b);
    }

//    fft.setBand(x, int ((r+b+g)/(3.0000*255)));    

    index++;
  }

//  fft.inverse(buffer);
  updatePixels();
}

void stop()
{
  out.close();
  minim.stop(); 
  super.stop();
}

