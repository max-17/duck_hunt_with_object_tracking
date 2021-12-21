
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
PImage duckflip;
PImage target;
PImage explosion;
PImage bg;
PImage bg2;
PImage background;

AudioSnippet shotSound;
AudioSnippet emptyClipSound;
AudioSnippet gunReloadSound;
Minim minim;

// Initiate beginning duck positions
ArrayList <Duck> ducks = new ArrayList<Duck>();

// current background color, ground color, sun/moon color, hill color
color backColor = color(30, 200, 255);

// variable to store bullet reload
int nBullets = 5;

// variable to store number of ducks killed
int numDuckKilled = 0;


void setup() {
 // size of screen
 size(1280, 720);
 
 for (int i =0; i<5; i++){
   ducks.add(new Duck(random(2)));
 }
 
 
  // Open up the camera so that it has a video feed to process
  initializeCamera(1280, 720);
  //surface.setSize(cam.width, cam.height);

  // Robust fiducial detectors are invariant to lightning conditions, while the other is much faster
  // but is much more brittle
  detector = Boof.fiducialSquareBinaryRobust(0.01);
  //detector = Boof.fiducialSquareBinary(0.1,100);

  // Much better results if you calibrate the camera.
  // It is guessing the parameters and assuming there is no lens distortion, which is never true!
  detector.guessCrappyIntrinsic(cam.width,cam.height);
 
 
 // load in images to their respective variables
 duck = loadImage("duckImage.png");
 duckflip = loadImage("duckflip.png");
 explosion = loadImage("explosionImage.png");
 target = loadImage("targetImage.png");
 bg = loadImage("bg.jpg");
 bg2 = loadImage("bg2.jpg");
 background = bg;
 
 // resize to desired length/width
 target.resize(50, 50);
 duck.resize(110, 80);
 duckflip.resize(110, 80);
 explosion.resize(110, 110);
 
 // load in sounds to their respective variables
 minim = new Minim(this);
 shotSound = minim.loadSnippet("shotSound.mp3");
 emptyClipSound = minim.loadSnippet("emptyClipSound.mp3");
 gunReloadSound = minim.loadSnippet("gunReloadSound.mp3");
 
 // remove cursor
 noCursor();
 
}

float aimX, aimY;

boolean objectDetected = false, gameover = false;
// draw elements on to screen
void draw() {
  
  background(background);
  
   if (cam.available() == true) {
    cam.read();

    List<FiducialFound> found = detector.detect(cam);

   
    
    if (found.size()==1){
       
      aimX=width-(float)found.get(0).getImageLocation().getX();
      aimY=(float)found.get(0).getImageLocation().getY();
      //println(aimX);
      //print(aimY);
    
    
      objectDetected=true;
    }else{
      objectDetected=false;
      }
  }
  
  // ducks for loop
  for (int i=0; i<ducks.size(); i++){
    Duck d = ducks.get(i);
    d.display();
    
    if(d.hit && millis() > d.passedTime){
     
      ducks.remove(i);
      ducks.add(new Duck(random(2)));  
    }
    
    // game over
    if (d.flip>1){
      if (d.duckX>width){
        
        gameover = true;
      }
    } else {
      if (d.duckX<0){
        gameover=true;
      }
    }
  }
  
  
  
  if(gameover){
    textSize(50);
    text("GAME OVER", (width/2)-150, height/2);
    ducks.clear();
  }
  // target acting as cursor

  
  if(objectDetected){
  
    image(target, aimX-20, aimY-20);
  
  }else{
  
  
  image(target, mouseX-20, mouseY-20);
  }
   
  // display current amount of ammo and score
  fill(255);
  textSize(20);
  text("Ammo: " + nBullets, 20, 30);
  text("Score: " + numDuckKilled, 800, 30);
  
  
}

// detects key press
void keyReleased() {
  
  if (key == ' ' ) {

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
  // add to score
  for (Duck d : ducks){
    if (hitAim(d.duckX, d.duckY)) {
      d.hit = true;
      d.passedTime = millis()+1000;
      
      numDuckKilled++;
    } 
  }
      
  }
 
   // reload actions
   if (key == 'r') {
      // rewind and play reload sound
      gunReloadSound.rewind();
      gunReloadSound.play();
      // reset bullets to clip size of 5
      nBullets = 5;
   } 
  
  //change background
   if (key == 'b') {
      
      background = bg2;;
   }
    if (key == 'v') {
      
      background = bg;;
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
  
  // add to score
  for (Duck d : ducks){
    if (hit(d.duckX, d.duckY)) {
      d.hit = true;
      d.passedTime = millis()+1000;
      
      numDuckKilled++;
    } 
  }
}



// check whether duck is within shot threshhold
// return true or false based on above condition
boolean hit(float x, float y) {
  // check if hit within rectangle hitbox
  if (mouseY > y && mouseY < y+80 && mouseX > x-20 && mouseX < x+120) return true;
  return false;
}

boolean hitAim(float x, float y) {
  // check if hit within rectangle hitbox
  if (objectDetected && aimY > y && aimY < y+80 && aimX > x-20 && aimX < x+120) return true;
  return false;
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
