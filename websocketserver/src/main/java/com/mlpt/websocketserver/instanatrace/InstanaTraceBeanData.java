package com.mlpt.websocketserver.instanatrace;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.springframework.stereotype.Component;

@Component
@Setter
@Getter
public class InstanaTraceBeanData {
    @JsonProperty("username")
    private String username;

    @JsonProperty("http.url")
    private String url;

    @JsonProperty("http.status_code")
    private String statusCode;

    @JsonProperty("description")
    private String description;

    @JsonProperty("error_string")
    private String errorString;
}
