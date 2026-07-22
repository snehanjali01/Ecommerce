class RazorpayWeb {
  static void open({
    required String key,
    required int amount,
    required String orderId,
    required String name,
    required String description,
    required String email,
    required Function(String paymentId, String orderId, String signature) onSuccess,
    required Function(String error) onError,
  }) {
    onError('Web checkout not available on this platform');
  }
}