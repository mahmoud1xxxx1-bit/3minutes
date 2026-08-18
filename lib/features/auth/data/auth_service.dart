import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthSignInException implements Exception {
  const AuthSignInException(this.code);

  final String code;

  @override
  String toString() => 'AuthSignInException($code)';
}

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  static const String _googleServerClientId =
      '492486855771-l4881i9c2kmgj0te1dhtgjc0i9av69g6.apps.googleusercontent.com';

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  bool _initialized = false;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> initialize() async {
    if (_initialized) return;
    await _googleSignIn.initialize(serverClientId: _googleServerClientId);
    _initialized = true;
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await initialize();

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthSignInException('missing_id_token');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await _firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      throw AuthSignInException('google_${error.code.name}');
    } on FirebaseAuthException catch (error) {
      throw AuthSignInException('firebase_${error.code}');
    }
  }

  Future<void> signOut() async {
    await initialize();
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
