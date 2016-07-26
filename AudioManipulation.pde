/*  
    Code based on "State Design Pattern in Java"
    https://sourcemaking.com/design_patterns/state/java/5
*/
import ddf.minim.*;

public class AudioManipulation {

	private Mode[] modes = { new Pan(), new Volume(), new Compression(), new Scratch(), new Pitch(), new Tempo(), new Treble(), new Bass() };
	private int currentMode = -1;
	private int trackIndex = -1;

	public String getCurrentModeName() {
		if (currentMode >= 0)
			return modes[currentMode].getClass().getName();
		else {
			return "";
		}
	}

	public int getTrackIndex() {
		return trackIndex;
	}

	public void changeMode(int newMode) {
		currentMode = newMode;
	}

	public void changeTrack(int index) {
		// if (trackIndex >= 0)
		// 	stop(track[trackIndex]);
		trackIndex = index;
		// play(track[trackIndex]);
	}

	public boolean execute() {
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

	public void Reverb(AudioPlayer audioClip) {
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
		print(x+y+z);
		return false;
	}
}

class Volume extends Mode {
	public boolean execute() { 
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