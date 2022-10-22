#include <stdio.h>
#include <stdlib.h>
#include <flite.h>
#include <gdnative_api_struct.gen.h>

cst_wave *wave;
cst_voice *voice_0;
cst_voice *voice_1;
cst_voice *voice_2;
cst_voice *voice_3;
int sample_rate;

const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;

GDCALLINGCONV void *tts_constructor(godot_object *p_instance, void *p_method_data);
GDCALLINGCONV void tts_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data);
godot_variant tts_init(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant tts_clear(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant tts_get_wave(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant tts_get_sample_rate(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);

void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options)
{
  api = p_options->api_struct;

  // now find our extensions
  for (int i = 0; i < api->num_extensions; i++)
  {
    switch (api->extensions[i]->type)
    {
    case GDNATIVE_EXT_NATIVESCRIPT:
    {
      nativescript_api = (godot_gdnative_ext_nativescript_api_struct *)api->extensions[i];
    };
    break;
    default:
      break;
    };
  };
}

void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *p_options)
{
  api = NULL;
  nativescript_api = NULL;
}

void GDN_EXPORT godot_nativescript_init(void *p_handle)
{
  godot_instance_create_func create = {NULL, NULL, NULL};
  create.create_func = &tts_constructor;

  godot_instance_destroy_func destroy = {NULL, NULL, NULL};
  destroy.destroy_func = &tts_destructor;

  nativescript_api->godot_nativescript_register_class(p_handle, "TTS", "Reference", create, destroy);

  godot_method_attributes attributes = {GODOT_METHOD_RPC_MODE_DISABLED};

  godot_instance_method get_wave = {NULL, NULL, NULL};
  get_wave.method = &tts_get_wave;
  godot_instance_method get_sample_rate = {NULL, NULL, NULL};
  get_sample_rate.method = &tts_get_sample_rate;

  nativescript_api->godot_nativescript_register_method(p_handle, "TTS", "get_wave", attributes, get_wave);
  nativescript_api->godot_nativescript_register_method(p_handle, "TTS", "get_sample_rate", attributes, get_sample_rate);
}

GDCALLINGCONV void *tts_constructor(godot_object *p_instance, void *p_method_data)
{
  printf("TTS._construct()\n");
  flite_init();
  voice_0 = register_cmu_us_awb(NULL);
  voice_1 = register_cmu_us_kal(NULL);
  voice_2 = register_cmu_us_kal16(NULL);
  voice_3 = register_cmu_us_slt(NULL);
}

GDCALLINGCONV void tts_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data)
{
  printf("TTS._destruct()\n");
}

godot_variant tts_get_wave(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args)
{
  godot_string text_string = api->godot_variant_as_string(p_args[0]);
  godot_char_string text_char_string = api->godot_string_utf8(&text_string);
  const char *c_text = api->godot_char_string_get_data(&text_char_string);
  int voice_number = api->godot_variant_as_int(p_args[1]);
  
  godot_pool_byte_array godot_wave;
  godot_variant ret_wave;
  switch (voice_number)
  {
    case 0:
      wave = flite_text_to_wave(c_text, voice_0);
      break;
    case 1:
      wave = flite_text_to_wave(c_text, voice_1);
      break;
    case 2:
      wave = flite_text_to_wave(c_text, voice_2);
      break;
    case 3:
      wave = flite_text_to_wave(c_text, voice_3);
      break;
  }
  api->godot_pool_byte_array_new(&godot_wave);
  for (int i = 0; i < wave->num_samples; i++)
  {
    api->godot_pool_byte_array_append(&godot_wave, wave->samples[i] & 0xff);
    api->godot_pool_byte_array_append(&godot_wave, (wave->samples[i] >> 8) & 0xff);
  }
  api->godot_variant_new_pool_byte_array(&ret_wave, &godot_wave);
  sample_rate = wave->sample_rate;

  delete_wave(wave);
  api->godot_string_destroy(&text_string);
  api->godot_char_string_destroy(&text_char_string);
  api->godot_pool_byte_array_destroy(&godot_wave);

  return ret_wave;
}

godot_variant tts_get_sample_rate(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args)
{
  godot_variant ret_sample_rate;
  api->godot_variant_new_int(&ret_sample_rate, sample_rate);

  return ret_sample_rate;
}