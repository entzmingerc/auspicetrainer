-- auspicetrainer
-- nb_drumcrow testing
-- originally adapted from
-- intervaltrainer by rgb
-- modified by postsolarpunk
--
-- IF enc2 == 1-4 THEN:
-- enc2 channel 1-4 notes
-- enc3 select note
-- key2 trigger a note
-- key3 clock a note every 2 sec
--
-- IF enc2 == 5-8 THEN:
-- enc2 5-8 channel 1-4 select
-- enc3 select modulation
-- key2 trigger random mod
-- key3 clock a random mod every 1.5 sec

next_auspice = "start!"
output_select = 1
param_select = 1
note_select = 60
auspice = {"turbulent", "turgid", "turquoise", "twinkling", "ultrasonic", "ultrastellar", "ululating", "uncanny", "unctuous", "undead", "undocumented"}
nb_voices = {"nb_1", "nb_2", "nb_3", "nb_4"}
drumcrow_presets = {}
idx_presets = 1
drumcrow_presets[1] = {
  mfreq = 1, note = 0, amp = 4, pw = 0, pw2 = 0, bit = 0, splash = 0,
  amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 10,  amp_symmetry = -1, amp_curve = 3,  amp_type = 0,  amp_phase = 1, 
  lfo_mfreq = 0,  lfo_note = 0,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 10,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
  note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 4, note_type = 0, note_phase = 1, 
  mfreq_mod = 0, note_mod = 0, amp_mod = 0, pw_mod = 0, pw2_mod = 0, bit_mod = 0, splash_mod = 0,
}
drumcrow_presets[2] = {
  mfreq = 0.5, note = 0, amp = 4, pw = 0, pw2 = 3, bit = 3, splash = 0,
  amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 10,  amp_symmetry = -1, amp_curve = 3,  amp_type = 0,  amp_phase = 1, 
  lfo_mfreq = 0,  lfo_note = 2,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 50,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
  note_mfreq = 0, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 10, note_symmetry = -1, note_curve = 4, note_type = 0, note_phase = 1, 
  mfreq_mod = 0, note_mod = 0, amp_mod = 0, pw_mod = 0, pw2_mod = 0, bit_mod = 0, splash_mod = 0,
}
drumcrow_presets[3] = {
  mfreq = 0.6, note = 0, amp = 4, pw = 0, pw2 = 0, bit = 0, splash = 0,
  amp_mfreq = 0,  amp_note = 0,  amp_amp = 1,  amp_pw = 0,  amp_pw2 = 0,  amp_bit = 0,  amp_cycle = 5,  amp_symmetry = -1, amp_curve = 3,  amp_type = 0,  amp_phase = 1, 
  lfo_mfreq = 0,  lfo_note = 4,  lfo_amp = 0,  lfo_pw = 0,  lfo_pw2 = 0,  lfo_bit = 0,  lfo_cycle = 3,  lfo_symmetry = 0,  lfo_curve = 0,  lfo_type = 1,  lfo_phase = -1, 
  note_mfreq = 0.8, note_note = 0, note_amp = 0, note_pw = 0, note_pw2 = 0, note_bit = 0, note_cycle = 200, note_symmetry = -1, note_curve = 4, note_type = 1, note_phase = 1, 
  mfreq_mod = 0, note_mod = 0, amp_mod = 0, pw_mod = 0, pw2_mod = 0, bit_mod = 0, splash_mod = 0,
}

nb = include("lib/nb/lib/nb") -- copy pasted the whole nb folder to lib
m = midi.connect()
m.event = function(data)
  local d = midi.to_msg(data)
  if d.type == "note_on" then
    generate_an_auspice(d.ch, d.note)
  end
end

function init()
  nb.voice_count = 1
  nb:init()
  nb:add_param(nb_voices[1], nb_voices[1])
  nb:add_param(nb_voices[2], nb_voices[2])
  nb:add_param(nb_voices[3], nb_voices[3])
  nb:add_param(nb_voices[4], nb_voices[4])
  nb:add_player_params()
end

function redraw()  
  screen.clear()
  screen.stroke()
  screen.move(0,40)
  screen.font_size(20)
  screen.text(next_auspice)
  screen.move(0,20)
  screen.text(output_select)  
  screen.move(20,20)
  if output_select <= 4 then
    screen.text(note_select)
  else
    player = params:lookup_param(nb_voices[(output_select-1) % 4 + 1]):get_player()
    desc = player:describe()
    if desc.note_mod_targets ~= nil then
      screen.text(desc.note_mod_targets[param_select])
    else
      screen.text("CAW! play")
    end
  end
  screen.update()
end

-- BUTTONS
function key(n, z)
  player = params:lookup_param(nb_voices[(output_select-1) % 4 + 1]):get_player()
  desc = player:describe()
  if desc.note_mod_targets ~= nil then
    if n == 2 and z == 1 then
      if output_select <= 4 then
        trigger_a_note(output_select, note_select)
      else
        trigger_a_mod((output_select-1) % 4 + 1, desc.note_mod_targets[param_select])
      end
    elseif n == 3 and z == 1 then
      if output_select <= 4 then
        next_auspice = auspice[math.random(11)]
        print("run rhythm "..next_auspice)
        clock.run(rhythm_init, output_select, note_select, 2)
      else
        next_auspice = auspice[math.random(11)]
        print("run mod "..next_auspice)
        clock.run(mod_init, (output_select-1) % 4 + 1, desc.note_mod_targets[param_select], 1.5)
      end
    end
  else
    next_auspice = "CAW!"
    print("CAW! NEED PLAYER!")
  end
  redraw()
end

-- KNOBS
function enc(n, delta)
  if n == 2 then
    output_select = output_select + delta
    output_select = output_select > 8 and 8 or output_select < 1 and 1 or output_select
  elseif n == 3 then
    if output_select <= 4 then -- 1 ... 4
      note_select = note_select + delta
      note_select = note_select > 127 and 127 or note_select < 1 and 1 or note_select
    else -- 5 ... 8
      param_select = param_select + delta
      param_select = param_select > 7 and 7 or param_select < 1 and 1 or param_select
    end
  end
  redraw()
end

-- select channel, select note, trig note every rtime seconds, constant velocity
function rhythm_init(ch, nt, rtime)
  while true do
    local player = params:lookup_param(nb_voices[ch]):get_player()
    player:note_on(nt, 5)
    clock.sleep(rtime)
  end
end

-- select channel, select parameter, random mod value every rtime seconds
function mod_init(ch, prm, rtime)
  while true do
    local player = params:lookup_param(nb_voices[ch]):get_player()
    player:modulate_note(1, prm, math.random())
    clock.sleep(rtime)
  end
end

function trigger_a_note(ch, nt)
  local player = params:lookup_param(nb_voices[ch]):get_player()
  player:note_on(nt, 5)
  next_auspice = auspice[math.random(11)]
  print("ch "..ch.." trig note "..next_auspice)
  redraw()
end

function trigger_a_mod(ch, prm)
  local player = params:lookup_param(nb_voices[ch]):get_player()
  player:modulate_note(1, prm, math.random())
  next_auspice = auspice[math.random(11)]
  print("ch "..ch.." trigger mod "..next_auspice)
  redraw()
end