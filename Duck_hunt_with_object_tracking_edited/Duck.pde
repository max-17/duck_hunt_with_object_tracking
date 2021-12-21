

class Duck{
  
  
  float duckX, duckY=random(50, height-height/3);
  float flip;
  float speedX = 1;
  int passedTime = 1;
  boolean hit = false;
  
   Duck(float toflip) {
    flip = toflip;
    if (flip>1){
      duckX = 0; 
    } else {
    duckX = width;
  }; 
  }
    
  void display() {
    if(!hit){
      if(flip>1){
        image(duckflip, duckX, duckY);
        duckX += speedX;
      } if(flip<1) {
        image(duck, duckX, duckY);
        duckX -= speedX;
      }
    }
    
    if(hit && millis() <= passedTime){
     
        image(explosion, duckX, duckY);
        
    } 
   
  }
}
