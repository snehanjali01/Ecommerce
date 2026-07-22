package com.ecommerce.model;

import lombok.Data;

@Data
public class WishlistItem {
    private String productId;
    private String productName;
    private double price;
    private String imageUrl;
    private String category;
}