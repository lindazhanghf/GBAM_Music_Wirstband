import processing.serial.*;
import processing.opengl.*;
import java.util.Scanner;
import java.lang.String;
import ddf.minim.*;

/* MODE */
static final boolean DJ_MODE = true;

/* Macros */
static final int NUM_SAMPLE = 300;
static final int IDLE_STATE = 0;
static final int SPRINT_STATE = 1;
static final int SPRINT_BOUND = 8000;
static final int TEXT_ROW = 80;

static final char LEFT      = 'L';
static final char RIGHT     = 'R';
static final char FORWARD   = 'F';
static final char BACKWARD  = 'B';
static final char UP        = 'U';
static final char DOWN      = 'D';

/* Raw Data */
public long x;
public long y;
public long z;     // Sometimes affected by gravity
public double gyroX;
public double gyroY;
public double gyroZ;
public double combinedR;
public double absAverage;
public long absSum;
public int absMax;
public int absX;
public int absY;
public int absZ;

/* Serial port and Initialization */
Serial port;
int interval = 0;
int time = 0;
int seconds = 0;
int oldSeconds = 0;
String acceBuffer;
String gyroBuffer;
boolean isAcce;

/* Initilization stuff */
boolean initializing;

/* State Machine */
public StateMachine stateMachine = new StateMachine();
public String  gestureBuffer = "";
public char currentGesture = 0;
public char oldGesture = 0;

/* Audio Library */
public Minim minim;
public AudioPlayer baseSong;
public AudioPlayer yPositive;
public AudioPlayer xPositive;
public AudioPlayer zPositive;
public AudioPlayer track1;
public String songName = "HELLO+VENUS+-+Wiggle+Wiggle+-+mirrored+dance+practice+video.mp3";

void setup() {
    size(800, 500, OPENGL);
    textSize(16);
    //Serial Port initilizing
    initializing = true;
    println(Serial.list());
    // println("\nINITIALIZING...\nPlease wait for about 30 seconds");
    port = new Serial(this, "/dev/ttyUSB0", 115200);
    port.write('r');
    seconds = second();

    //Minim initilizing
    minim = new Minim(this);
    baseSong = minim.loadFile("./audio/" + songName);
    baseSong.setGain(-13);
    xPositive = minim.loadFile("./audio/213507__goup-1__kick.wav");
    yPositive = minim.loadFile("./audio/347625__notembug__deep-house-kick-drum-3.wav");
    zPositive = minim.loadFile("./audio/25666__walter-odington__deep-short-one-snare.wav");
    zPositive.setGain(0);
    track1 = minim.loadFile("./audio/track1.wav");
}

public void initializePort() {
    port = new Serial(this, "/dev/ttyUSB0", 115200);
    port.write('r');    
}

void draw() {
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
    if (stateMachine.execute() == true)
    {
      int nextState = stateMachine.onExit();
      stateMachine.changeState(nextState);
    }
    track1.setGain((float)mapRange(absSum, 1000, 22000, -20, 0));


    /* Display numbers on screen */
    if (baseSong.isPlaying()) text("Playing: " + songName, 10, 20);

    text("x:" + formatNumber(x) + " y:" + formatNumber(y) + " z:" + formatNumber(z), 10, 40);
    text("Sum: "+absSum, 300, 40);
    text("gyro-x:" + gyroX, 10, 60);
    text(" y:" + gyroY, 140, 60);
    text(" z:" + gyroZ, 250, 60);
    text("Beat x", 10, TEXT_ROW);
    text("Beat y", 10, TEXT_ROW + 20);
    text("Beat z", 10, TEXT_ROW + 40);
    text("Gestures: " + gestureBuffer, 10 ,TEXT_ROW + 60);

    if (xPositive.isPlaying()) text("!!!", 80, TEXT_ROW);

    if (yPositive.isPlaying()) text("!!!", 80, TEXT_ROW+20);

    if (zPositive.isPlaying()) text("!!!", 80, TEXT_ROW + 40);
}

double mapRange(double x, int in_min, int in_max, int out_min, int out_max)
{
 return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

void serialEvent(Serial port)
{
    interval = millis();
    if (port.available() > 0) {
        int input = port.read();
        if (parseData(input))    //finish parsing data
        {
            /* Update all data once received new x,y,z data */
            // R^2 = Rx^2 + Ry^2 + Rz^2 
            combinedR = Math.sqrt(Math.pow(x,2)+Math.pow(y,2)+Math.pow(z,2));
            absSum = Math.abs(x) + Math.abs(y) + Math.abs(z);
            absAverage = absSum/3.0;
            absMax = (int) Math.max(Math.abs(x),  Math.max(Math.abs(y), Math.abs(z)));
            absX = (int) Math.abs(x);
            absY = (int) Math.abs(y);
            absZ = (int) Math.abs(z);
       }
    }
    else initializePort();
}

boolean parseData(int data)
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
        if (Math.abs(x) + Math.abs(y) < 2000)
        {
            baseSong.play();
            baseSong.loop(10);
            track1.play();
            track1.loop();
            stateMachine.changeState(IDLE_STATE);
            initializing = false;
            println ("DONE INITIALIZING !!!!!!!!!!!!!!");
        }
        print("x:" + formatNumber(x) + "  y:"+formatNumber(y) + "  z:"+formatNumber(z)); //print out data!
        println("  GYRO  x: " + String.valueOf(gyroX) + "\ty: " + String.valueOf(gyroY) + "\tz: " + String.valueOf(gyroZ));
    }

    // println("x: "+x+"\t\ty: "+y+"\t\tz: "+z);
    // print("x:" + formatNumber(x) + "  y:"+formatNumber(y) + "  z:"+formatNumber(z)); //print out data!
    // println("  GYRO  x: " + String.valueOf(gyroX) + "\ty: " + String.valueOf(gyroY) + "\tz: " + String.valueOf(gyroZ));
    // println("  Gyro - x:" + formatNumber(gyroX) + "  y:"+formatNumber(gyroY) + "  z:"+formatNumber(gyroZ)); //print out data!
    return true;
}

String formatNumber(long number)
{
    if (number != 0)
    {
        String newString = "      " + String.valueOf(number);
        return newString.substring(newString.length() - 7);
    }
    else
        return "       ";
}