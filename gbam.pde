import processing.serial.*;
import processing.opengl.*;
import java.util.Scanner;
import java.lang.String;
import ddf.minim.*;

/* MODE */
static final boolean DJ_MODE = true; // DJ vs. Dance

/* Macros */
static final int NUM_SAMPLE = 300;
static final int IDLE_STATE = 0;
static final int SPRINT_STATE = 1;
static final int SPRINT_BOUND = 8000;
static final int TEXT_ROW = 80;

/* Movement */
static final char LEFT      = 'L';
static final char RIGHT     = 'R';
static final char FORWARD   = 'F';
static final char BACKWARD  = 'B';
static final char UP        = 'U';
static final char DOWN      = 'D';

/* Gestures */
static final String TRACK_1 = "RDD";
static final String TRACK_2 = "RDR";
static final String TRACK_3 = "RDL";
static final String TRACK_4 = "DRU";
static final String PAN = "ULU";
static final String VOL = "URD";
static final String COMPRESS = "LUR";
static final String SCRATCH = "LDR";
static final String PITCH = "LUL";
static final String TEMPO = "LLU";
static final String TREB = "LDL";
static final String BASS = "RUR";

/* Mode index */
static final int MODE_PAN = 0;
static final int MODE_VOL = 1;
static final int MODE_COMPRESS = 2;
static final int MODE_SCRATCH = 3;
static final int MODE_PITCH = 4;
static final int MODE_TEMPO = 5;
static final int MODE_TREB = 6;
static final int MODE_BASS = 7;


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
public AudioManipulation audioEngine;
public StateMachine stateMachine = new StateMachine();
public String  gestureBuffer = "";
public char currentGesture = 0;
public char oldGesture = 0;
public boolean reversed = false;
public String matchResult = "";

/* Audio Library */
public Minim minim;
public AudioPlayer baseSong;
public AudioPlayer yPositive;
public AudioPlayer xPositive;
public AudioPlayer zPositive;
public AudioPlayer track1;
public AudioPlayer[] track = new AudioPlayer[4];
public String songName = "HELLO+VENUS+-+Wiggle+Wiggle+-+mirrored+dance+practice+video.mp3";

void setup() {
    size(800, 500, OPENGL);
    textSize(16);
    //Serial Port initilizing
    initializing = true;
    println(Serial.list());
    initializePort();
    seconds = second();

    //Minim initilizing
    minim = new Minim(this);
    if (DJ_MODE) setupDJ();
    else setupDance();

    setupDance(); //TODO delete after split mode in state machine
}

void setupDJ() {
    baseSong = minim.loadFile("./audio/" + songName);
    baseSong.setGain(-13);
    track[0] = minim.loadFile("./audio/tracks/115360__ac-verbeck__arp-03.wav");
    track[1] = minim.loadFile("./audio/tracks/4Minute-Hate.wav");
    track[2] = minim.loadFile("./audio/tracks/BTS-Dope.wav");
    track[3] = minim.loadFile("./audio/tracks/MBLAQ-Smoky-Girl.wav");
}

void setupDance() {
    baseSong = minim.loadFile("./audio/" + songName);
    baseSong.setGain(-13);
    xPositive = minim.loadFile("./audio/213507__goup-1__kick.wav");
    yPositive = minim.loadFile("./audio/347625__notembug__deep-house-kick-drum-3.wav");
    zPositive = minim.loadFile("./audio/25666__walter-odington__deep-short-one-snare.wav");
    zPositive.setGain(0);
    track1 = minim.loadFile("./audio/fx-4-Walls-inst.mp3");    
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
        }
        text(time + " second", 10, 40);
        fill(0,0,0);
        return;
    }

    /* Main Execution */
    if (stateMachine.execute() == true)
    {
      int nextState = stateMachine.onExit();
      stateMachine.changeState(nextState);
    }

    audioEngine.execute();

    if (!DJ_MODE) track1.setGain((float)mapRange(absSum, 1000, 22000, -20, 0));

    /* Display numbers on screen */
    if (baseSong.isPlaying()) text("Playing: " + songName, 10, 20);
    text("x:" + formatNumber(x) + " y:" + formatNumber(y) + " z:" + formatNumber(z), 10, 40);
    text("Sum: "+absSum, 300, 40);
    text("gyro-x:" + gyroX, 10, 60);
    text(" y:" + gyroY, 140, 60);
    text(" z:" + gyroZ, 250, 60);

    if (DJ_MODE) drawDJ();
    else drawDance();
}

void drawDJ() {
    text("Gestures: " + gestureBuffer, 10 ,TEXT_ROW + 60);
    if (gestureBuffer.length() >= 3) {
        matchResult = matchGesture(gestureBuffer.substring(gestureBuffer.length() - 3));
        if( matchResult != "") gestureBuffer = "";
    }
    text("Track " + audioEngine.getTrackIndex()+1, 10, TEXT_ROW);
    text("Mode " + audioEngine.getCurrentModeName(), 10, TEXT_ROW + 20);
    // text("Beat z", 10, TEXT_ROW + 40);

    text("GESTURE MATCH: " + matchResult, 10, TEXT_ROW + 80);
}

void drawDance() {
    text("Beat x", 10, TEXT_ROW);
    text("Beat y", 10, TEXT_ROW + 20);
    text("Beat z", 10, TEXT_ROW + 40);
    if (xPositive.isPlaying()) text("!!!", 80, TEXT_ROW);
    if (yPositive.isPlaying()) text("!!!", 80, TEXT_ROW+20);
    if (zPositive.isPlaying()) text("!!!", 80, TEXT_ROW + 40);    
}

String matchGesture(String gesture) {
    if  (gesture.compareTo(TRACK_1) == 0){
        audioEngine.changeTrack(0);
        return TRACK_1;
    }
    else if (gesture.compareTo(TRACK_2) == 0) {
        audioEngine.changeTrack(1);
        return TRACK_2;
    }
    else if (gesture.compareTo(TRACK_3) == 0) {
        audioEngine.changeTrack(2);
        return TRACK_3;
    }
    else if (gesture.compareTo(TRACK_4) == 0) {
        audioEngine.changeTrack(3);
        return TRACK_4;
    }
    else if (gesture.compareTo(PAN) == 0) {
        audioEngine.changeMode(MODE_PAN);
        return PAN;
    }
    else if (gesture.compareTo(VOL) == 0) {
        audioEngine.changeMode(MODE_VOL);
        return VOL;
    }
    else if (gesture.compareTo(COMPRESS) == 0) {
        audioEngine.changeMode(MODE_COMPRESS);
        return COMPRESS;
    }
    else if (gesture.compareTo(SCRATCH) == 0) {
        audioEngine.changeMode(MODE_SCRATCH);
        return SCRATCH;
    }
    else if (gesture.compareTo(PITCH) == 0) {
        audioEngine.changeMode(MODE_PITCH);
        return PITCH;
    }
    else if (gesture.compareTo(TEMPO) == 0) {
        audioEngine.changeMode(MODE_TEMPO);
        return TEMPO;
    }    else if (gesture.compareTo(TREB) == 0) {
        audioEngine.changeMode(MODE_TREB);
        return TREB;
    }    else if (gesture.compareTo(BASS) == 0) {
        audioEngine.changeMode(MODE_BASS);
        return BASS;
    }
    else return "";
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

void initializeAudio() {
    baseSong.play();
    baseSong.loop(10);
    audioEngine = new AudioManipulation(DJ_MODE, track);
    // if (DJ_MODE) {
    //     for (int i = 0; i < track.length; i++) {
    //         track[i].play();
    //         track[i].loop();
    //         track[i].mute();
    //     }
    // }
    // else {
    //     track1.play();
    //     track1.loop();
    // }
    stateMachine.changeState(IDLE_STATE);

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
            initializeAudio();
            initializing = false;
            println ("DONE INITIALIZING !!!!!!!!!!!!!!");
        }
        print("x:" + formatNumber(x) + "  y:"+formatNumber(y) + "  z:"+formatNumber(z)); //print out data!
        println("  GYRO  x: " + String.valueOf(gyroX) + "\ty: " + String.valueOf(gyroY) + "\tz: " + String.valueOf(gyroZ));
    }

    /* Printing data in console */
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