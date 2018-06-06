
import 'package:flutter/foundation.dart';

class CardViewModel {
  final String backgroundAssetPath;
  final String address;
  final int minHeightInFeet;
  final int maxHeightInFeet;
  final double tempInDegrees;
  final String weatherType;
  final double windSpeedMph;
  final String cardinalDirection;

  CardViewModel({this.backgroundAssetPath, this.address, this.minHeightInFeet, this.maxHeightInFeet, this.tempInDegrees, this.weatherType, this.windSpeedMph, this.cardinalDirection});

}

final List<CardViewModel> listSampleCards = [
  CardViewModel(
    backgroundAssetPath: 'assets/images/shutterstock_90167506.jpg',
    address: 'Hải Vân',
    minHeightInFeet: 1,
    maxHeightInFeet: 2,
    tempInDegrees: 25.0,
    weatherType: 'Windy',
    windSpeedMph: 25.0,
    cardinalDirection: 'ENE'
  ),
  CardViewModel(
      backgroundAssetPath: 'assets/images/shutterstock_147644363.jpg',
      address: 'Trường Sơn',
      minHeightInFeet: 2,
      maxHeightInFeet: 3,
      tempInDegrees: 28.0,
      weatherType: 'Cloudy',
      windSpeedMph: 35.0,
      cardinalDirection: 'E'
  ),
  CardViewModel(
      backgroundAssetPath: 'assets/images/shutterstock_223017889.jpg',
      address: 'Cát Bà',
      minHeightInFeet: 5,
      maxHeightInFeet: 8,
      tempInDegrees: 12.0,
      weatherType: 'Sunny',
      windSpeedMph: 19.0,
      cardinalDirection: 'N'
  ),
];