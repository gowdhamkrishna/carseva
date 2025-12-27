import 'package:carseva/carinfo/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCarRemoteDataSource {
  final FirebaseFirestore firestore;

  UserCarRemoteDataSource(this.firestore);

  Future<void> saveCar(String userId, UserCarModel model) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('current_car')
        .doc('active')
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  Future<UserCarModel?> getCar(String userId) async {
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('current_car')
        .doc('active')
        .get();

    if (!doc.exists) return null;
    return UserCarModel.fromFirestore(doc.data()!);
  }
}
