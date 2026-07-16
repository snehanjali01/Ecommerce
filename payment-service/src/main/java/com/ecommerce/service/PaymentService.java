package com.ecommerce.service;

import com.ecommerce.model.Payment;
import com.ecommerce.repository.PaymentRepository;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.Utils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class PaymentService {

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private RazorpayClient razorpayClient;

    @Value("${razorpay.key.secret}")
    private String keySecret;

    public Payment createRazorpayOrder(Payment payment) throws Exception {
        JSONObject orderRequest = new JSONObject();
        orderRequest.put("amount", (int) (payment.getAmount() * 100));
        orderRequest.put("currency", "INR");
        orderRequest.put("receipt", payment.getOrderId());

        Order razorpayOrder = razorpayClient.orders.create(orderRequest);

        payment.setRazorpayOrderId(razorpayOrder.get("id"));
        payment.setStatus("CREATED");
        payment.setMethod("RAZORPAY");

        return paymentRepository.save(payment);
    }

    public Payment verifyAndCompletePayment(String paymentId, String razorpayPaymentId,
                                             String razorpayOrderId, String razorpaySignature) throws Exception {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));

        JSONObject options = new JSONObject();
        options.put("razorpay_order_id", razorpayOrderId);
        options.put("razorpay_payment_id", razorpayPaymentId);
        options.put("razorpay_signature", razorpaySignature);

        boolean isValid = Utils.verifyPaymentSignature(options, keySecret);

        if (isValid) {
            payment.setStatus("SUCCESS");
            payment.setRazorpayPaymentId(razorpayPaymentId);
            payment.setRazorpaySignature(razorpaySignature);
        } else {
            payment.setStatus("FAILED");
        }

        return paymentRepository.save(payment);
    }

    public Payment processPayment(Payment payment) {
        payment.setStatus("SUCCESS");
        return paymentRepository.save(payment);
    }

    public Payment getPaymentByOrderId(String orderId) {
        return paymentRepository.findByOrderId(orderId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
    }

    public List<Payment> getPaymentsByUser(String userId) {
        return paymentRepository.findByUserId(userId);
    }

    public Payment updatePaymentStatus(String id, String status) {
        Payment payment = paymentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
        payment.setStatus(status);
        return paymentRepository.save(payment);
    }
}
        