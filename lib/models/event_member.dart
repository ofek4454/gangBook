import 'dart:convert';

enum ConfirmationType {
  Arrive,
  NotArrive,
  HasntConfirmed,
}

class EventMember {
  String uid;
  String name;
  ConfirmationType isComming;
  Car car;

  EventMember(this.uid, this.name, this.isComming, this.car);

  factory EventMember.fromJson(String data) {
    final _data = json.decode(data);
    ConfirmationType isComming;
    switch (_data['isComming']) {
      case 'ConfirmationType.Arrive':
        isComming = ConfirmationType.Arrive;
        break;
      case 'ConfirmationType.NotArrive':
        isComming = ConfirmationType.NotArrive;
        break;
      default:
        isComming = ConfirmationType.HasntConfirmed;
        break;
    }
    return EventMember(
      _data['uid'],
      _data['name'],
      isComming,
      Car.fromJson(_data['car']),
    );
  }

  String toJson() {
    return json.encode({
      'uid': this.uid,
      'name': this.name,
      'isComming': this.isComming.toString(),
      'car': car?.toJson(),
    });
  }
}

class Car {
  String ownerId;
  List<String> riders;
  int places;

  Car(this.ownerId, this.riders, this.places);

  factory Car.fromJson(String data) {
    if (data == null) return null;
    final _data = json.decode(data);
    return Car(
      _data['ownerId'],
      _data['riders'],
      _data['places'],
    );
  }

  String toJson() {
    return json.encode({
      'ownerId': this.ownerId,
      'riders': this.riders,
      'places': this.places,
    });
  }
}
