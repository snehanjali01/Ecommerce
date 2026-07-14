package com.ecommerce;

import org.springframework.cloud.gateway.server.mvc.handler.GatewayRouterFunctions;
import org.springframework.cloud.gateway.server.mvc.handler.HandlerFunctions;
import org.springframework.cloud.gateway.server.mvc.filter.LoadBalancerFilterFunctions;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.function.RouterFunction;
import org.springframework.web.servlet.function.ServerResponse;

@Configuration
public class GatewayConfig {

    @Bean
    public RouterFunction<ServerResponse> userServiceRoute() {
        return GatewayRouterFunctions.route("user-service")
                .GET("/api/users/**", HandlerFunctions.http())
                .POST("/api/users/**", HandlerFunctions.http())
                .filter(LoadBalancerFilterFunctions.lb("USER-SERVICE"))
                .build();
    }

    @Bean
    public RouterFunction<ServerResponse> productServiceRoute() {
        return GatewayRouterFunctions.route("product-service")
                .GET("/api/products/**", HandlerFunctions.http())
                .POST("/api/products/**", HandlerFunctions.http())
                .PUT("/api/products/**", HandlerFunctions.http())
                .DELETE("/api/products/**", HandlerFunctions.http())
                .filter(LoadBalancerFilterFunctions.lb("PRODUCT-SERVICE"))
                .build();
    }
    
    
    @Bean
    public RouterFunction<ServerResponse> cartServiceRoute() {
        return GatewayRouterFunctions.route("cart-service")
                .GET("/api/cart/**", HandlerFunctions.http())
                .POST("/api/cart/**", HandlerFunctions.http())
                .PUT("/api/cart/**", HandlerFunctions.http())
                .DELETE("/api/cart/**", HandlerFunctions.http())
                .filter(LoadBalancerFilterFunctions.lb("CART-SERVICE"))
                .build();
    }
    
    @Bean
    public RouterFunction<ServerResponse> orderServiceRoute() {
        return GatewayRouterFunctions.route("order-service")
                .GET("/api/orders/**", HandlerFunctions.http())
                .POST("/api/orders/**", HandlerFunctions.http())
                .PUT("/api/orders/**", HandlerFunctions.http())
                .DELETE("/api/orders/**", HandlerFunctions.http())
                .filter(LoadBalancerFilterFunctions.lb("ORDER-SERVICE"))
                .build();
    }
    
    
    @Bean
    public RouterFunction<ServerResponse> paymentServiceRoute() {
        return GatewayRouterFunctions.route("payment-service")
                .GET("/api/payments/**", HandlerFunctions.http())
                .POST("/api/payments/**", HandlerFunctions.http())
                .PUT("/api/payments/**", HandlerFunctions.http())
                .filter(LoadBalancerFilterFunctions.lb("PAYMENT-SERVICE"))
                .build();
    }
    
    @Bean
    public RouterFunction<ServerResponse> wishlistServiceRoute() {
        return GatewayRouterFunctions.route("wishlist-service")
                .GET("/api/wishlist/**", HandlerFunctions.http())
                .POST("/api/wishlist/**", HandlerFunctions.http())
                .DELETE("/api/wishlist/**", HandlerFunctions.http())
                .filter(LoadBalancerFilterFunctions.lb("WISHLIST-SERVICE"))
                .build();
    }
    
    
    
    
    
    
}