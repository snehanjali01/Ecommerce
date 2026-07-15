package com.ecommerce.service;

import com.ecommerce.model.Cart;
import com.ecommerce.model.CartItem;
import com.ecommerce.repository.CartRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Optional;

@Service
public class CartService {

    @Autowired
    private CartRepository cartRepository;

    public Cart getCart(String userId){
        return cartRepository.findByUserId(userId)
                .orElse(new Cart());
    }

    public Cart addToCart(String userId, CartItem item) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElse(new Cart());
        cart.setUserId(userId);

        item.setTotalPrice(item.getPrice() * item.getQuantity());

        Optional<CartItem> existing = cart.getItems().stream()
                .filter(i -> i.getProductId().equals(item.getProductId()))
                .findFirst();

        if (existing.isPresent()) {
            existing.get().setQuantity(existing.get().getQuantity() + item.getQuantity());
            existing.get().setTotalPrice(existing.get().getPrice() * existing.get().getQuantity());
        } else {
            cart.getItems().add(item);
        }

        cart.calculateTotal();
        return cartRepository.save(cart);
    }

    public Cart removeFromCart(String userId, String productId) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        cart.getItems().removeIf(i -> i.getProductId().equals(productId));
        cart.calculateTotal();
        return cartRepository.save(cart);
    }

    public Cart updateQuantity(String userId, String productId, int quantity) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        cart.getItems().stream()
                .filter(i -> i.getProductId().equals(productId))
                .findFirst()
                .ifPresent(i -> {
                    i.setQuantity(quantity);
                    i.setTotalPrice(i.getPrice() * quantity);
                });
        cart.calculateTotal();
        return cartRepository.save(cart);
    }

    public void clearCart(String userId) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        cart.getItems().clear();
        cart.setTotalAmount(0);
        cartRepository.save(cart);
    }
}