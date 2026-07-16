package com.ecommerce.model;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TrackingEvent {
    private String status;
    private String description;
    private LocalDateTime timestamp = LocalDateTime.now();
}