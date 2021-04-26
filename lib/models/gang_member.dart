import 'dart:convert';

class GangMember {
  String uid;
  String name;

  GangMember(this.uid, this.name);

  factory GangMember.fromJson(String data) {
    final _data = json.decode(data);
    return GangMember(
      _data['uid'],
      _data['name'],
    );
  }

  String toJson() {
    return json.encode({
      'uid': this.uid,
      'name': this.name,
    });
  }
}
