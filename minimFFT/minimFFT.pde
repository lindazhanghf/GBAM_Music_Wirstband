/**
Hacked together from the minim tutorial examples
**/

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
//AudioPlayer jingle;
FFT fftLin;
FFT fftLog;
AudioInput jingle;

float height3;
float height23;
float spectrumScale = 4;

PFont font;

void setup()
{
  size(512, 480);
  height3 = height/3;
  height23 = 2*height/3;

  minim = new Minim(this);
  jingle =  minim.loadFile("./../audio/BIGBANG(BANG_BANG_BANG)_(Official_Instrumental).mp3", 1024);
  
  // loop the file
  //jingle.loop();
  
  // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be 1024. 
  // see the online tutorial for more info.
  fftLin = new FFT( jingle.bufferSize(), 1024);//jingle.sampleRate() );
  
  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fftLin.linAverages(12 );
  
  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT( jingle.bufferSize(), jingle.sampleRate() );
  
  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages( 22, 3 );
  
  rectMode(CORNERS);
//  font = loadFont("ArialMT-12.vlw");
}

void draw()
{
  background(0);
  
//  textFont(font);
  textSize( 18 );
 
  float centerFrequency = 0;
  
  // perform a forward FFT on the samples in jingle's mix buffer
  // note that if jingle were a MONO file, this would be the same as using jingle.left or jingle.right
  fftLin.forward( jingle.mix );
  fftLog.forward( jingle.mix );
 
  // draw the full spectrum
  {
    noFill();
    
}
  
  // no more outline, we'll be doing filled rectangles from now
  noStroke();
  
  // draw the linear averages
  {
    // since linear averages group equal numbers of adjacent frequency bands
    // we can simply precalculate how many pixel wide each average's 
    // rectangle should be.
    int w = int( width/fftLin.avgSize() );
    for(int i = 0; i < fftLin.avgSize(); i++)
    {
      // if the mouse is inside the bounds of this average,
      // print the center frequency and fill in the rectangle with red
      //if ( mouseX >= i*w && mouseX < i*w + w )
      //{
      //  centerFrequency = fftLin.getAverageCenterFrequency(i);
        
      //  fill(255, 128);
        //text("Linear Average Center Frequency: " + centerFrequency, 5, height23 - 25);
        
      //  fill(255, 0, 0);
      //}
      //else
      {
          fill(128);
      }
      // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better
      fill(0, 0,int(fftLin.getAvg(i)*20*spectrumScale));
      rect(i*w, height, i*w + w, height - int(fftLin.getAvg(i)*20*spectrumScale));//these things draw the wrong way up...
      //rect(i*w, height, i*w + w, int(fftLin.getAvg(i)*10*spectrumScale));
      stroke(255);
      line(i*w, height, i*w, height - 10) ;
      noStroke();
      print(i + " " + fftLin.getAvg(i)*20*spectrumScale + " ");
    }
  }
  println();
  
}
