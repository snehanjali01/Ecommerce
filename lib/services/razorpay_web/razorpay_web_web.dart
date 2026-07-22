import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('Razorpay')
external JSFunction? get _razorpayConstructor;

extension type _RazorpayInstance(JSObject _) implements JSObject {
  external void open();
}

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
    _waitForRazorpayThenOpen(
      key: key,
      amount: amount,
      orderId: orderId,
      name: name,
      description: description,
      email: email,
      onSuccess: onSuccess,
      onError: onError,
      attemptsLeft: 150,
    );
  }

  static void _waitForRazorpayThenOpen({
    required String key,
    required int amount,
    required String orderId,
    required String name,
    required String description,
    required String email,
    required Function(String paymentId, String orderId, String signature) onSuccess,
    required Function(String error) onError,
    required int attemptsLeft,
  }) {
    final ctor = _razorpayConstructor;

    if (ctor != null) {
      _openCheckout(
        ctor: ctor,
        key: key,
        amount: amount,
        orderId: orderId,
        name: name,
        description: description,
        email: email,
        onSuccess: onSuccess,
        onError: onError,
      );
      return;
    }

    if (attemptsLeft <= 0) {
      onError(
          'Razorpay script failed to load after waiting. Check your internet connection and try again.');
      return;
    }

    Timer(const Duration(milliseconds: 200), () {
      _waitForRazorpayThenOpen(
        key: key,
        amount: amount,
        orderId: orderId,
        name: name,
        description: description,
        email: email,
        onSuccess: onSuccess,
        onError: onError,
        attemptsLeft: attemptsLeft - 1,
      );
    });
  }

  static void _openCheckout({
    required JSFunction ctor,
    required String key,
    required int amount,
    required String orderId,
    required String name,
    required String description,
    required String email,
    required Function(String paymentId, String orderId, String signature) onSuccess,
    required Function(String error) onError,
  }) {
    try {
      final options = JSObject();
      options.setProperty('key'.toJS, key.toJS);
      options.setProperty('amount'.toJS, amount.toJS);
      options.setProperty('order_id'.toJS, orderId.toJS);
      options.setProperty('name'.toJS, name.toJS);
      options.setProperty('description'.toJS, description.toJS);

      final prefill = JSObject();
      prefill.setProperty('email'.toJS, email.toJS);
      options.setProperty('prefill'.toJS, prefill);

      final handler = ((JSObject response) {
        try {
          final paymentId =
              (response.getProperty('razorpay_payment_id'.toJS) as JSString).toDart;
          final razorpayOrderId =
              (response.getProperty('razorpay_order_id'.toJS) as JSString).toDart;
          final signature =
              (response.getProperty('razorpay_signature'.toJS) as JSString).toDart;
          onSuccess(paymentId, razorpayOrderId, signature);
        } catch (e) {
          onError('Handler error: $e');
        }
      }).toJS;
      options.setProperty('handler'.toJS, handler);

      final modal = JSObject();
      final onDismiss = (() {
        onError('Payment cancelled by user');
      }).toJS;
      modal.setProperty('ondismiss'.toJS, onDismiss);
      options.setProperty('modal'.toJS, modal);

      final rzp = ctor.callAsConstructor<_RazorpayInstance>(options);
      rzp.open();
    } catch (e) {
      onError('Web checkout error: $e');
    }
  }
}