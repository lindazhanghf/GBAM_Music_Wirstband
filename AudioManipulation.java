/*  
    Code based on "State Design Pattern in Java"
    https://sourcemaking.com/design_patterns/state/java/5
*/
import ddf.minim.*;

public class AudioManipulation {

	private Mode[] modes = { new Pan(), new Volume(), new Compression(), new Scratch(), new Pitch(), new Tempo(), new Treble(), new Bass() };
	private int currentMode = -1;
	private int trackIndex = -1;

	public void changeMode(int newMode) {
		currentMode = newMode;
	}

	public void changeTrack(int index) {
		trackIndex = index;
	}

	public boolean execute() {
		return modes[currentMode].execute(); // Return false means its still executing in that state, true means changing mode
	}

	public void play(AudioPlayer audioClip) {
		audioClip.rewind();
		if (!audioClip.isPlaying() )
			audioClip.play();
	}

	public void stop(AudioPlayer audioClip) {
		if (audioClip.isPlaying()) {
			audioClip.pause();
		}
		audioClip.rewind();
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