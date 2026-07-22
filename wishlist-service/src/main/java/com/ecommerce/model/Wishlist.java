package com.ecommerce.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Data
@Document(collection = "wishlists")
public class Wishlist {

    @Id
    private String id;
    private String userId;
    private List<WishlistItem> items = new ArrayList<>();
}