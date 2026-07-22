package com.ecommerce.controller;

import com.ecommerce.model.Wishlist;
import com.ecommerce.model.WishlistItem;
import com.ecommerce.service.WishlistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/wishlist")
public class WishlistController {

    @Autowired
    private WishlistService wishlistService;

    @GetMapping("/{userId}")
    public ResponseEntity<Wishlist> getWishlist(@PathVariable String userId) {
        return ResponseEntity.ok(wishlistService.getWishlist(userId));
    }

    @PostMapping("/{userId}/add")
    public ResponseEntity<Wishlist> addToWishlist(@PathVariable String userId,
                                                   @RequestBody WishlistItem item) {
        return ResponseEntity.ok(wishlistService.addToWishlist(userId, item));
    }

    @DeleteMapping("/{userId}/remove/{productId}")
    public ResponseEntity<Wishlist> removeFromWishlist(@PathVariable String userId,
                                                        @PathVariable String productId) {
        return ResponseEntity.ok(wishlistService.removeFromWishlist(userId, productId));
    }

    @DeleteMapping("/{userId}/clear")
    public ResponseEntity<String> clearWishlist(@PathVariable String userId) {
        wishlistService.clearWishlist(userId);
        return ResponseEntity.ok("Wishlist cleared successfully");
    }
}