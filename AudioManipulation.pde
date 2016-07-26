/*  
    Code based on "State Design Pattern in Java"
    https://sourcemaking.com/design_patterns/state/java/5
*/
import ddf.minim.*;
// import ddf.minim.spi.*; // for AudioRecordingStream
import ddf.minim.ugens.*;

public class AudioManipulation {

	private Mode[] modes = { new Pan(), new Volume(), new Compression(), new Scratch(), new Pitch(), new Tempo(), new Treble(), new Bass() };
	private int currentMode = -1;
	private char lastGesture = 0;

	public String getCurrentModeName() {
		if (currentMode >= 0) return modes[currentMode].getClass().getName();
		else return "";
	}

	public void changeMode(int newMode) {
		modes[currentMode].onExit();
		modes[newMode].onEnter();
		currentMode = newMode;
	}

	public boolean execute() {
		if (gestureBuffer.length() > 0 && gestureBuffer.charAt(gestureBuffer.length()-1) == FORWARD) {
			gestureBuffer = "";
			if (trackIndex >= 0) {
				if (track[trackIndex].isMuted()) track[trackIndex].unmute();
			}
		}
		else if (gestureBuffer.length() > 0 && gestureBuffer.charAt(gestureBuffer.length()-1) == BACKWARD) {
			gestureBuffer = "";
			if (currentMode >= 0) {
				currentMode = -1;
				return false;
			}
			else {
				if (trackIndex >= 0) {
					if (!track[trackIndex].isMuted()) track[trackIndex].mute();				
				}
			}
		}

		if (currentMode >= 0)
			if (trackIndex >= 0)
				return modes[currentMode].execute(); // Return false means its still executing in that state, true means changing mode
		return false;
	}

	public void play(AudioPlayer audioClip) {
		if(!DJ_MODE) audioClip.rewind();

		if (!audioClip.isPlaying() )
			audioClip.play();
		if (audioClip.isMuted ( ))
			audioClip.unmute();
	}

	public void stop(AudioPlayer audioClip) {
		if (DJ_MODE)
			audioClip.mute();
		else {
			if (audioClip.isPlaying()) {
				audioClip.pause();
			}
			audioClip.rewind();
		}
	}
}

abstract class Mode {
	public void onEnter(){};

	public void onExit(){};

	public boolean execute() { 
		System.out.println(audioEngine.getCurrentModeName() + " not implemented" );
		return false;
	}
}

class Pan extends Mode {
	public boolean execute() { 
		track[trackIndex].setPan((float)mapRange(x, -3000, 3000, -1, 1));           
		return false;
	}
}

class Volume extends Mode {
	public boolean execute() { 
		track[trackIndex].setGain((float)mapRange(-z, -3000, 3000, -25, 5));
		return false;
	}
}

class Compression extends Mode {
	public boolean execute() { 
		return false;
	}
}

class Scratch extends Mode {
	public boolean execute() {
		if (Math.abs(x) < 600) return false; // noise
		int scratchAmount = (int) Math.abs(x)/10;
		if (x > 0) // scratch forward
		{ 
			// get the current position of the baseSong
			int pos = track[trackIndex].position();
			// if the baseSong's position is more than 40 milliseconds from the end of the baseSong
			if ( pos < track[trackIndex].length() - 40 )
			{
			// forward the baseSong by 40 milliseconds
				track[trackIndex].skip(40);
			}
			else
			{
			// otherwise, cue the baseSong at the end of the baseSong
				track[trackIndex].cue( track[trackIndex].length() );
			}
			// start the baseSong playing
			track[trackIndex].play();
		}
		else //scratch backward (rewind)
		{
			// get the current baseSong position
			int pos = track[trackIndex].position();
			// if it greater than scratchAmount milliseconds
			if ( pos > scratchAmount )
			{
			// rewind the baseSong by scratchAmount milliseconds
				track[trackIndex].skip(-scratchAmount);
			}
			else
			{
			// if the baseSong hasn't played more than 100 milliseconds
			// just rewind to the beginning
				track[trackIndex].rewind();
			}
		}
		return false;
	}
}

class Pitch extends Mode {
	public boolean execute() { 
		return false;
	}
}

class Tempo extends Mode {
	// private TickRate rateControl = new TickRate(1.f);
	// private AudioOutput out = minim.getLineOut();

	// public void onEnter() {
	// 	track[trackIndex].patch(rateControl).patch(out);
	// 	rateControl.setInterpolation( true );		
	// }

	// public boolean execute() {
	// 	float rate =  map(x, -3000, 3000, 0.0f, 3.f);
	// 	rateControl.value.setLastValue(rate);
	// 	return false;
	// }
}

class Treble extends Mode {
	public boolean execute() { 
		return false;
	}
}

class Bass extends Mode {
	public boolean execute() { 
		return false;
	}
}