import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import processing.opengl.*; 
import java.util.Scanner; 
import java.lang.String; 
import ddf.minim.*; 
import java.lang.String; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class gbam extends PApplet {







/* Macros */
static final int NUM_SAMPLE = 300;
static final int IDLE_STATE = 0;
static final int SPRINT_STATE = 1;
static final int SPRINT_BOUND = 10000;

/* Raw Data */
public int x;
public int y;
public int z;     // Sometimes affected by gravity
public double gyroX;
public double gyroY;
public double gyroZ;
public double combinedR;
public double absAverage;
public int absMax;
public int absX;
public int absY;
public int absZ;

/* Serial port and Initialization */
Serial port;
int interval = 0;
// int synced = 0;
// float[] q = new float[4];
// Quaternion quat = new Quaternion(1, 0, 0, 0);
// float[] gravity = new float[3];
// float[] euler = new float[3];
// float[] ypr = new float[3];
int time = 0;
int seconds = 0;
int oldSeconds = 0;
String acceBuffer;
String gyroBuffer;
boolean isAcce;

/* Initilization stuff */
boolean initializing;
int numSamples = 0;
int sumZ = 0;
int averageGravity = 0;

/* State Machine */
public StateMachine stateMachine = new StateMachine();

/* Audio Library */
public Minim minim;
public AudioPlayer baseSong;
public AudioPlayer yPositive;
public AudioPlayer xPositive;
public AudioPlayer zPositive;
public String songName = "328366__frankum__electronic-dance-loop-02.mp3";

public void setup() {
    size(500, 500, OPENGL);
    textSize(20);
    //Serial Port initilizing
    initializing = true;
    // println(Serial.list());
    println("\nINITIALIZING...\nPlease wait for about 30 seconds");
    port = new Serial(this, "/dev/ttyUSB1", 115200);
    port.write('r');
    seconds = second();

    //Minim initilizing
    minim = new Minim(this);
    baseSong = minim.loadFile("./audio/" + songName);
    xPositive = minim.loadFile("./audio/213507__goup-1__kick.wav");
    yPositive = minim.loadFile("./audio/347625__notembug__deep-house-kick-drum-3.wav");
    zPositive = minim.loadFile("./audio/25666__walter-odington__deep-short-one-snare.wav");
}

public void initializePort() {
    port = new Serial(this, "/dev/ttyUSB1", 115200);
    port.write('r');    
}

public void draw() {
    background(255);
    if (millis() - interval > 1000) {
        // resend single character to trigger DMP init/start
        // in case the MPU is halted/reset while applet is running
        port.write('r');
        interval = millis();
    }
    if (initializing)
    {
        text("INITIALIZING... Please wait for about 30 seconds", 10, 20);
        fill(0,0,0);
        seconds = second();
        if (seconds != oldSeconds)
        {
          oldSeconds = seconds;
          time++;
          print(time + " ");
          text(String.valueOf(time) + " second", 10, 40);
          fill(0,0,0);
        }
        text(String.valueOf(time) + " second", 10, 40);
        fill(0,0,0);
        return;
    }

    /* Main Execution */
    if (baseSong.isPlaying()) text("Playing: " + songName, 10, 20);

    if (stateMachine.execute() == true)
    {
      int nextState = stateMachine.onExit();
      stateMachine.changeState(nextState);
    }

    try {
        serialEvent(port);
    }
    catch (java.lang.RuntimeException e) {
        println(e);
        initializePort();
    }

}

public void serialEvent(Serial port)
{
    interval = millis();
    if (port.available() > 0) {
        int input = port.read();
        if (parseData(input))    //finish parsing data
        {
            /* Update all data once received new x,y,z data */
            // R^2 = Rx^2 + Ry^2 + Rz^2 
            combinedR = Math.sqrt(Math.pow(x,2)+Math.pow(y,2)+Math.pow(z,2));
            absAverage = (Math.abs(x) + Math.abs(y) + Math.abs(z))/3;
            absMax = (int) Math.max(Math.abs(x),  Math.max(Math.abs(y), Math.abs(z)));
            absX =  Math.abs(x);
            absY =  Math.abs(y);
            absZ = Math.abs(z);
       }
    }
    else initializePort();
}

public boolean parseData(int data)
{
    // print ((char)data);
    switch (data)
    {
        case '^':         // Mark the start of gyroscope data
            isAcce = false;
            gyroBuffer = "";
            return false;
        case '&':
            Scanner g = new Scanner(gyroBuffer).useDelimiter("\t");
            gyroX = g.nextDouble();
            gyroY = g.nextDouble();
            gyroZ = g.nextDouble();
            g.close();
            return false;            
        case '#':         // Mark the start of acceleration data
            isAcce = true;
            acceBuffer = "";
            return false;
        case '$':         // Mark the end of acceleration data
            Scanner s = new Scanner(acceBuffer).useDelimiter("\t");
            x = s.nextInt();
            y = s.nextInt();
            z = s.nextInt();
            s.close();
            break;
        default :
            if (isAcce) acceBuffer += (char)data;
            else gyroBuffer += (char)data;
            return false;
    }
    if (initializing) //initializing process
    {
        if (Math.abs(x) + Math.abs(y) < 200)
        {
            // if (numSamples < NUM_SAMPLE)
            // {
            //     sumZ += z;
            //     numSamples++;
            //     if (numSamples == NUM_SAMPLE)
            //     {
            //         averageGravity = sumZ / NUM_SAMPLE;
                    baseSong.play();
                    baseSong.loop(10);
                    initializing = false;
                    println ("DONE INITIALIZING !!!!!!!!!!!!!!");
                    stateMachine.changeState(IDLE_STATE);
            //     }
            // }
        }
    }

    // println("x: "+x+"\t\ty: "+y+"\t\tz: "+z);
    print("x:" + formatNumber(x) + "  y:"+formatNumber(y) + "  z:"+formatNumber(z)); //print out data!
    println("  GYRO  x: " + String.valueOf(gyroX) + "\ty: " + String.valueOf(gyroY) + "\tz: " + String.valueOf(gyroZ));
    // println("  Gyro - x:" + formatNumber(gyroX) + "  y:"+formatNumber(gyroY) + "  z:"+formatNumber(gyroZ)); //print out data!
    return true;
}

public String formatNumber(long number)
{
    if (number != 0)
    {
        String newString = "      " + String.valueOf(number);
        return newString.substring(newString.length() - 7);
    }
    else
        return "       ";
}
/*  
    Code based on "State Design Pattern in Java"
    https://sourcemaking.com/design_patterns/state/java/5
*/


public class StateMachine {
  private State[] states     = { new Idle(), new Sprint() }; // 2. states , new C()
  private int     current    = 0;                             // 3. current State

  // 5. All client requests are simply delegated to the current state object
  public void onEnter(int oldState) { 
    states[current].onEnter(oldState);   
  }
  public int onExit() { 
    return states[current].onExit();  
  }
  public boolean execute() { 
    return states[current].execute();  
  }

  public void changeState(int newState)
  {
    states[newState].onEnter(current);
    current = newState;
  }
}

// 6. Create a state base class that makes the concrete states interchangeable
 abstract class State {
   public void onEnter(int oldState) { 
     System.out.println( "error" );
   }  // 7. The State base 
   public int onExit() { 
     System.out.println( "error" );
     return 0;
   }  //    class specifies 
   public boolean execute() { 
     System.out.println( "error" );
     return false;
   }  //    default behavior
 }

 class Idle extends State {
   private int nextState;
   public void onEnter(int oldState) { 
     System.out.println( "IDLE + onEnter" );
   }
   public int onExit() { 
     System.out.println( "IDLE + onExit" );
     return nextState;
   }
   public boolean execute() { 
     // R^2 = Rx^2 + Ry^2 + Rz^2 
     println ("                                                                                     vectorR = " + combinedR + "\tabsAverage     = " + absAverage);
     if (combinedR >= SPRINT_BOUND)
     {
       nextState = SPRINT_STATE;
       return true;
     }
     return false;
   }
 }

 class Sprint extends State {
   private int nextState;

   public void onEnter(int oldState) { 
     System.out.println( "Sprint + onEnter" );
     if (oldState == IDLE_STATE)
     {
      if (absMax == absX)
      {
        if (x >= 0) AudioManipulation.play(xPositive);
        text("Beat1", 10, 40);
      }
      else if (absMax == absY)
      {
        if (y >= 0) AudioManipulation.play(yPositive);
        text("Beat2", 10, 60);
      }
      else
      {
        if (z >= 0) AudioManipulation.play(zPositive);
        text("Beat3", 10, 80);
        println("else");
      }
    }
   }

   public int onExit() { 
     System.out.println( "Sprint + onExit" );
     return nextState;
   }

   public boolean execute() { 
     // println ("Sprint: vectorR = " + combinedR + "\tabsAverage     = " + absAverage);
     if (combinedR < SPRINT_BOUND)
     {
      // AudioManipulation.stop(kick);
      // AudioManipulation.stop(kick1);
      nextState = IDLE_STATE;
      return true;
     }
     return false;
   }

 }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "gbam" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
