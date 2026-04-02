import 'package:pet/premium/models/linked_account.dart';
import 'package:pet/premium/services/bank_integration_provider.dart';

class MockBankIntegrationProvider implements BankIntegrationProvider {
  @override
  String get name => 'Mock Aggregator';

  final List<LinkedAccount> _accounts = [
    LinkedAccount(
      id: 'mock_hdfc',
      provider: 'mock',
      accountName: 'HDFC Savings',
      accountType: 'bank',
    ),
    LinkedAccount(
      id: 'mock_paytm',
      provider: 'mock',
      accountName: 'Paytm Wallet',
      accountType: 'wallet',
    ),
  ];

  @override
  Future<List<LinkedAccount>> listLinkedAccounts() async {
    return List<LinkedAccount>.from(_accounts);
  }

  @override
  Future<void> connectAccount() async {
    // No-op for mock provider.
  }

  @override
  Future<void> disconnectAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);
  }
}
