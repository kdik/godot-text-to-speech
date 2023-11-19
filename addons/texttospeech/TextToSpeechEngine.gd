tool
extends Node

const VOICE_AWB = 0
const VOICE_AHW = 1
const VOICE_FEM = 2
const VOICE_AEW = 3
const VOICE_SLT = 4
const VOICE_EEY = 5
const VOICE_CLB = 6

var text_to_speech

func _ready():
    text_to_speech = load("res://addons/texttospeech/texttospeech.gdns").new()
    _load_voice("cmu_us_awb.flitevox", VOICE_AWB)
    _load_voice("cmu_us_ahw.flitevox", VOICE_AHW)
    _load_voice("cmu_us_fem.flitevox", VOICE_FEM)
    _load_voice("cmu_us_aew.flitevox", VOICE_AEW)
    _load_voice("cmu_us_slt.flitevox", VOICE_SLT)
    _load_voice("cmu_us_eey.flitevox", VOICE_EEY)
    _load_voice("cmu_us_clb.flitevox", VOICE_CLB)
    # NOTE: custom voices could be loaded here. To do so:
    # Add the .flitevox file to addons/texttospeech/voices/ folder
    # Include it in the list of dependencies in the texttospeech.gdnlib file 

func _load_voice(file_name, voice_id):
    if OS.has_feature("standalone"):
        text_to_speech.load_voice(file_name, voice_id)
    else:
        text_to_speech.load_voice("addons/texttospeech/voices/" + file_name, voice_id)

func say(audio_stream_player, text, voice_id, speed):
    var sample = AudioStreamSample.new()
    sample.data = text_to_speech.get_wave(text, voice_id)
    sample.mix_rate = text_to_speech.get_sample_rate() * speed
    sample.format = AudioStreamSample.FORMAT_16_BITS
    sample.loop_mode = AudioStreamSample.LOOP_DISABLED
    sample.loop_begin = 0
    sample.loop_end = 0
    sample.stereo = false
    audio_stream_player.stream = sample
    audio_stream_player.play()
    var duration = sample.data.size() / (sample.mix_rate * 2.0)
    yield(get_tree().create_timer(duration), "timeout")
