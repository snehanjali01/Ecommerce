package com.ecommerce.controller;

import com.ecommerce.model.AuthRequest;
import com.ecommerce.model.AuthResponse;
import com.ecommerce.model.User;
import com.ecommerce.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/register")
    public ResponseEntity<User> register(@RequestBody User user) {
        return ResponseEntity.ok(userService.registerUser(user));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest request) {
        String token = userService.loginUser(request.getEmail(), request.getPassword());
        User user = userService.findByEmail(request.getEmail());
        return ResponseEntity.ok(new AuthResponse(token, user.getEmail(), user.getRole()));
    }

    @GetMapping("/test")
    public ResponseEntity<String> test() {
        return ResponseEntity.ok("User Service is running!");
    }
}