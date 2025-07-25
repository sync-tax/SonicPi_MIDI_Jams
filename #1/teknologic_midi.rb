"_- Tekno Logic | MIDI ~ TRIBΞHOLZ -_'
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

master = 1
#---------------------------------------------------------
#SAMPLES
s_path = "C:/Users/rober/Desktop/SOUND/samples/Hä/"

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
#MIDI MIXER
define :scale_midi do |val, min, max|
  return min + (val.to_f / 127) * (max - min)
end

$midi_values ||= Hash.new(0.01)

live_loop :midi_controls do
  key, value = sync "/midi:midi_mix_1:1/control_change"
  
  case key
  when 18
    $midi_values[18] = scale_midi(value, 5, 80) # kick_co + bass_co
  when 19
    $midi_values[19] = scale_midi(value, 0, 1) # kick_amp + bass_amp
  when 22
    $midi_values[22] = scale_midi(value, 0, 1) # drumkit_amp
  when 23
    $midi_values[23] = scale_midi(value, 0, 0.6) # hats_amp
  when 27
    $midi_values[27] = scale_midi(value, 0, 0.4) # snare_amp
  when 31
    $midi_values[31] = scale_midi(value, 0, 0.5) # tz_amp
  when 49
    $midi_values[49] = scale_midi(value, 0, 0.5) # umau_amp
  when 53
    $midi_values[53] = scale_midi(value, 0, 1) # lead_amp
  when 57
    $midi_values[57] = scale_midi(value, 0, 0.17) # drone_amp
  when 58
    $midi_values[58] = scale_midi(value, 40, 80) # synth_cutoff
  when 59
    $midi_values[59] = scale_midi(value, -2, 6) # synth_pitch
  when 60
    $midi_values[60] = scale_midi(value, 0, 1) # synth_cutoff
  when 61
    $midi_values[61] = scale_midi(value, 0, 0.3) # synth_amp
  when 62
    $midi_values[62] = scale_midi(value, 0, 0.5) # thingy_amp
  end
end
#---------------------------------------------------------

live_loop :kick do
  #stop
  if pattern(kick_pattern)
    with_fx :eq, low_shelf: -0.2 do
      with_fx :hpf, cutoff: $midi_values[18] do
        with_fx :lpf, cutoff: 120 do
          sample s[:kick],
            amp:  $midi_values[19] * master,
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
          amp: $midi_values[19] * 1.25,
          rate: 1
        sleep 0.5
      end
    end
  end
end

live_loop :snare do
  with_fx :reverb, mix: 0.25 do
    sample s[:snare],
      amp:  $midi_values[27]* master,
      beat_stretch: 0.25,
      cutoff: 110
    sleep 2
  end
end

with_fx :gverb, dry: 0.75, release: 0.25 do
  live_loop :hihat , sync: :metro do
    #stop
    sample s[:hat], amp: $midi_values[23] * master, rate: 8 , cutoff: 80
    sleep 0.5
    sample s[:hat], amp: $midi_values[23] * master, rate: 3, cutoff: 100
    sleep 0.5
    sample s[:hat], amp: $midi_values[23] * master, rate: 3, cutoff: 90
    sleep 0.5
    sample s[:hat], amp: $midi_values[23] * master, rate: 3, cutoff: 100
    sleep 0.5
  end
end

with_fx :reverb, mix: 0.3 do
  live_loop :tz, sync: :kick do
    sample s[:hat],
      amp: $midi_values[31] ,
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
      
      sample s[:snare], amp: 0.22  * $midi_values[22], beat_stretch: 0.3
    end
    if highhat_pattern[i] == 1
      sample s[:hat], amp: 0.1 * $midi_values[22], beat_stretch: 0.15
    end
    sleep 0.25
  end
end

live_loop :umau, sync: :metro do
  with_fx :reverb, room: 0.75, mix: 0.6 do
    with_fx :slicer, phase: 0.5 do
      sample s[:umau],
        amp: $midi_values[49], start: 0, finish: 1,
        beat_stretch: 8,
        rate: (ring 2,-2).tick
      sleep 8
    end
  end
end

live_loop :drone, sync: :metro do
  with_fx :reverb, mix: 0.5, room: 0.75 do
    with_fx :slicer, phase: 0.5 do
      sample s[:atmo1],
        amp: $midi_values[57],
        beat_stretch: 12,
        rpitch: ring(2, 1).tick
      sleep 4
    end
  end
end

live_loop :tütötüdädä do
  atmo_co = range(70, 75, 2.5).mirror
  with_fx :gverb, damp: 1, mix: 0.75, dry: 0.5 do
    with_fx :reverb, mix: 0.6, room: 0.75 do
      with_fx :slicer, phase: 0.5 do
        sample s[:atmo2],
          amp: $midi_values[53] * master,
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
  with_fx :reverb, mix: 0.5, room: 0.75  do
    with_fx :slicer, phase: 0.5 do
      sample s[:atmo3],
        amp: $midi_values[62],
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
            cutoff: synth_co.look * $midi_values[60],
            res: 0.5,
            wave: 0,
            amp: $midi_values[61],
            pitch: $midi_values[59]
          sleep 0.25
        end
      end
    end
  end
end