final Map<String, Map<String, dynamic>> neckQuestions = {
  'Q01': {
    'title': '목 진단 시작',
    'question': '목이 아프신가요?',
    'options': [
      {'text': '네 (통증과 저림 포함)', 'next': 'Q02'},
      {'text': '아니오 (목에 아픔만 없을 때, 저리거나 이상감각 포함)', 'next': 'Q20'},
    ],
  },
  'Q02': {
    'title': '통증 발생 시기',
    'question': '움직일 때 아프신가요?',
    'options': [
      {'text': '네', 'next': 'Q03'},
      {'text': '아니요', 'next': 'Q17'},
    ],
  },
  'Q03': {
    'title': '움직임 방향',
    'question': '어떤 움직임에서 통증이 발생하나요?',
    'options': [
      {'text': '고개 숙이기', 'next': 'Q04'},
      {'text': '고개 젖히기', 'next': 'Q07'},
      {'text': '옆으로 기울이기 (귀가 어깨에 닿게)', 'next': 'Q10'},
    ],
  },
  'Q04': {
    'title': '숙일 때 통증 위치',
    'question': '통증이 목의 위쪽인가요, 아래쪽인가요?',
    'options': [
      {'text': '위', 'next': 'Q05'},
      {'text': '아래', 'next': 'Q06'},
    ],
  },
  'Q05': {
    'title': '숙이고 회전 확인 (위쪽 통증)',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_1'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_2'},
    ],
  },
  'Q06': {
    'title': '숙이고 회전 확인 (아래쪽 통증)',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_3'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_4'},
    ],
  },
  'Q07': {
    'title': '젖힐 때 통증 위치',
    'question': '통증이 목의 위쪽인가요, 아래쪽인가요?',
    'options': [
      {'text': '위', 'next': 'Q08'},
      {'text': '아래', 'next': 'Q09'},
    ],
  },
  'Q08': {
    'title': '젖히고 회전 확인 (위쪽 통증)',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_5'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_6'},
    ],
  },
  'Q09': {
    'title': '젖히고 회전 확인 (아래쪽 통증)',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_7'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_8'},
    ],
  },
  'Q10': {
    'title': '기울이기 방향',
    'question': '어느 쪽으로 숙일 때 아프신가요?',
    'options': [
      {'text': '왼쪽', 'next': 'Q11'},
      {'text': '오른쪽', 'next': 'Q14'},
    ],
  },
  'Q11': {
    'title': '왼쪽 기울이기 통증 위치',
    'question': '어디가 아프세요?',
    'options': [
      {'text': '왼쪽', 'next': 'Q12'},
      {'text': '오른쪽', 'next': 'Q13'},
    ],
  },
  'Q12': {
    'title': '왼쪽 기울이기 (왼쪽 통증)',
    'question': '통증이 목의 위쪽인가요, 아래쪽인가요?',
    'options': [
      {'text': '위', 'next': 'Q12A'},
      {'text': '아래', 'next': 'Q12B'},
    ],
  },
  'Q12A': {
    'title': '왼쪽 기울이기 위 회전',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_9'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_10'},
    ],
  },
  'Q12B': {
    'title': '왼쪽 기울이기 아래 회전',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_11'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_12'},
    ],
  },
  'Q13': {
    'title': '왼쪽 기울이기 (오른쪽 통증)',
    'question': '통증이 목의 위쪽인가요, 아래쪽인가요?',
    'options': [
      {'text': '위', 'next': 'Q13A'},
      {'text': '아래', 'next': 'Q13B'},
    ],
  },
  'Q13A': {
    'title': '왼쪽 기울이기 위 회전',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_13'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_14'},
    ],
  },
  'Q13B': {
    'title': '왼쪽 기울이기 아래 회전',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_15'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_16'},
    ],
  },
  'Q14': {
    'title': '오른쪽 기울이기 통증 위치',
    'question': '어디가 아프세요?',
    'options': [
      {'text': '오른쪽', 'next': 'Q15'},
      {'text': '왼쪽', 'next': 'Q16'},
    ],
  },
  'Q15': {
    'title': '오른쪽 기울이기 (오른쪽 통증)',
    'question': '통증이 목의 위쪽인가요, 아래쪽인가요?',
    'options': [
      {'text': '위', 'next': 'Q15A'},
      {'text': '아래', 'next': 'Q15B'},
    ],
  },
  'Q15A': {
    'title': '오른쪽 기울이기 위 회전',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_17'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_18'},
    ],
  },
  'Q15B': {
    'title': '오른쪽 기울이기 아래 회전',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_19'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_20'},
    ],
  },
  'Q16': {
    'title': '오른쪽 기울이기 (왼쪽 통증)',
    'question': '통증이 목의 위쪽인가요, 아래쪽인가요?',
    'options': [
      {'text': '위', 'next': 'Q16A'},
      {'text': '아래', 'next': 'Q16B'},
    ],
  },
  'Q16A': {
    'title': '오른쪽 기울이기 위 회전',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_21'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_22'},
    ],
  },
  'Q16B': {
    'title': '오른쪽 기울이기 아래 회전',
    'question': '회전 시 어느 쪽이 더 아프신가요?',
    'options': [
      {'text': '오른쪽으로 돌릴 때', 'next': 'DX_NECK_23'},
      {'text': '왼쪽으로 돌릴 때', 'next': 'DX_NECK_24'},
    ],
  },
  'Q17': {
    'title': '두통 확인',
    'question': '두통이 있으신가요?',
    'options': [
      {'text': '네', 'next': 'Q18'},
      {'text': '아니요', 'next': 'DX_MENTAL'},
    ],
  },
  'Q18': {
    'title': '두통 관련 움직임',
    'question': '머리를 돌리면 아프신가요?',
    'options': [
      {'text': '네', 'next': 'DX_HEADACHE_1'},
      {'text': '아니요', 'next': 'DX_HEADACHE_2'},
    ],
  },
  'Q20': {
    'title': '저림 확인',
    'question': '저린 증상이 있으신가요?',
    'options': [
      {'text': '네', 'next': 'Q21'},
      {'text': '아니요', 'next': 'Q25'},
    ],
  },
  'Q21': {
    'title': '저림 부위',
    'question': '어디까지 저리신가요?',
    'options': [
      {'text': '손', 'next': 'Q22'},
      {'text': '팔', 'next': 'Q23'},
      {'text': '어깨', 'next': 'DX_ULTT_6'},
    ],
  },
  'Q22': {
    'title': '손 저림 부위',
    'question': '손의 어느 부위가 저리신가요?',
    'options': [
      {'text': '1, 2번 손가락', 'next': 'DX_ULTT_1'},
      {'text': '3, 4, 5번 손가락', 'next': 'DX_ULTT_2'},
      {'text': '손등', 'next': 'DX_ULTT_3'},
    ],
  },
  'Q23': {
    'title': '팔 저림 부위',
    'question': '팔의 어느 부위가 저리신가요?',
    'options': [
      {'text': '안쪽', 'next': 'DX_ULTT_4'},
      {'text': '바깥쪽', 'next': 'DX_ULTT_5'},
    ],
  },
  'Q25': {
    'title': '날개뼈 통증',
    'question': '혹시 날개뼈 사이가 아프신가요?',
    'options': [
      {'text': '네', 'next': 'DX_CT'},
      {'text': '아니오', 'next': 'DX_NORMAL'},
    ],
  },
};

final List<String> neckResultCodes = [
  'DX_NECK_1',
  'DX_NECK_2',
  'DX_NECK_3',
  'DX_NECK_4',
  'DX_NECK_5',
  'DX_NECK_6',
  'DX_NECK_7',
  'DX_NECK_8',
  'DX_NECK_9',
  'DX_NECK_10',
  'DX_NECK_11',
  'DX_NECK_12',
  'DX_NECK_13',
  'DX_NECK_14',
  'DX_NECK_15',
  'DX_NECK_16',
  'DX_NECK_17',
  'DX_NECK_18',
  'DX_NECK_19',
  'DX_NECK_20',
  'DX_NECK_21',
  'DX_NECK_22',
  'DX_NECK_23',
  'DX_NECK_24',
  'DX_HEADACHE_1',
  'DX_HEADACHE_2',
  'DX_MENTAL',
  'DX_ULTT_1',
  'DX_ULTT_2',
  'DX_ULTT_3',
  'DX_ULTT_4',
  'DX_ULTT_5',
  'DX_ULTT_6',
  'DX_CT',
  'DX_NORMAL',
];
