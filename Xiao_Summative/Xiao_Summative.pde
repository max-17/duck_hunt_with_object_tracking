/*
Xiao David
26/10/2018

Interactive duck shooting game with forest scenery and exploding ducks!
User is able to toggle rain, time of day, and other fun activities.

KEYBOARD & MOUSE INTERACTIONS (READ!):

Keyboard Interactions:
- (w): toggles rain to appear on screen
- (c): toggles between day and night (movement of circle in sky)
- (r): Reloads bullets for gun (activates reload sound)

Mouse Click Interactions:
- mouse release:
  * Sniper sound when ammo > 0
  * empty clip sound when ammo = 0
- click on a duck:
  * duck explodes! 
  * plus 1 point
- click on rock:
  * OVER 9000 POINTS
  * More you click, the more the rock changes color!

3 Shapes:
- circle (e.g. moon)
- triangle (e.g. trees)
- rectangle (e.g. tree trunk)
- etc

3 Colors:
- green (e.g. trees)
- brown (e.g. tree trunks)
- black (e.g. night sky)
- etc

1 Custom Shape:
- rock

6 Elements:
- Ducks
- Trees
- Rock
- Sun
- Moon
- Rain
- Blinking Stars
- etc

Animated Elements:
- tinkling stars at night
- ducks moving across screen
- sun/moon phases
- rain pouring down

Outside curriculum:
- sound
- images
- arrays
- no cursor
- custom functions
- use of parabola

Commeting:
- comments describing 
  * functions
  * if statemennts
  * loops
  * Anything that user can hear/see 
  
Overall Appearance:
- Absolutely beautiful.
- Out of this world.
- Outstanding.
*/

// import sound module
import ddf.minim.*;



// Launches a webcam and searches for square-binary fiducials.  Draws a cube over the feducials when it
// finds them and their ID number

import processing.video.*;
import boofcv.processing.*;
import java.util.*;

Capture cam;
SimpleFiducial detector;



PImage duck;
PImage target;
PImage explosion;

AudioSnippet shotSound;
AudioSnippet emptyClipSound;
AudioSnippet gunReloadSound;
Minim minim;

// Initiate beginning duck positions
float duckX1=random(1000, 1800), duckY1=random(0, 300);
float duckX2=random(1000, 1800), duckY2=random(0, 300);
float duckX3=random(1000, 1800), duckY3=random(0, 300);
float duckX4=random(1000, 1800), duckY4=random(0, 300);
float duckX5=random(1000, 1800), duckY5=random(0, 300);

// current background color, ground color, sun/moon color, hill color
color backColor = color(30, 200, 255);
color groundColor = color(12, 193, 40);
color sunColor = color(255, 130, 13);
color moonColor = color(213, 238, 240);
color hillColor = color(12, 147, 22);

// variables to keep track of time passed since explosion
int passed1 = 1, passed2 = 1, passed3 = 1, passed4 = 1, passed5 = 1;

// variables to keep track of location where duck died
float diedX1, diedY1, diedX2, diedY2, diedX3, diedY3, diedX4, diedY4, diedX5, diedY5;

// ellipse of sun/moon x-coordinate overtime
float sunX=0, moonX=500;

// wait timer for star drawing
int starWait=0;

// create array of 50 static star positions stored by x and y;
float[] staticStarX = new float[50];
float[] staticStarY = new float[50];

// array to store 5 random twinkling stars
float[] twinkleStarX = new float[5];
float[] twinkleStarY = new float[5];

// array to store rain droplets
float[] rainDropX = new float[800];
float[] rainDropY = new float[800];

// boolean to check if we should draw rain
boolean displayRain = false;

// variable to store bullet reload
int nBullets = 5;

// variable to store number of ducks killed
int numDuckKilled = 0;

// variable to record damage done to rock
int rockDmg = 0;

void setup() {
 // size of screen
 size(1000, 600); 
 
 
 
  // Open up the camera so that it has a video feed to process
  initializeCamera(width, height);
  //surface.setSize(cam.width, cam.height);

  // Robust fiducial detectors are invariant to lightning conditions, while the other is much faster
  // but is much more brittle
  detector = Boof.fiducialSquareBinaryRobust(0.01);
  //detector = Boof.fiducialSquareBinary(0.1,100);

  // Much better results if you calibrate the camera.
  // It is guessing the parameters and assuming there is no lens distortion, which is never true!
  // detector.setIntrinsic(intrinsic);
  detector.guessCrappyIntrinsic(cam.width,cam.height);
 
 
 // load in images to their respective variables
 duck = loadImage("duckImage.png");
 explosion = loadImage("explosionImage.png");
 target = loadImage("targetImage.png");
 
 // resize to desired length/width
 target.resize(50, 50);
 duck.resize(110, 80);
 explosion.resize(110, 110);
 
 // load in sounds to their respective variables
 minim = new Minim(this);
 shotSound = minim.loadSnippet("shotSound.mp3");
 emptyClipSound = minim.loadSnippet("emptyClipSound.mp3");
 gunReloadSound = minim.loadSnippet("gunReloadSound.mp3");
 
 // remove cursor
 noCursor();
 
 // predetermine random locations of static stars
 for (int i = 0; i < 50; i++) {
   staticStarX[i] = random(10, 990);
   staticStarY[i] = random(10, 390); 
 }
 
 // predetermine random locations of rain droplets
 for (int i = 0; i < 300; i++) {
   rainDropX[i] = random(0, 1000);
   rainDropY[i] = random(-600, 0);
 }
}

float aimX, aimY;

boolean detected = false;
// draw elements on to screen
void draw() {
  // dynamic background color 
  background(backColor);
  
  
  
   if (cam.available() == true) {
    cam.read();

    List<FiducialFound> found = detector.detect(cam);

    //image(cam, 0, 0);

    //for( FiducialFound f : found ) {
    for (int i=0; i<found.size(); i++){
      FiducialFound f=found.get(i);
      //  println("ID             "+f.getId());
      println("image location "+(float)f.getImageLocation().getX()+"  "+(float)f.getImageLocation().getY() );
      //  println("world location "+f.getFiducialToCamera().getT());
      aimX=width-(float)f.getImageLocation().getX();
      aimY=(float)f.getImageLocation().getY();
      //detector.render(this,f);
    }
    
    if (found.size()>0){
    detected=true;
    }else{
      detected=false;
      }
  }
  
  
  
  // activate sky activities based on whether it is day time or night time(color=0)
  if (backColor == color(0)) {
    // draw stars at each draw call as long as it has been a second since locations where determined
    // otherwise, generate new random locations to be drawn at each call
    if (millis() <= starWait+1000) {
      drawStars(); // function to draw stars
    } else {
      // generate new random twinkling star position in sky
      starWait = millis();
      for (int i = 0; i < 5; i++) {
        twinkleStarX[i] = random(10, 990);
        twinkleStarY[i] = random(10, 390);
      }
    }
    
    // draw static stars that are in the sky
    // by iterating through the arrays that store star x, y
    fill(255);
    for (int i = 0; i < 50; i++) {
      ellipse(staticStarX[i], staticStarY[i], 5, 5);
    }
    
    // commence moon phase, where moon replaces sun in parabolic direction
    moonPhase();
  } else {
   // commence sun phase, where sun replaces moon in parabolic direction
    sunPhase();
  }
  
  // Draw a small hill with an ellipse
  // color it based on time of day
  fill(hillColor);
  ellipse(430, 400, 200, 150);
  
  // draw green rect to act as ground
  fill(groundColor);
  rect(0, 400, 1010, 300);
  
  // Draw many tree shapes across ground;
  drawTree(300, 255);
  drawTree(500, 225);
  drawTree(700, 300);
  drawTree(1000, 260);
  drawTree(200, 300);
  drawTree(50, 325);
  drawTree(900, 320);
  drawTree(800, 350);
  
  // draw grey rock on ground using custom shape
  // rock color is changed the more you hit it
  fill(142+rockDmg, 142+rockDmg, 142);
  beginShape();
  vertex(380, 540);
  vertex(390, 520);
  vertex(400, 510);
  vertex(420, 510);
  vertex(436, 530);
  vertex(420, 545);
  vertex(390, 550);
  vertex(380, 540);
  endShape();  
  
  // determines how long explosion animation will last after duck dies
  // checks for each duck whether program length has surpassed its dying animation duration
  // only draws explosion if time is within threshold
  if (millis() <= passed1) {
    image(explosion, diedX1, diedY1);
  } 
  if (millis() <= passed2) {
    image(explosion, diedX2, diedY2);
  } 
  if (millis() <= passed3) {
    image(explosion, diedX3, diedY3);
  }
  if (millis() <= passed4) {
    image(explosion, diedX4, diedY4);
  }
  if (millis() <= passed5) {
    image(explosion, diedX5, diedY5);
  }
  
  // ducks fly from right to left are a rate of 0.9 per draw function call
  duckX1 -= 0.9;
  duckX2 -= 0.9;
  duckX3 -= 0.9;
  duckX4 -= 0.9;
  duckX5 -= 0.9;
  
  // redraw ducks to update their x position
  image(duck, duckX1, duckY1);
  image(duck, duckX2, duckY2);
  image(duck, duckX3, duckY3);
  image(duck, duckX4, duckY4);
  image(duck, duckX5, duckY5);
  
  // target acting as cursor
  // target image follos mouse position
  
  
  if(detected){
  
    image(target, aimX-20, aimY-20);
  
  }else{
  
  
  image(target, mouseX-20, mouseY-20);
  }
  // check whether ducks move past screen
  // if they move past, reset their x, y to a random position on right side of screen
  if (check(duckX1)) {
    duckX1=random(1000, 1800); 
    duckY1=random(0, 300);
  }
  if (check(duckX2)) {
    duckX2=random(1000, 1800); 
    duckY2=random(0, 300);
  }
  if (check(duckX3)) {
    duckX3=random(1000, 1800); 
    duckY3=random(0, 300);
  }
  if (check(duckX4)) {
    duckX4=random(1000, 1800); 
    duckY4=random(0, 300);
  }
  if (check(duckX5)) {
    duckX5=random(1000, 1800); 
    duckY5=random(0, 300);
  }
  
  // display current amount of ammo and score
  fill(255);
  textSize(20);
  text("Ammo: " + nBullets, 20, 30);
  text("Score: " + numDuckKilled, 800, 30);
  
  // creates rain animation when variable displayRain is true
  if (displayRain) drawRain(); 
}

// detects key press
void keyPressed() {
  // if 'c' is pressed, change time of day:
   if (key == 'c' ) {
     // if current time is not night, then change to night time
     // otherwise change to day time
     if (backColor != color(0)) {
       // set sky to black and ground+hill to darker green
       // prepare moon and sun positions for phase change
       backColor = color(0);
       groundColor = color(13, 57, 3);
       moonX = 0;
       hillColor = color(1, 46, 4);
       sunX = 500;
     } else {
       // set sky to blue and ground to lighter green
       // prepare moon and sun positions for phase change
       backColor = color(30, 200, 255);
       groundColor = color(12, 193, 40);
       hillColor = color(12, 147, 22);
       sunX = 0;
       moonX = 500;
     }
   } 
   // if 'r' is pressed, generate reload actions
   else if (key == 'r') {
      // rewind and play reload sound
      gunReloadSound.rewind();
      gunReloadSound.play();
      // reset bullets to clip size of 5
      nBullets = 5;
   } 
   // if 'w' is pressed, toggle displayRain variable to either true or false
   else if (key == 'w') {
      // if already raining, set to false
      // otherwise set to true
      if (displayRain) displayRain = false;
      else displayRain = true;
   }
}

// mouse release indicates player shoots
void mouseReleased() {
  // if clip is empty cannot shoot
  if (nBullets==0) {
    // play empty clip sound
    emptyClipSound.rewind();
    emptyClipSound.play();
    // exit function now
    return; 
  }
  
  // decrease ammo by 1 since user shot
  nBullets--;
  
  // play shot sound
  shotSound.rewind();
  shotSound.play();
  
  // detect whether a duck is shot using a rectangular hitbox
  // if shot, set death animaion duration to last 1 second and record death spot for explosion image
  // add to score
  // reset duck x and y to random positions on right side of screen
  if (hit(duckX1, duckY1)) {
    passed1 = millis()+1000;
    diedX1 = duckX1; diedY1 = duckY1;
    duckX1=random(1000, 1800); 
    duckY1=random(0, 300);
    numDuckKilled++;
  } else if (hit(duckX2, duckY2)) {
    passed2 = millis()+1000;
    diedX2 = duckX2; diedY2 = duckY2;
    duckX2=random(1000, 1800); 
    duckY2=random(0, 300);
    numDuckKilled++;
  } else if (hit(duckX3, duckY3)) {
    passed3 = millis()+1000;
    diedX3 = duckX3; diedY3 = duckY3;
    duckX3=random(1000, 1800); 
    duckY3=random(0, 300);
    numDuckKilled++;
  } else if (hit(duckX4, duckY4)) {
    passed4 = millis()+1000;
    diedX4 = duckX4; diedY4 = duckY4;
    duckX4=random(1000, 1800); 
    duckY4=random(0, 300);
    numDuckKilled++;
  } else if (hit(duckX5, duckY5)) {
    passed5 = millis()+1000;
    diedX5 = duckX5; diedY5 = duckY5;
    duckX5=random(1000, 1800); 
    duckY5=random(0, 300);
    numDuckKilled++;
  }
  // check if rock is hit. If hit, add 9001 points to score!
  // increase rockDamage variable by 6
  if (mouseX >= 380 && mouseX <= 436 && mouseY >= 510 && mouseY <= 550) {
    numDuckKilled+=9001;
    rockDmg+=20;
  }
}

// following are helper functions:

// sun phase (sun comes in from the right, and moon leaves to left)
// draw in a parabolic direction
void sunPhase() {
  // redraw sun and moon
  fill(sunColor);
  ellipse(sunX, parabola(sunX), 120, 120);
  fill(moonColor);
  ellipse(moonX, parabola(moonX), 120, 120);
  
  // sun should not move past center of screen
  if (sunX <= 500) sunX+=0.5;
  moonX += 0.5;
}

// moon phase (moon comes in from right, and sun leaves to left)
// draw in a parabolic direction
void moonPhase() {
  // redraw sun and moon
  fill(sunColor);
  ellipse(sunX, parabola(sunX), 120, 120);
  fill(moonColor);
  ellipse(moonX, parabola(moonX), 120, 120);
  // moon should not move past center of screen
  if (moonX <= 500) moonX+=0.5;
  sunX += 0.5;
}

// check whether any ducks move past left of screen
// return true or false based on above condition
boolean check(float x) {
  if (x < -110) return true;
  return false;
}

// check whether duck is within shot threshhold
// return true or false based on above condition
boolean hit(float x, float y) {
  // check if hit within rectangle hitbox
  if (mouseY > y && mouseY < y+80 && mouseX > x && mouseX < x+120) return true;
  return false;
}

// draws a tree
void drawTree(int x, int y) {
  // draw green tree top as green triangle
  fill(5, 88, 15);
  triangle(x, y, x+100, y+225, x-100, y+225);
  
  // draw brown tree base as brown rectangle
  fill(59, 36, 14);
  rect(x-25, y+225, 50, 100);
}

// calculate parabolic direction for sun and moon
float parabola(float x) {
  return 0.05*(x-500)*0.05*(x-500)+75;
}

// draws twinkling star
void drawStars() {
  // set line color to white
  stroke(255);
  
  // iterates through arrays that store each star's position to draw them
  for (int i = 0; i < 5; i++) {
    // draw as a cross
    line(twinkleStarX[i]+5, twinkleStarY[i], twinkleStarX[i]-5, twinkleStarY[i]);
    line(twinkleStarX[i], twinkleStarY[i]+5, twinkleStarX[i], twinkleStarY[i]-5);
  }
  // remove stroke 
  noStroke();
}

// draws rain
void drawRain() {
  // give rain a deep blue color
  stroke(0, 0, 230);
  
  // iterates through arrays that store each rain droplet's position to draw them
  for (int i = 0; i < 800; i++) {
    // draw as a thick line
    line(rainDropX[i], rainDropY[i], rainDropX[i], rainDropY[i]+5); 
    
    // make rain go downards
    rainDropY[i]+=8;
    
    // if the rain goes below the screen, reset to random positions on top of screen
    if (rainDropY[i] > 600) {
      rainDropX[i] = random(0, 1000);
      rainDropY[i] = random(-600, 0);
    }
  }
  noStroke();
}









void initializeCamera(int desiredWidth, int desiredHeight ) {
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
     println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
   
  }
  cam = new Capture(this, desiredWidth, desiredHeight, cameras[0]);
    cam.start();     
}
