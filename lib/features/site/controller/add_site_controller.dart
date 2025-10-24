import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_management/core/util/helpers/snackbar_util.dart';
import 'package:inventory_management/features/site/models/site_model.dart';

class AddSiteController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<SiteModel>> fetchSites() async {
    final snapshot = await _firestore.collection('sites').orderBy('name').get();
    return snapshot.docs
        .map((doc) => SiteModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
