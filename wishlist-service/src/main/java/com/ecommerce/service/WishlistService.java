package com.ecommerce.service;

import com.ecommerce.model.Wishlist;
import com.ecommerce.model.WishlistItem;
import com.ecommerce.repository.WishlistRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class WishlistService {

    @Autowired
    private WishlistRepository wishlistRepository;

    public Wishlist getWishlist(String userId) {
        return wishlistRepository.findByUserId(userId)
                .orElse(new Wishlist());
    }

    public Wishlist addToWishlist(String userId, WishlistItem item) {
        Wishlist wishlist = wishlistRepository.findByUserId(userId)
                .orElse(new Wishlist());
        wishlist.setUserId(userId);

        boolean exists = wishlist.getItems().stream()
                .anyMatch(i -> i.getProductId().equals(item.getProductId()));

        if (!exists) {
            wishlist.getItems().add(item);
        }

        return wishlistRepository.save(wishlist);
    }

    public Wishlist removeFromWishlist(String userId, String productId) {
        Wishlist wishlist = wishlistRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Wishlist not found"));
        wishlist.getItems().removeIf(i -> i.getProductId().equals(productId));
        return wishlistRepository.save(wishlist);
    }

    public void clearWishlist(String userId) {
        Wishlist wishlist = wishlistRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Wishlist not found"));
        wishlist.getItems().clear();
        wishlistRepository.save(wishlist);
    }
}