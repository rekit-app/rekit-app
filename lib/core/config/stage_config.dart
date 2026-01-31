const Map<String, int> stage1DaysByDx = {
  'DX_FROZEN_1': 5,
  'DX_FROZEN_2': 5,
  'DX_FROZEN_3': 5,
  'DX_FROZEN_4': 5,
  'DX_FROZEN_5': 5,
  'DX_FROZEN_6': 5,
  'DX_FROZEN_7': 5,
  'DX_FROZEN_8': 5,

  'DX_RICE': 3,

  'DX_RCT_1': 7,
  'DX_RCT_2': 7,
  'DX_RCT_3': 7,
  'DX_RCT_4': 7,
  'DX_RCT_5': 7,
  'DX_RCT_6': 7,

  'DX_IMPINGE_1': 5,
  'DX_IMPINGE_2': 5,
  'DX_IMPINGE_3': 5,
  'DX_IMPINGE_4': 5,

  'DX_OTHER_1': 5,
  'DX_OTHER_2': 5,
  'DX_OTHER_3': 5,
  'DX_OTHER_4': 5,
  'DX_OTHER_5': 5,
  'DX_OTHER_6': 5,

  'DX_NECK_1': 3,
  'DX_NECK_2': 3,
  'DX_NECK_3': 3,
  'DX_NECK_4': 3,
  'DX_NECK_5': 3,
  'DX_NECK_6': 3,
  'DX_NECK_7': 3,
  'DX_NECK_8': 3,
  'DX_NECK_9': 3,
  'DX_NECK_10': 3,
  'DX_NECK_11': 3,
  'DX_NECK_12': 3,
  'DX_NECK_13': 3,
  'DX_NECK_14': 3,
  'DX_NECK_15': 3,
  'DX_NECK_16': 3,
  'DX_NECK_17': 3,
  'DX_NECK_18': 3,
  'DX_NECK_19': 3,
  'DX_NECK_20': 3,
  'DX_NECK_21': 3,
  'DX_NECK_22': 3,
  'DX_NECK_23': 3,
  'DX_NECK_24': 3,

  'DX_HEADACHE_1': 3,
  'DX_HEADACHE_2': 3,

  'DX_MENTAL': 3,

  'DX_ULTT_1': 3,
  'DX_ULTT_2': 3,
  'DX_ULTT_3': 3,
  'DX_ULTT_4': 3,
  'DX_ULTT_5': 3,
  'DX_ULTT_6': 3,

  'DX_CT': 3,
  'DX_NORMAL': 3,
};

int getStage1Days(String dx) {
  return stage1DaysByDx[dx] ?? 5;
}
