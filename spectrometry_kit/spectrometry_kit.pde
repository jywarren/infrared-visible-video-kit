import processing.video.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

Capture video;

Minim minim;
AudioInput in;
AudioOutput out;
FFT fft;
SpectrumCollector spectrumfilter;

float[] buffer;
int bsize = 1024;

int res = 1;
int samplesize = 50;
int samplerow;

class SpectrumCollector implements AudioSignal, AudioListener
{
  private float[] leftChannel;
  private float[] rightChannel;
  SpectrumCollector(int sample)
  {
    leftChannel = new float[sample];
    rightChannel= new float[sample];
  }
  // This part is implementing AudioListener interface, see Minim reference
  synchronized void samples(float[] samp)
  {
     arraycopy(samp,leftChannel);
  }
  synchronized void samples(float[] sampL, float[] sampR)
  {
    arraycopy(sampL,leftChannel);
    arraycopy(sampR,rightChannel);
  }  
  // This part is implementing AudioSignal interface, see Minim reference
  void generate(float[] samp)
  {
    arraycopy(leftChannel,samp);
//    println("left channel, before: "+ samp[0] + ", " + samp[samp.length/2] );
    fft.forward(samp);
    loadPixels();
    background(0);
 
    int index = int (video.width*samplerow); //the middle horizontal strip

    for (int x = 0; x < fft.specSize(); x+=1) {

      int vindex = int (map(x,0,fft.specSize(),0,video.width));
      int pixelColor = video.pixels[vindex];
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;

      //samp[x] = samp[x] *0;//* map((r+b+g)/3,0,255,0.00,1.00);
      fft.setBand(x,fft.getBand(x) * map((r+b+g)/3.00,0,255,0,1));

      index++;
    }
//    println("Desired spectrum: "+samp[0] + ", " + samp[samp.length/2] + ", " + index);
    fft.inverse(samp);
    
//    println("Resulting spectrum: "+samp[0] + ", " + samp[samp.length/2] + ", " + index);
  }
  // this is a stricly mono signal
  void generate(float[] left, float[] right)
  {
//     arraycopy(leftChannel,left);
//     arraycopy(rightChannel,right);
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
  spectrumfilter = new SpectrumCollector(out.bufferSize());
  // adds the signal to the output
//  out.addSignal(spectrumfilter);
  in.addListener(spectrumfilter);
  out.addSignal(spectrumfilter);

  buffer = new float[bsize];
}

public void captureEvent(Capture c) {
  c.read();
}

void draw() {
  loadPixels();
  background(0);

  int index = int (video.width*samplerow); //the middle horizontal strip

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

    index++;
  }

  updatePixels();
}

void stop()
{
  out.close();
  minim.stop(); 
  super.stop();
}

