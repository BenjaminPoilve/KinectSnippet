/*snipplet to convert and kinect image to opencv object and track blob 
on a specific depthzone. Use parts of code from opencvexemple and from
the "making things see" book (oreilly). 
         Made by Benjamin Poilvé 2013 */



import hypermedia.video.*;
import java.awt.Rectangle;
import java.awt.Point;
import SimpleOpenNI.*;

PImage display;
SimpleOpenNI  context;
OpenCV opencv;
PFont font;

void setup() {
   context = new SimpleOpenNI(this);
   
  // mirror is by default enabled
  context.setMirror(true);
  
  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  

 
  size(screen.width, screen.height); 

    

    opencv = new OpenCV( this );
    opencv.capture(screen.width,screen.height);
    
    font = loadFont( "AndaleMono.vlw" );
    textFont( font );

    println( "Drag mouse inside sketch window to change threshold" );
    println( "Press space bar to record background image" );

}



void draw() {
  //get the information from the kinext
    context.update();
  //convert to img (to avoid nullpointerexception)
    display = context.depthImage();
   display.loadPixels();
  //loop to select a depthzone
  
    for(int x = 0; x < context.depthWidth(); x++) {
      
      for(int y = 0; y < context.depthHeight(); y++) {
        
        // mirroring image
          int offset =context.depthWidth()-x-1+y*context.depthWidth();
        
        int[] depthValues = context.depthMap();
        int rawDepth = depthValues[offset];

        int pix = x + y *context.depthWidth();
        //only get the pixel corresponding to a certain depth
       int depthmin=600;
       int depthmax=800;
        if (rawDepth <depthmax && rawDepth > depthmin) {
        
          // A red color instead
          display.pixels[pix] = color(255);
        } 
        else {
          display.pixels[pix] = color(0);
        }
      }
      
    }
    display.updatePixels();
    
    background(0);
    //resize and copy to opencv object
   opencv.copy(display,0,0,context.depthWidth(),context.depthHeight(),0,0,screen.width,screen.height);
   image( opencv.image(OpenCV.GRAY), 0, 0 ); 


    // working with blobs
    Blob[] blobs = opencv.blobs( 200, context.depthWidth()*context.depthHeight()/5, 5, false );

    noFill();

    
    for( int i=0; i<blobs.length; i++ ) {

        Rectangle bounding_rect	= blobs[i].rectangle;
        float area = blobs[i].area;
        float circumference = blobs[i].length;
        Point centroid = blobs[i].centroid;
        Point[] points = blobs[i].points;

        // rectangle
        noFill();
        stroke( blobs[i].isHole ? 128 : 64 );
        rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );


        // centroid
        stroke(0,0,255);
        line( centroid.x-5, centroid.y, centroid.x+5, centroid.y );
        line( centroid.x, centroid.y-5, centroid.x, centroid.y+5 );
        noStroke();
        fill(0,0,255);
        text( area,centroid.x+5, centroid.y+5 );


        fill(255,0,255,64);
        stroke(255,0,255);
        if ( points.length>0 ) {
            beginShape();
            for( int j=0; j<points.length; j++ ) {
                vertex( points[j].x, points[j].y );
            }
            endShape(CLOSE);
        }

        noStroke();
        fill(255,0,255);
        text( circumference, centroid.x+5, centroid.y+15 );

    }


}



public void stop() {
    opencv.stop();
    super.stop();
}
