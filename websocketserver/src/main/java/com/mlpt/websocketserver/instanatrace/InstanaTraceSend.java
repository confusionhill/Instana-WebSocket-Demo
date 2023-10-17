package com.mlpt.websocketserver.instanatrace;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mlpt.websocketserver.controller.WebSocketEventListener;
import lombok.Getter;
import lombok.Setter;
import okhttp3.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Objects;

@Component
public class InstanaTraceSend {
    private static final Logger logger = LoggerFactory.getLogger(WebSocketEventListener.class);

    @Autowired
    private InstanaTraceBean instanaTraceBean;

    public void sendTrace(
            String name,
            Long epochDuration,
            Long epochStart,
            String error,
            String username,
            String errorString
    ) {
        // Build Instana tracing beans
        instanaTraceBean.setName(name);
        instanaTraceBean.setDuration(epochDuration);
        instanaTraceBean.setTraceId("ws-trace");
        instanaTraceBean.setSpanId("ws-span");
        instanaTraceBean.setParentId("");
        instanaTraceBean.setType("ENTRY");
        instanaTraceBean.setTimestamp(epochStart);
        instanaTraceBean.setError(error);

        InstanaTraceBeanData data = new InstanaTraceBeanData();
        data.setUrl("Websocket");
        data.setUsername(username);
        data.setDescription(name);
        data.setErrorString(errorString);

        if (Objects.equals(error, "true")) {
            data.setStatusCode("500");
        } else {
            data.setStatusCode("200");
        }


        instanaTraceBean.setData(data);

        ObjectMapper mapper = new ObjectMapper();
        try {
            OkHttpClient client = new OkHttpClient().newBuilder().build();
            MediaType mediaType = MediaType.parse("application/json");
//            RequestBody body = RequestBody.create(mapper.writeValueAsString(instanaTraceBean), mediaType);
            RequestBody body = RequestBody.create(mediaType, mapper.writeValueAsString(instanaTraceBean));

            logger.info(mapper.writeValueAsString(instanaTraceBean));
            Request request = new Request.Builder()
                    .url("http://localhost:42699/com.instana.plugin.generic.trace")
                    .method("POST", body)
                    .addHeader("Content-Type", "application/json")
                    .build();
            Response response = client.newCall(request).execute();
        } catch (JsonProcessingException e) {
            logger.error("JSON Processing Error: " + e.toString());
        } catch (IOException e) {
            logger.error("IO Error connecting Instana agent host: " + e.toString());
        }
    }
}
