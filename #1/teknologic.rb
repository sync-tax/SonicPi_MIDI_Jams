"_- Tekno Logic ~ TRIBΞHOLZ -_'
================================================.
     .-.   .-.     .--.                         |
    | OO| | OO|   / _.-' .-.   .-.  .-.   .''.  |
================================================"
#---------------------------------------------------------
#PRESETS
use_bpm 170
use_debug false
use_real_time

#---------------------------------------------------------
#METRONOME
live_loop :metro do
  sleep 1
end
#---------------------------------------------------------
#SAMPLES
s_path = "C:/Users/Your/Sample/Path"

s = {
  kick: "#{s_path}/kick.wav",
  bass:  "#{s_path}/bass.wav",
  
  snare: "#{s_path}/snare.wav",
  clap: "#{s_path}/clap.wav",
  hat: "#{s_path}/hat.wav",
  
  atmo1:  "#{s_path}/atmo1.wav",
  atmo2:  "#{s_path}/atmo2.wav",
  atmo3:  "#{s_path}/atmo4.wav",
  
  umau: "#{s_path}/umau.wav",
}

#---------------------------------------------------------
#PATTERNS
define :pattern do |p|
  return p.ring.tick == "x"
end

kick_pattern = ("xoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxo")
snare_drum_pattern = [[0, 0, 0, 0, 1, 0, 0, 0],[0, 0, 0, 0, 1, 0, 1, 1],[0, 0, 0, 0, 1, 0, 0, 0],[0, 0, 0, 0, 1, 0, 0, 1]].flatten
highhat_pattern = [[0, 1, 1, 1, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0, 0, 0]].flatten

#---------------------------------------------------------
#MIXER
master = 1

kick_amp = 1
kick_co = 5

bass_amp = 1

drumkit_amp = 1
hats_amp = 0.0
snare_amp = 0.3
tz_amp = 0.0

umau_amp = 0.0
umau_phase = 4

lead_amp = 0
drone_amp = 0.0
thingy_amp = 0.0

synth_amp = 0.0
synth_pitch = 6
synth_co_multiplier = 0.7

#---------------------------------------------------------

live_loop :kick do
  #stop
  if pattern(kick_pattern)
    with_fx :eq, low_shelf: -0.2 do
      with_fx :hpf, cutoff: kick_co do
        with_fx :lpf, cutoff: 120 do
          sample s[:kick],
            amp:  kick_amp * master,
            depth: 0.9,
            cutoff: 120,
            beat_stretch: 1
        end
      end
    end
  end
  sleep 0.5
end

bass_co = range(130, 85, 0.5).mirror
with_fx :mono do
  with_fx :hpf, cutoff: 5 do
    live_loop :bass do
      with_fx :lpf, cutoff:  80 - $midi_values[18] do
        sleep 0.5
        sample s[:bass],
          amp: bass_amp * master,
          rate: 1
        sleep 0.5
      end
    end
  end
end

with_fx :reverb, mix: 0.25 do
  live_loop :snare, sync: :metro do
    #stop
    sample s[:snare],
      amp:  snare_amp * master,
      beat_stretch: 0.25,
      cutoff: 110
    sleep 2
  end
end

with_fx :gverb, dry: 0.75, release: 0.25 do
  live_loop :hihat , sync: :metro do
    #stop
    sample s[:hat], amp: hats_amp * master, rate: 8 , cutoff: 80
    sleep 0.5
    sample s[:hat], amp: hats_amp * master, rate: 3, cutoff: 100
    sleep 0.5
    sample s[:hat], amp: hats_amp * master, rate: 3, cutoff: 90
    sleep 0.5
    sample s[:hat], amp: hats_amp * master, rate: 3, cutoff: 100
    sleep 0.5
  end
end

with_fx :reverb, mix: 0.3 do
  live_loop :tz, sync: :kick do
    #stop
    sample s[:hat],
      amp: tz_amp ,
      rate: 2,
      cutoff: 120,
      beat_stretch: 1,
      rpitch: 20,
      release: 0.08,
      attack: 0.01
    sleep 1
  end
end

live_loop :drumkit, sync: :metro do
  32.times do |i|
    if snare_drum_pattern[i] ==  1
      
      sample s[:snare], amp: 0.23  * drumkit_amp, beat_stretch: 0.3
    end
    if highhat_pattern[i] == 1
      sample s[:hat], amp: 0.1 * drumkit_amp, beat_stretch: 0.15
    end
    sleep 0.25
  end
end

with_fx :reverb, room: 0.75, mix: 0.6 do
  with_fx :slicer, phase: umau_phase do
    live_loop :umau, sync: :metro do
      #stop
      sample s[:umau],
        amp: umau_amp * master, start: 0, finish: 1,
        beat_stretch: 8,
        rate: ring(1, 1).tick
      sleep 8
    end
  end
end

with_fx :reverb, mix: 0.5, room: 0.75 do
  with_fx :slicer, phase: 0.5 do
    live_loop :drone, sync: :metro do
      #stop
      sample s[:atmo1],
        amp: drone_amp * master,
        beat_stretch: 12,
        rpitch: ring(2, 1).tick
      sleep 4
    end
  end
end

with_fx :gverb, damp: 1, mix: 0.75, dry: 0.5 do
  with_fx :reverb, mix: 0.6, room: 0.75 do
    with_fx :slicer, phase: 0.5 do
      live_loop :tütötüdädä do
        #stop
        atmo_co = range(70, 75, 2.5).mirror
        sample s[:atmo2],
          amp: lead_amp * master,
          release: 0.25,
          attack: 0.05,
          rate: 1,
          beat_stretch: 2,
          pitch: 12,
          cutoff: 90
        sleep 8
      end
    end
  end
end

live_loop :thingy, sync: :metro do
  #stop
  with_fx :reverb, mix: 0.5, room: 0.75  do
    with_fx :slicer, phase: 0.5 do
      sample s[:atmo3],
        amp: thingy_amp * master,
        beat_stretch: 10
      sleep 8
    end
  end
end

#----------------------------------------------------------------------
#----------------------------------------------------------------------
#SYNTH PART

with_fx :ping_pong, feedback: 0.25, phase: 0.5 do
  with_fx :ixi_techno, phase: 1, mix: 0.5, res: 0.2 do
    live_loop :synth, sync: :metro do
      synth_co = range(105, 85, 0.5).mirror
      use_random_seed ring(100, 1500, 125, 400, 2500).tick
      16.times do
        with_synth :bass_foundation do
          n1 = (ring :f3, :d3, :e3).tick
          n2 = (ring :e4, :d4).tick
          play n1,
            release: (ring, 0.15, 0.5, 0.15, 0.5).tick,
            cutoff: synth_co.look,
            res: 0.5,
            wave: 0,
            amp: synth_amp,
            pitch: synth_pitch
          sleep 0.25
        end
      end
    end
  end
end
