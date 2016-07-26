/*  
    Code based on "State Design Pattern in Java"
    https://sourcemaking.com/design_patterns/state/java/5
*/
import ddf.minim.*;

public class AudioManipulation {

	private Mode[] modes = { new Pan(), new Volume(), new Compression(), new Scratch(), new Pitch(), new Tempo(), new Treble(), new Bass() };
	private int currentMode = -1;
	private char lastGesture = 0;

	public String getCurrentModeName() {
		if (currentMode >= 0) return modes[currentMode].getClass().getName();
		else return "";
	}

	public void changeMode(int newMode) {
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
	public boolean execute() { 
		System.out.println( "error" );
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
		return false;
	}
}

class Pitch extends Mode {
	public boolean execute() { 
		return false;
	}
}

class Tempo extends Mode {
	public boolean execute() { 
		return false;
	}
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