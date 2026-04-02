import 'package:pet/premium/models/linked_account.dart';

abstract class BankIntegrationProvider {
  String get name;
  Future<List<LinkedAccount>> listLinkedAccounts();
  Future<void> connectAccount();
  Future<void> disconnectAccount(String id);
}
