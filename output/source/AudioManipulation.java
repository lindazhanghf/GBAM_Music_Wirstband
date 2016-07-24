import ddf.minim.*;

public class AudioManipulation {

	public static void play(AudioPlayer audioClip) {
		audioClip.rewind();
		if (!audioClip.isPlaying() )
			audioClip.play();
	}

	public static void stop(AudioPlayer audioClip) {
		if (audioClip.isPlaying()) {
			audioClip.pause();
		}
		audioClip.rewind();
	}
}