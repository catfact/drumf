Engine_Drumf : CroneEngine {

	classvar <numVoices = 4;

	var <trig_bus;
	var <drum_synth;

	var <drum_def;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {

		var synth_param_names;
		var s = context.server;

		Routine {
			// make a synthdef
			drum_def = SynthDef.new(\better_drumf, {

				arg out=0, trig_bus, amp=0.25,

				pitch_base=55,
				fm_ratio=2.0, fm_mod=2.0, noise_rate=10000,
				noise_shape=0,

				osc_level = 1.0,
				noise_level = 1.0,

				noise_amp_env_atk=0.01,
				noise_amp_env_sus=0.1,
				noise_amp_env_rel=0.2,

				osc_amp_env_atk=0.01,
				osc_amp_env_sus=0.1,
				osc_amp_env_rel=0.2,

				pitch_env_atk=0.01,
				pitch_env_sus=0.0,
				pitch_env_rel=0.3,
				pitch_env_ratio=2,

				fc_env_atk=0.01,
				fc_env_sus=0.0,
				fc_env_rel=0.3,
				fc_env_ratio=2,
				fc_base = 1000,

				filter_gain=1;

				/*
				gain_env_atk=0.01,
				gain_env_sus=0.0,
				gain_env_rel=0.3;*/


				var gate, snd, osc, noise,
				noise_amp, osc_amp, pitch,
				noise_amp_env, osc_amp_env, pitch_env, fc_env, fc;

				gate = InTrig.kr(trig_bus);

				noise_amp_env = Env.linen(noise_amp_env_atk, noise_amp_env_sus, noise_amp_env_rel);
				osc_amp_env = Env.linen(osc_amp_env_atk, osc_amp_env_sus, osc_amp_env_rel);
				pitch_env = Env.linen(pitch_env_atk, pitch_env_sus, pitch_env_rel);
				fc_env = Env.linen(fc_env_atk, fc_env_sus, fc_env_rel);

				pitch = pitch_base * (1.0 +  (pitch_env_ratio * EnvGen.ar(pitch_env, gate)));
				noise_amp = EnvGen.ar(noise_amp_env, gate);
				osc_amp = EnvGen.ar(osc_amp_env, gate);
				fc = fc_base * (1.0 + (fc_env_ratio * EnvGen.ar(fc_env, gate)));

				osc = SinOsc.ar(pitch, SinOsc.ar(pitch * fm_ratio) * fm_mod).distort;
				osc = osc * osc_amp * osc_level;
				noise = SelectX.ar(noise_shape, [
					LFNoise0.ar(noise_rate),
					LFNoise1.ar(noise_rate),
					LFNoise2.ar(noise_rate)
				]);

				noise = noise * noise_amp * noise_level;

				snd = osc + noise;

				snd = MoogFF.ar(snd, fc, filter_gain);

				Out.ar(out, snd*amp);
			}).send(s);

			// send to the server
			drum_def.send(s);

			// make a control bus for triggers
			trig_bus = Array.fill(numVoices, {
				Bus.control(s)
			});

			s.sync;

			// make a synth lookin at the bus
			drum_synth = Array.fill(numVoices, {
				arg i;
				Synth.new(\better_drumf, [\trig_bus, trig_bus[i].index], s);
			});

		}.play;


		this.addCommand("trig", "i", {
			arg msg;
			var idx;
			postln(msg);
			idx = msg[1] - 1;
			if((idx >= 0) && (idx < numVoices), {
  			trig_bus[idx].set(1.0);
			});
		});

		synth_param_names = [
			\pitch_base,
			\pitch_env_ratio,
			\fm_ratio,
			\fm_mod,

			\noise_rate,
			\noise_shape,

			\osc_level ,
			\noise_level ,

			\noise_amp_env_atk,
			\noise_amp_env_sus,
			\noise_amp_env_rel,

			\osc_amp_env_atk,
			\osc_amp_env_sus,
			\osc_amp_env_rel,

			\pitch_env_atk,
			\pitch_env_sus,
			\pitch_env_rel,

			\fc_env_atk,
			\fc_env_sus,
			\fc_env_rel,
			\fc_env_ratio,
			\fc_base,

			\filter_gain
		];

		synth_param_names.do({ arg name;
			this.addCommand(name, "if", {
				arg msg;
				var idx, value;
				postln(msg);
				idx = msg[1] - 1;
				if((idx >= 0) && (idx < numVoices), { 
				  value = msg[2];
				  drum_synth[idx].set(name, value);
				});
			});
		});
	}
	
	free {
		trig_bus.do ({ arg bus; bus.free; });
		drum_synth.do({ arg synth; synth.free; });
	}


}