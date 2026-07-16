package com.ecommerce.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Document(collection = "orders")
public class Order {

    @Id
    private String id;
    private String userId;
    private List<OrderItem> items;
    private double totalAmount;
    private String status = "PLACED";
    private String address;
    private String paymentMethod = "COD";
    private LocalDateTime createdAt = LocalDateTime.now();
    private List<TrackingEvent> trackingHistory = new ArrayList<>();
}