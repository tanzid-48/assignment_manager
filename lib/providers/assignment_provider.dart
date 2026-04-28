
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../services/notification_service.dart';

class AssignmentProvider with ChangeNotifier {
  List<Assignment> _assignments = [];
  bool _isDarkMode = false;
  String _searchQuery = '';
  String _filterStatus = 'All';
  int _currentTab = 0;
  bool _isLoading = false;

  int get currentTab => _currentTab;
  List<Assignment> get assignments => _assignments;
  bool get isDarkMode => _isDarkMode;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  bool get isLoading => _isLoading;

  CollectionReference<Map<String, dynamic>>? get _col {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('assignments');
  }

  List<Assignment> get filtered {
    return _assignments.where((a) {
      final matchSearch =
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              a.subject.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchFilter = _filterStatus == 'All' ||
          (_filterStatus == 'High Priority'
              ? a.priority == 'High'
              : a.status == _filterStatus);
      return matchSearch && matchFilter;
    }).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  int get totalCount => _assignments.length;
  int get pendingCount =>
      _assignments.where((a) => a.status == 'Pending').length;
  int get inProgressCount =>
      _assignments.where((a) => a.status == 'In Progress').length;
  int get completedCount =>
      _assignments.where((a) => a.status == 'Completed').length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
 
    _isDarkMode = prefs.getBool('darkMode') ?? false;

    final col = _col;
    if (col == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final snapshot = await col.orderBy('deadline').get();
      _assignments = snapshot.docs
          .map((doc) => Assignment.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Firestore load error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void listenToAssignments() {
    final col = _col;
    if (col == null) return;

    col.orderBy('deadline').snapshots().listen((snapshot) {
      _assignments = snapshot.docs
          .map((doc) => Assignment.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      notifyListeners();
    });
  }

  Future<void> add(Assignment a) async {
    final col = _col;
    if (col == null) return;

    try {
      final docRef = await col.add(a.toMap());
      final saved = Assignment.fromMap({...a.toMap(), 'id': docRef.id});
      _assignments.add(saved);

      await NotificationService.instance.scheduleForAssignment(saved);
      await NotificationService.instance.showSavedNotification(
        title: a.title,
        subject: a.subject,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Firestore add error: $e');
    }
  }

  Future<void> update(Assignment a) async {
    final col = _col;
    if (col == null) return;

    try {
      await col.doc(a.id).update(a.toMap());
      final i = _assignments.indexWhere((e) => e.id == a.id);
      if (i != -1) _assignments[i] = a;

      await NotificationService.instance.scheduleForAssignment(a);
      notifyListeners();
    } catch (e) {
      debugPrint('Firestore update error: $e');
    }
  }

  // id এখন String
  Future<void> delete(String id) async {
    final col = _col;
    if (col == null) return;

    try {
      await col.doc(id).delete();
      _assignments.removeWhere((e) => e.id == id);

      await NotificationService.instance.cancelForAssignment(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Firestore delete error: $e');
    }
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilter(String f) {
    _filterStatus = f;
    notifyListeners();
  }

  void setCurrentTab(int tab) {
    _currentTab = tab;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  void clearOnLogout() {
    _assignments = [];
    _searchQuery = '';
    _filterStatus = 'All';
    _currentTab = 0;
    notifyListeners();
  }
}