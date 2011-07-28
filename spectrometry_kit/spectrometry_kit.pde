/*

 Spectrofone - a spectrometer-based musical instrument or guitar pedal
 by Jeffrey Warren of the Public Laboratory for Open Technology and Science
 publiclaboratory.org
 
 (c) Copyright 2011 Jeffrey Warren
 
 This code is released under the MIT License
 
 */

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
int bsize = 512;

int res = 1;
int samplesize = 30;
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
    fft.forward(samp);
    loadPixels();

    int index = int (video.width*samplerow); //the middle horizontal strip

    for (int x = 0; x < fft.specSize(); x+=1) {

      int vindex = int (map(x,0,fft.specSize(),0,video.width));
      int pixelColor = pixels[vindex];
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;

      //samp[x] = samp[x] *0;//* map((r+b+g)/3,0,255,0.00,1.00);
      fft.setBand(x,map((r+b+g)/3.00,0,255,0,1));
      //      fft.setBand(x,fft.getBand(x) * map((r+b+g)/3.00,0,255,0,1));
      index++;
    }
    fft.inverse(samp);
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
  size(1280, 720, P2D);
//  size(640, 480, P2D);
  //size(320, 240, P2D);
  // Or run full screen, more fun! Use with Sketch -> Present
  //size(screen.width, screen.height, OPENGL);

  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, width, height, 20);
  samplerow = int (height*(0.850));
  video.settings();

  minim = new Minim(this);
  minim.debugOn();
  in = minim.getLineIn(Minim.MONO, bsize);
  out = minim.getLineOut(Minim.MONO, bsize);
  // create an FFT object that has a time-domain buffer 
  // the same size as jingle's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum
  // will be 512. see the online tutorial for more info.
  fft = new FFT(out.bufferSize(), out.sampleRate());
  fft.window(FFT.HAMMING);
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
//  background(0);
  int[] savedpixels = video.pixels;

  int index = int (video.width*samplerow); //the middle horizontal strip

  for (int x = 0; x < int (width); x+=res) {

    int r = 0, g = 0, b = 0;

    for (int yoff = int (samplesize/-2); yoff < int (samplesize/2); yoff+=1) {
      int sampleind = int ((video.width*samplerow)+(video.width*yoff)+x);

      if (sampleind >= 0 && sampleind <= (video.height*video.width)) {
        int pixelColor = savedpixels[sampleind];
        // Faster method of calculating r, g, b than red(), green(), blue() 
        r = r+((pixelColor >> 16) & 0xff);
        g = g+((pixelColor >> 8) & 0xff);
        b = b+(pixelColor & 0xff);
      }
    }    

    r = int (r/(samplesize*1.00));
    g = int (g/(samplesize*1.00));
    b = int (b/(samplesize*1.00));

    //      int pixelColor = video.pixels[index];
    //       int r = (pixelColor >> 16) & 0xff;
    //       int g = (pixelColor >> 8) & 0xff;
    //       int b = pixelColor & 0xff;

    for (int y = 0; y < int (height/4); y+=res) {
      pixels[(y*width)+x] = color(r,g,b);
    }

    index++;
  }

  updatePixels();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == DOWN) {
      samplerow += 1;
      if (samplerow >= video.height) {
        samplerow = video.height;
      }
    } 
    else if (keyCode == UP) {
      samplerow -= 1;
      if (samplerow <= 0) {
        samplerow = 0;
      }
    } 
  }
  println(samplerow);
}

void stop()
{
//  out.close();
  minim.stop(); 
  super.stop();
}


