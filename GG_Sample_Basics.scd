//  3 Apr 2017 18:56

// Find all wav files in this folder on the external usb drive:
~paths = ("/Volumes/GG-BACKUP/FLUTE*".pathMatch.first ++ "*.wav").pathMatch;

// From these, take only the first 10:
~paths10 =~paths [..9];

~paths10.size;  // confirm it is 10 path items!

// Load the files corresponding to these paths into 10 buffers: 
~buffers = ~paths10 collect: { | p | Buffer.read (Server.default, p) };

// This is the first buffer
~buffers.first;

// Play the first buffer
~buffers.first.play;

//: play all 10 buffers together

~buffers do: _.play;

//: play at different times
{
	~buffers do: { | b |
		b.play;
		2.0.rand.wait; // wait random inerval up to 2 seconds before playing next
	}
}.fork;

//: Play in rantom order!
{  // scramble just rearranges the buffer array at random.
	~buffers.scramble do: { | b |
		b.play;
		2.0.rand.wait; // wait random inerval up to 2 seconds before playing next
	}
}.fork;


/*  Next start introducing variations in the way that the buffers are played
For this, we need to create custom buffer-playback SynthDefs.
*/

//: First find out how many channels each buffer has - just to know.

~buffers collect: _.numChannels;
// [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ]
// OK they are all mono. This is good (!)

//: Simple buffer playback synthdef
SynthDef ("bufplay01", { | bufnum = 0, rate = 1, out = 0 |
	var source; // here we put the output signal, for clarity of code
	source = PlayBuf.ar (1, bufnum,
		BufRateScale.kr(bufnum) * rate,
		doneAction: 2
	);
	Out.ar (out, source);
}).add; // load it to all servers immediately
//: test it!
//: Play the first buffer with bufplay01
a = Synth ("bufplay01", [bufnum: ~buffers.first.bufnum]);

//: Play a buffer chosen at random with bufplay01
// note: .choose chooses one of the buffers from the array at random.
a = Synth ("bufplay01", [bufnum: ~buffers.choose.first.bufnum]);

//: Variation: play a sequence of 100 buffers at random
//: starting at 0.1 intervals
{
	100 do: {
		Synth ("bufplay01", [bufnum: ~buffers.choose.first.bufnum]);
		0.1.wait;
	};
}.fork;
//: Now play back at random rates between 0.5 and 2;
{
	100 do: {
		Synth ("bufplay01", [
			bufnum: ~buffers.choose.first.bufnum,
			rate: (0.5 rrand: 2)
		]);
		0.1.wait;
	};
}.fork;
//: Now play back at random rates between 0.5 and 2,
//: and at random between right and left channel.
{
	100 do: {
		Synth ("bufplay01", [
			bufnum: ~buffers.choose.first.bufnum,
			rate: (0.5 rrand: 2),
			out: 2.rand
		]);
		0.1.wait;
	};
}.fork;
//:




