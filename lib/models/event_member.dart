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
  List<String> carRequests;
  String carRide;

  EventMember({
    this.uid,
    this.name,
    this.isComming,
    this.car,
    this.carRequests,
    this.carRide,
  });

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
      uid: _data['uid'],
      name: _data['name'],
      isComming: isComming,
      car: Car.fromJson(_data['car']),
      carRequests: List<String>.from(_data['carRequests']) ?? [],
      carRide: _data['carRide'],
    );
  }

  String toJson() {
    return json.encode({
      'uid': this.uid,
      'name': this.name,
      'isComming': this.isComming.toString(),
      'car': car?.toJson(),
      'carRequests': this.carRequests,
      'carRide': this.carRide,
    });
  }
}

class Car {
  String ownerId;
  List<CarRider> riders;
  int places;
  List<CarRider> requests;

  Car({this.ownerId, this.riders, this.places, this.requests});

  factory Car.fromJson(String data) {
    if (data == null) return null;
    final _data = json.decode(data);

    final List<dynamic> ridersData = _data['riders'];
    final List<CarRider> _riders = [];
    ridersData.forEach((rider) => _riders.add(CarRider.fromJson(rider)));

    final List<dynamic> requestsData = _data['requests'];
    final List<CarRider> _requests = [];
    requestsData.forEach(
      (rider) => _requests.add(
        CarRider.fromJson(rider),
      ),
    );

    return Car(
      ownerId: _data['ownerId'],
      places: _data['places'],
      riders: _riders,
      requests: _requests,
    );
  }

  String toJson() {
    return json.encode({
      'ownerId': this.ownerId,
      'riders': this.riders,
      'places': this.places,
      'requests': this.requests,
    });
  }
}

class CarRider {
  String uid;
  String name;
  String pickupFrom;

  CarRider({this.uid, this.name, this.pickupFrom});

  factory CarRider.fromJson(String data) {
    if (data == null) return null;
    final _data = json.decode(data);
    return CarRider(
      uid: _data['uid'],
      name: _data['name'],
      pickupFrom: _data['pickupFrom'],
    );
  }

  String toJson() {
    return json.encode({
      'uid': this.uid,
      'name': this.name,
      'pickupFrom': this.pickupFrom,
    });
  }
}
