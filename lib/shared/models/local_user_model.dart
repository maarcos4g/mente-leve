class LocalUserModel {
  final String nickname;
  final String avatar;

  LocalUserModel({
    required this.nickname,
    required this.avatar,
  });

  LocalUserModel copyWith({
    String? nickname,
    String? avatar
  }) => LocalUserModel(
    nickname: nickname ?? this.nickname,
    avatar: avatar ?? this.avatar,
  );

  Map<String, dynamic> toMap() => {
    'nickname': nickname,
    'avatar': avatar,
  };

  factory LocalUserModel.fromMap(Map map) => LocalUserModel(
    nickname: map['nickname'] as String,
    avatar: map['avatar'] as String,
  );
}