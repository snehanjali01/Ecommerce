package com.ecommerce.service;

import com.ecommerce.model.Order;
import com.ecommerce.model.TrackingEvent;
import com.ecommerce.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    public Order placeOrder(Order order) {
        order.setStatus("PLACED");
        double total = order.getItems().stream()
                .mapToDouble(item -> item.getPrice() * item.getQuantity())
                .sum();
        order.setTotalAmount(total);
        order.getItems().forEach(item ->
                item.setTotalPrice(item.getPrice() * item.getQuantity()));

        order.getTrackingHistory().add(
                new TrackingEvent("PLACED", "Your order has been placed", null));

        return orderRepository.save(order);
    }

    public List<Order> getOrdersByUser(String userId) {
        return orderRepository.findByUserId(userId);
    }

    public Order getOrderById(String id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));
    }

    public Order updateStatus(String id, String status) {
        Order order = getOrderById(id);
        order.setStatus(status);

        String description = switch (status) {
            case "CONFIRMED" -> "Your order has been confirmed";
            case "SHIPPED" -> "Your order has been shipped";
            case "OUT_FOR_DELIVERY" -> "Your order is out for delivery";
            case "DELIVERED" -> "Your order has been delivered";
            case "CANCELLED" -> "Your order has been cancelled";
            default -> "Order status updated to " + status;
        };

        order.getTrackingHistory().add(new TrackingEvent(status, description, null));
        return orderRepository.save(order);
    }

    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }
}