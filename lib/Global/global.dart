import 'package:firebase_auth/firebase_auth.dart';
import 'package:user/Models/direction_detail_info.dart';
import 'package:user/Models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;
UserModel? UserModelCurrentInfo;
//if i found key then i put it here
String cloudMessagingServerToken = "{}";
List driversList = [];
DirectionDetailInfo? tripDirectionDetailInfo;
String userDropOffAdress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
String driverRatings = "";
double countRatingStars = 0.0;
String titleStartRating = "";
