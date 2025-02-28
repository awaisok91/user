import 'package:firebase_auth/firebase_auth.dart';
import 'package:user/Models/direction_detail_info.dart';
import 'package:user/Models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;
UserModel? UserModelCurrentInfo;
//if i found key then i put it here
String cloudMessagingServerToken =
    "key=AAAABtiQzP4:APA91bFTLzNNnLGIU6Cdl-75HQLFHUOP7oLGJbCN_7kzGbzh3mFmS1F241dWxhdih3P02ih4k6omdxZdcq_m6lCX7YgqsnfAxUpic2oFGapKriffda3m4ebpOnJwFUVSQsqnkkBwArz_";
List driversList = [];
DirectionDetailInfo? tripDirectionDetailInfo;
String userDropOffAdress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
double countRatingStars = 0.0;
String titleStartRating = "";
