final Map<String, Map<String, dynamic>> shoulderQuestions = {
  'Q01': {
    'title': '어깨 진단 시작',
    'question': '가만히 있어도 팔이나 손까지 저리거나 찌릿한 느낌이 있나요?',
    'options': [
      {'text': '저림', 'next': 'NECK'},
      {'text': '없음', 'next': 'Q02'},
    ],
  },
  'Q02': {
    'title': '가동 범위 확인',
    'question': '움직일 때 가동범위에 제한이 있으신가요? (아픈데 무리해서 올리지 마세요)',
    'options': [
      {'text': '네', 'next': 'Q03'},
      {'text': '아니오', 'next': 'Q04'},
    ],
  },
  'Q03': {
    'title': '보조 가동 범위',
    'question': '팔을 보조해줘도 가동범위에 제한이 있나요?',
    'options': [
      {'text': '네', 'next': 'Q05'},
      {'text': '아니오 잘 움직여요', 'next': 'Q06'},
    ],
  },
  'Q04': {
    'title': 'External Rotation 테스트',
    'question': 'External Rotation하고 팔을 올렸을 때 통증이 줄어드나요?',
    'options': [
      {'text': '통증이 증가함', 'next': 'Q04A'},
      {'text': '통증의 변화가 없음', 'next': 'Q04B'},
      {'text': '통증이 줄어듦', 'next': 'Q04C'},
    ],
  },
  'Q04A': {
    'title': '소리 확인',
    'question': '어깨에서 딸깍하는 소리가 들리나요?',
    'options': [
      {'text': '네', 'next': 'DX_OTHER_1'},
      {'text': '아니오', 'next': 'DX_OTHER_2'},
    ],
  },
  'Q04B': {
    'title': '소리 확인',
    'question': '어깨에서 딸깍하는 소리가 들리나요?',
    'options': [
      {'text': '네', 'next': 'DX_OTHER_3'},
      {'text': '아니오', 'next': 'DX_OTHER_4'},
    ],
  },
  'Q04C': {
    'title': '소리 확인',
    'question': '어깨에서 딸깍하는 소리가 들리나요?',
    'options': [
      {'text': '네', 'next': 'DX_OTHER_5'},
      {'text': '아니오', 'next': 'DX_OTHER_6'},
    ],
  },
  'Q05': {
    'title': '증상 기간',
    'question': '증상이 시작된지 대략적으로 얼마나 되었나요?',
    'options': [
      {'text': '6개월 미만', 'next': 'DX_RICE'},
      {'text': '6개월 ~ 1년', 'next': 'Q05A'},
      {'text': '1년 이상', 'next': 'Q05B'},
    ],
  },
  'Q05A': {
    'title': '동작 제한 패턴 (6개월~1년)',
    'question': '팔을 들어 올리는 동작, 바깥으로 돌리는 동작, 등 뒤로 돌리는 동작이 전반적으로 다 비슷하게 잘 안 되나요?',
    'options': [
      {'text': '네', 'next': 'DX_FROZEN_1'},
      {'text': '다릅니다', 'next': 'Q05A1'},
    ],
  },
  'Q05A1': {
    'title': '특정 동작 제한 (6개월~1년)',
    'question': '어떤 동작이 가장 불편하신가요?',
    'options': [
      {'text': 'IR', 'next': 'DX_FROZEN_2'},
      {'text': 'ER', 'next': 'DX_FROZEN_3'},
      {'text': 'FL', 'next': 'DX_FROZEN_4'},
    ],
  },
  'Q05B': {
    'title': '동작 제한 패턴 (1년 이상)',
    'question': '팔을 들어 올리는 동작, 바깥으로 돌리는 동작, 등 뒤로 돌리는 동작이 전반적으로 다 비슷하게 잘 안 되나요?',
    'options': [
      {'text': '네', 'next': 'DX_FROZEN_5'},
      {'text': '아니오 다릅니다', 'next': 'Q05B1'},
    ],
  },
  'Q05B1': {
    'title': '특정 동작 제한 (1년 이상)',
    'question': '어떤 동작이 가장 불편하신가요?',
    'options': [
      {'text': 'FL할 때', 'next': 'DX_FROZEN_6'},
      {'text': 'ER 할 때', 'next': 'DX_FROZEN_7'},
      {'text': 'IR 할 때', 'next': 'DX_FROZEN_8'},
    ],
  },
  'Q06': {
    'title': '회전 동작 확인',
    'question': '바깥으로 돌리거나(ER), 안쪽으로 돌릴 때(IR) 둘 중 하나라도 통증이나 힘 빠짐이 있나요?',
    'options': [
      {'text': '네', 'next': 'Q07'},
      {'text': '아니오', 'next': 'Q08'},
    ],
  },
  'Q07': {
    'title': '회전 방향 확인',
    'question': '어느 방향에서 문제가 있나요?',
    'options': [
      {'text': 'IR', 'next': 'Q07A'},
      {'text': 'ER', 'next': 'Q07B'},
    ],
  },
  'Q07A': {
    'title': '편심성 수축 테스트 (IR)',
    'question': '팔을 들어올리고 천천히 내렸을 때(5초~8초) 통증이 발생하거나 힘이 빠지나요?',
    'options': [
      {'text': '네', 'next': 'Q07A1'},
      {'text': '아니오', 'next': 'RCT_3'},
    ],
  },
  'Q07A1': {
    'title': '열중쉬엇 동작 (IR)',
    'question': '이 동작이 가능한가요? (열중쉬엇)',
    'options': [
      {'text': '아니오', 'next': 'RCT_1'},
      {'text': '네', 'next': 'RCT_2'},
    ],
  },
  'Q07B': {
    'title': '편심성 수축 테스트 (ER)',
    'question': '팔을 들어올리고 천천히 내렸을 때(5초~8초) 통증이 발생하거나 힘이 빠지나요?',
    'options': [
      {'text': '네', 'next': 'Q07B1'},
      {'text': '아니오', 'next': 'RCT_6'},
    ],
  },
  'Q07B1': {
    'title': '열중쉬엇 동작 (ER)',
    'question': '이 동작이 가능한가요? (열중쉬엇)',
    'options': [
      {'text': '아니오', 'next': 'RCT_4'},
      {'text': '네', 'next': 'RCT_5'},
    ],
  },
  'Q08': {
    'title': '편심성 수축 일반 테스트',
    'question': '팔을 들어올리고 천천히 내렸을 때(5~8초 정도) 통증이 발생하거나 힘이 빠지나요?',
    'options': [
      {'text': '네', 'next': 'Q08A'},
      {'text': '아니오', 'next': 'Q08B'},
    ],
  },
  'Q08A': {
    'title': '소리/걸림 확인',
    'question': '팔을 내릴 때 어깨에서 소리가 나거나 걸리는 느낌이 있나요?',
    'options': [
      {'text': '예', 'next': 'IMPINGE_1'},
      {'text': '아니오', 'next': 'IMPINGE_2'},
    ],
  },
  'Q08B': {
    'title': '찝힘 확인',
    'question': '팔을 들거나 내릴 때 특정 각도에서 찝히는 느낌이 있나요?',
    'options': [
      {'text': '예', 'next': 'IMPINGE_3'},
      {'text': '아니오', 'next': 'IMPINGE_4'},
    ],
  },
};
