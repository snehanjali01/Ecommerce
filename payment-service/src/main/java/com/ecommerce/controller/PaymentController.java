package com.ecommerce.controller;

import com.ecommerce.model.Payment;
import com.ecommerce.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @PostMapping("/razorpay/create")
    public ResponseEntity<Payment> createRazorpayOrder(@RequestBody Payment payment) throws Exception {
        return ResponseEntity.ok(paymentService.createRazorpayOrder(payment));
    }

    @PostMapping("/razorpay/verify")
    public ResponseEntity<Payment> verifyPayment(@RequestBody Map<String, String> body) throws Exception {
        Payment payment = paymentService.verifyAndCompletePayment(
                body.get("paymentId"),
                body.get("razorpay_payment_id"),
                body.get("razorpay_order_id"),
                body.get("razorpay_signature")
        );
        return ResponseEntity.ok(payment);
    }

    @PostMapping
    public ResponseEntity<Payment> processPayment(@RequestBody Payment payment) {
        return ResponseEntity.ok(paymentService.processPayment(payment));
    }

    @GetMapping("/order/{orderId}")
    public ResponseEntity<Payment> getPaymentByOrderId(@PathVariable String orderId) {
        return ResponseEntity.ok(paymentService.getPaymentByOrderId(orderId));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Payment>> getPaymentsByUser(@PathVariable String userId) {
        return ResponseEntity.ok(paymentService.getPaymentsByUser(userId));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Payment> updateStatus(@PathVariable String id,
                                                @RequestParam String status) {
        return ResponseEntity.ok(paymentService.updatePaymentStatus(id, status));
    }
}