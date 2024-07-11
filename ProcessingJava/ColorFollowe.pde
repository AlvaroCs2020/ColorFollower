import processing.video.*; //<>// //<>//
import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import processing.serial.*;
import java.lang.Math;
boolean ir = false;
boolean colorDepth = false;
Kinect tmpKinect;
int numDevices = 0;
color trackColor = color(0);
//index to change the current device changes
int deviceIndex = 0;

float deg = 35;
// The serial port:
Serial myPort;       

//Detecting movement
static IntList pixelsX;
static IntList pixelsY;
int pixelsThreshold = 4;

//Calculating movement

PVector vStart;
PVector vEnd;

void setup() {
    size(1280, 1000);

    //get the actual number of devices before creating them
    numDevices = Kinect.countDevices();
    println("number of Kinect v1 devices  " + numDevices);

    //creat the arraylist
    //iterate though all the devices and activate them
    tmpKinect = new Kinect(this);
    tmpKinect.activateDevice(0);
    tmpKinect.initDepth();
    tmpKinect.initVideo();
    tmpKinect.enableColorDepth(colorDepth);
    printArray(Serial.list());
    myPort = new Serial(this, Serial.list()[1],115200);
    pixelsX = new IntList();
    pixelsY = new IntList();
}

    String s = "";
    String distance = "";
    String commandSent = "";
void draw() {
    background(0);
  // List all the available serial ports:

  
    //iterat though the array of kinects
    PImage video = tmpKinect.getVideoImage();
    int[] rawDepth = tmpKinect.getRawDepth();
    //make the kinects capture smaller to fit the window
    image(video, 0, 0, video.width, video.height);
    //image(tmpKinect.getVideoImage(), 0, 0, 320, 240);
    image(tmpKinect.getDepthImage(), video.width, video.height, video.width, video.height);
    float avgX = 0;
    float avgY = 0;

    int count = 0;
    if (trackColor != color(0)) {
        PImage filteredVideo = video.copy();

        for (int x = 0; x < video.width; x++) {
            for (int y = 0; y < video.height; y++) {
                int loc = x + y * video.width;
                // What is current color
                color currentColor = video.pixels[loc];
                float r1 = red(currentColor);
                float g1 = green(currentColor);
                float b1 = blue(currentColor);
                float r2 = red(trackColor);
                float g2 = green(trackColor);
                float b2 = blue(trackColor);

                float d = distSq(r1, g1, b1, r2, g2, b2);
                if (d < deg * deg) {
                    filteredVideo.set(x, y, color(255));
                    avgX += x;
                    avgY += y;
                    count++;
                } else {
                    filteredVideo.set(x, y, color(0));
                }
            }
        }
        image(filteredVideo, 0, filteredVideo.height, filteredVideo.width, filteredVideo.height);
    }

    if (count > 0) {
        avgX = avgX / count;
        avgY = avgY / count;
        // Draw a circle at the tracked pixel
        fill(255);
        //strokeWeight(4.0);
        //stroke(0);
        ellipse(avgX, avgY, 24, 24);
        
        pixelsX.append((int) avgX);
        pixelsY.append((int) avgY);
        
    }
    int i = (int) avgX + (int)avgY * video.width;
    
    text(rawDepth[i],avgX-15, avgY-15f);

    fill(255);
    text("Device Count: " + numDevices + "  \n" +
        "Current Index: " + deviceIndex, 660, 50, 150, 50);
    
    text(
        "Press 'i' to enable/disable between video image and IR image  \n" +
        "Press 'c' to enable/disable between color depth and gray scale depth \n" +
        "Press 'n' to trigger test function \n" +
        "UP and DOWN to tilt camera : " + deg + "  \n" +
        "Framerate: " + int(frameRate), 660, 100, 280, 250);
    fill(trackColor);
    rect(640, 240, 80, 80);
    
    //Hardware and serial stuff
    
    int degreesX = (int) map(avgX, 0, video.width, 120, 55);

    int degreesY = (int) map(avgY, 0, video.height, 90, 40);
    
    if(pixelsX.size() >= 10 && pixelsY.size() == pixelsX.size() )
    {
      int _x = pixelsX.toArray()[pixelsX.size()-1] - pixelsX.toArray()[0];
      int _y = pixelsY.toArray()[pixelsY.size()-1] - pixelsY.toArray()[0];
      //commandSent = String.format("+7;%s-",str(degreesY));
      //myPort.write(commandSent);
      commandSent = String.format("{%s;%s;%s}",str((int)avgX),str((int)avgY),str(1));
      myPort.write(commandSent);
      

      
      

        // Scale the mouseX value from 0 to 640 to a range between 0 and 175
      
      //commandSent = String.format("+6;%x-",degrees);
      //myPort.write(commandSent);

      /*
      //X movement
      if(_x > pixelsThreshold)
      {
         s = "Derecha";
         myPort.write(String.format("+2;%x-",(int) Math.abs(_x/4)));
      }
      else if(_x < -pixelsThreshold)
      {
        s = "Izquierda";
       
        myPort.write(String.format("+1;%x-",(int) Math.abs(_x/4)));
      }
      else
      {
        s = "";
      } 
      //Y movement
      if(_y > pixelsThreshold)
      {
         myPort.write(String.format("+4;%x-",(int) Math.abs(_y/4.5)));
      }
      else if(_y < -pixelsThreshold)
      {
        myPort.write(String.format("+3;%x-",(int) Math.abs(_y/4.5)));
      }
      */
      pixelsX.clear();  
      pixelsY.clear(); 
  }

      println((int) avgX + " : " + (int)avgY+" --- " + commandSent);
      //println(video.height + " ss " + video.width);
        fill(color(255));

      text("Valor x" + str((int)avgX) + " Grados: " + str(degreesY) + "command sent: " + commandSent, 660, 220, 280, 250);
  fill(color(255));
      text(
    "Sentido " + s + " ; " + distance, 660, 320, 280, 250);
    
    
}
void trackColor() {
    myPort.write("+5;0-");
    
    distance = myPort.readString();
}
void keyPressed() {
    if (key == '-') {
        if (deviceIndex > 0 && numDevices > 0) {
            deviceIndex--;
            //deg = tmpKinect.getTilt();
        }
    }

    if (key == '+') {
        if (deviceIndex < numDevices - 1) {
            deviceIndex++;
            //deg = tmpKinect.getTilt();
        }
    }


    if (key == 'i') {
        ir = !ir;
        tmpKinect.enableIR(ir);
    } else if (key == 'c') {
        colorDepth = !colorDepth;
        tmpKinect.enableColorDepth(colorDepth);
    } else if (key == 'n') {
        trackColor();
    } else if (key == CODED) {
        if (keyCode == UP) {
            deg++;
        } else if (keyCode == DOWN) {
            deg--;
        }
        //deg = constrain(deg, 0, 30);
        tmpKinect.setTilt(deg);
    }
}
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
    float d = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1);
    return d;
}
void mousePressed() {
    int loc = mouseX + mouseY * tmpKinect.getVideoImage().width;
    /*
    int depth = tmpKinect.getRawDepth()[loc];
    if(vStart == null)
    {
      vStart = new PVector(mouseX, mouseY, depth);
    }
    else if(vEnd == null)
    {
      vEnd = new PVector(mouseX, mouseY, depth);
    }
    else
    {
      distance = str(PVector.dist(vEnd, vStart));
      vEnd = null;
      vStart = null;
    }
    */
    // Save color where the mouse is clicked in trackColor variable
    
    
    trackColor = tmpKinect.getVideoImage().pixels[loc];
}
