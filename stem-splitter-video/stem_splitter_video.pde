/**
* REALLY simple processing sketch that sends mouse x and y position of box to wekinator
* This sends 2 input values to port 6448 using message /wek/inputs
* Adapated from https://processing.org/examples/mousefunctions.html by Rebecca Fiebrink
**/

import oscP5.*;
import netP5.*;
import processing.video.*;

Movie movie;
OscP5 oscP5;
NetAddress dest;
PFont f;
PImage img;



float bx;
float by;
int boxSize = 30;
boolean overBox = false;
boolean locked = false;
float xOffset = 0.0; 
float yOffset = 0.0;

boolean updatePos = false;
float startTime;

boolean updateSpeed = false;
float multiplier;

int songInd = 0;
Movie[] movies = new Movie[128];


String videoList[] = {
  "smile.mov",
  "monkeys.mov",
  "evergreen.mov",
  "glee.mov", 
  "beautiful.mov"
};

void setup() {
  
   surface.setTitle("stem splitter");

  // load each movie
  for( int i = 0; i < videoList.length; i++ )
  {
      // make a Movie object for each video
      movies[i] = new Movie(this, videoList[i] );
      // set it to loop
      movies[i].loop();
      // silence the video (since the audio will come from mosaic audio)
      movies[i].volume(0);
  }
  
   



  setupOSC( 5555 );

  f = createFont("Calibri", 15);
  textFont(f);

  size(1280, 720, P2D);
  noStroke();
  smooth();
  
  bx = width/2.0;
  by = height/2.0;
  rectMode(RADIUS);  
  
  dest = new NetAddress("127.0.0.1",6448);
  
}

void setupOSC( int port )
{
    // Listen for keyboard input messages from ChucK
    oscP5 = new OscP5( this, 9990 );
}

void movieEvent(Movie movie) {
  movie.read();
}


void draw() {
      //background(255);
     img = loadImage("inputs.png");
    tint(255, 50); 
  
    image(img, 0, 0);
    //image(movie, 0, 0, 1280, 720);
    image(movies[songInd], 40, 40, 1200, 640);
  
   if( updatePos )
    {
      for( int i = 0; i < videoList.length; i++ )
      {
          movies[i].jump( startTime );
      }
        updatePos = false;
    }
       if( updateSpeed )
    {
      for( int i = 0; i < videoList.length; i++ )
      {
          movies[i].speed( multiplier );
      }
        updateSpeed = false;
    }
    
    

  text("Drag the box around to explore the soundscape!", 40, 50);
  text("x=" + bx + ", y=" + by, 40, 65);
  
  // Fill when dragging box
  fill(255);

  // Test if the cursor is over the box 
  if (mouseX > bx-boxSize && mouseX < bx+boxSize && 
      mouseY > by-boxSize && mouseY < by+boxSize) {
    overBox = true;  
    if(!locked) { 
      stroke(255, 255, 255); 
      fill(255, 255, 255);
    } 
  } else {
    stroke(255, 255, 255); 
    fill(255, 255, 255);
    overBox = false;
  }
  
  // Draw the box
  rect(bx, by, boxSize, boxSize);
  
  //Send the OSC message with box current position
  sendOsc();
}

// incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage theOscMessage)
{
  if( theOscMessage.checkAddrPattern("/video/pos")==true )
  {
      updatePos = true;
      startTime = theOscMessage.get(0).floatValue();
      return;
  } 
  if( theOscMessage.checkAddrPattern("/video/speed")==true )
  {
      updateSpeed = true;
      multiplier = theOscMessage.get(0).floatValue();
      return;
  } 
  if( theOscMessage.checkAddrPattern("/video/song")==true )
  {
      songInd = theOscMessage.get(0).intValue();
      return;
  } 
}


void mousePressed() {
  if(overBox) { 
    locked = true; 
    fill(255, 255, 255);
  } else {
    locked = false;
  }
  xOffset = mouseX-bx; 
  yOffset = mouseY-by; 

}

void mouseDragged() {
  if(locked) {
    bx = mouseX-xOffset; 
    by = mouseY-yOffset; 
  }
}

void mouseReleased() {
  locked = false;
}


void sendOsc() {
  OscMessage msg = new OscMessage("/wek/inputs");
  msg.add((float)bx); 
  msg.add((float)by);
  oscP5.send(msg, dest);
}
