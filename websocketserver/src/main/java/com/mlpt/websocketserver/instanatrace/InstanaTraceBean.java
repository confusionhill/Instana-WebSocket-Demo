package com.mlpt.websocketserver.instanatrace;

import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
@Setter
@Getter
public class InstanaTraceBean {
    private String spanId;
    private String parentId;
    private String traceId;
    private Long timestamp;
    private Long  duration;
    private String name;
    private String type;
    private String error;

    @Autowired
    private InstanaTraceBeanData data;
}
