package com.ecommerce.model;

import lombok.Data;

@Data
public class CartItem{
    private String productId;
    private String productName;
    private double price;
    private int quantity;
    private double totalPrice;
}