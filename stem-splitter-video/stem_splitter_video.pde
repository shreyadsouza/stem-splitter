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

boolean updateSong = false;
float songInd = 0;

String videoList[] = {
  "smile.mp4",
  "monkeys.mp4",
  "evergreen.mp4",
  "ken.mp4"
};

void setup() {
  
   surface.setTitle("stem splitter");

   movie = new Movie(this, "smile.mov");
   movie.loop();
   movie.volume(0);
  
   



  setupOSC( 5555 );

  f = createFont("Calibri", 15);
  textFont(f);

  size(1280, 720, P2D);
  noStroke();
  smooth();
  
  bx = width/2.0;
  by = height/2.0;
  rectMode(RADIUS);  
  
  /* start oscP5, listening for incoming messages at port 12000 */
  //oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1",6448);
  
}

void setupOSC( int port )
{
    // start oscP5, listening for incoming messages at port 12000
    oscP5 = new OscP5( this, 9990 );
    println("listening");
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
    image(movie, 40, 40, 1200, 640);
  
   if( updatePos )
    {
        // only jump once per update (e.g., once per incoming OSC message)
        movie.jump( startTime );
        // set to false until next incoming message
        updatePos = false;
    }
       if( updateSpeed )
    {
        // only jump once per update (e.g., once per incoming OSC message)
        movie.speed( multiplier );
        // set to false until next incoming message
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
  // print the address pattern and the typetag of the received OscMessage
  // print("### received an osc message.");
  // print(" addrpattern: "+theOscMessage.addrPattern());
  // println(" typetag: "+theOscMessage.typetag());

  if( theOscMessage.checkAddrPattern("/video/pos")==true )
  {
      updatePos = true;
      // parse theOscMessage and extract the values from the osc message arguments.
      startTime = theOscMessage.get(0).floatValue();
      println(" values: "+startTime);
      return;
  } 
  if( theOscMessage.checkAddrPattern("/video/speed")==true )
  {
      updateSpeed = true;
      // parse theOscMessage and extract the values from the osc message arguments.
      multiplier = theOscMessage.get(0).floatValue();
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
