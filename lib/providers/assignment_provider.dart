import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../services/notification_service.dart';

class AssignmentProvider with ChangeNotifier {
  List<Assignment> _assignments = [];
  bool _isDarkMode = false;
  String _searchQuery = '';
  String _filterStatus = 'All';

  List<Assignment> get assignments => _assignments;
  bool get isDarkMode => _isDarkMode;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;

  List<Assignment> get filtered {
    return _assignments.where((a) {
      final matchSearch = a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.subject.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchFilter = _filterStatus == 'All' ||
          (_filterStatus == 'High Priority' ? a.priority == 'High' : a.status == _filterStatus);
      return matchSearch && matchFilter;
    }).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  int get totalCount => _assignments.length;
  int get pendingCount => _assignments.where((a) => a.status == 'Pending').length;
  int get inProgressCount => _assignments.where((a) => a.status == 'In Progress').length;
  int get completedCount => _assignments.where((a) => a.status == 'Completed').length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('assignments');
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _assignments = list.map((e) => Assignment.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('assignments', jsonEncode(_assignments.map((e) => e.toMap()).toList()));
  }

  Future<void> add(Assignment a) async {
    _assignments.add(a);
    await _save();
     await NotificationService.instance.scheduleForAssignment(a); 
      await NotificationService.instance.showSavedNotification( 
    title: a.title,
    subject: a.subject,
  );
    notifyListeners();
  }

  Future<void> update(Assignment a) async {
    final i = _assignments.indexWhere((e) => e.id == a.id);
    if (i != -1) _assignments[i] = a;
    await _save();
    await NotificationService.instance.scheduleForAssignment(a);
    notifyListeners();
  }

  Future<void> delete(int id) async {
    _assignments.removeWhere((e) => e.id == id);
    await _save();
    await NotificationService.instance.cancelForAssignment(id);
    notifyListeners();
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilter(String f) {
    _filterStatus = f;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  int get nextId => _assignments.isEmpty
      ? 1
      : _assignments.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
}