tool
extends AudioStreamPlayer3D
class_name TextToSpeech3D

const VOICE_AWB = 0
const VOICE_KAL = 1
const VOICE_KAL16 = 2
const VOICE_SLT = 3

onready var text_to_speech = preload("res://addons/texttospeech/texttospeech.gdns").new()

func say(text, voice_id = VOICE_AWB, speed = 1.0):
    var sample = AudioStreamSample.new()
    sample.data = text_to_speech.get_wave(text, voice_id)
    sample.mix_rate = text_to_speech.get_sample_rate() * speed
    sample.format = AudioStreamSample.FORMAT_16_BITS
    sample.loop_mode = AudioStreamSample.LOOP_DISABLED
    sample.loop_begin = 0
    sample.loop_end = 0
    sample.stereo = false
    self.stream = sample
    self.play()
    var duration = sample.data.size() / (sample.mix_rate * 2.0)
    yield(get_tree().create_timer(duration), "timeout")