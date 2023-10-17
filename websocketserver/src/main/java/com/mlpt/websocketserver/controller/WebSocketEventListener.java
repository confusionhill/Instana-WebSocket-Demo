package com.mlpt.websocketserver.controller;

import com.mlpt.websocketserver.instanatrace.InstanaTraceSend;
import com.mlpt.websocketserver.model.ChatMessage;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

@Component
public class WebSocketEventListener {
    private static final Logger logger = LoggerFactory.getLogger(WebSocketEventListener.class);

    private final int intOnlineStatus = 1;
    Gauge wsCurrentOnlineGauge;
    private int intCurrentConnectedClients = 0;
    Gauge wsCurrentConnectedClientsGauge;
    public WebSocketEventListener(MeterRegistry registry) {
        wsCurrentOnlineGauge = Gauge.builder("current_online_status", () -> intOnlineStatus)
                .description("Websocket Online Status")
                .register(registry);
        wsCurrentConnectedClientsGauge = Gauge.builder("current_connected_clients", () -> intCurrentConnectedClients)
                .description("Number of Clients Connected")
                .register(registry);
    }

    @Autowired
    private SimpMessageSendingOperations sendingOperations;

    @Autowired
    private InstanaTraceSend instanaTraceSend;

    @EventListener
    public void handleWebSocketConnectListener(final SessionConnectedEvent event) {
        logger.info("A Client connected");
        intCurrentConnectedClients++;
    }

    @EventListener
    public void handleWebSocketDisconnectlistener(final SessionDisconnectEvent event) {
        Long epochStart = System.currentTimeMillis();

        logger.info("A Client disconnected");
        intCurrentConnectedClients--;
        final StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        final String username = (String) headerAccessor.getSessionAttributes().get("username");
        final int closeStatus = event.getCloseStatus().getCode();

        if (username != null) {
            final ChatMessage chatMessage = new ChatMessage("", username, epochStart,ChatMessage.MessageType.LEAVE);
            sendingOperations.convertAndSend("/topic/public", chatMessage);

            Long epochEnd = System.currentTimeMillis();
            Long epochDuration = epochEnd - epochStart;

            if (closeStatus == 1000) {
                instanaTraceSend.sendTrace(
                        "client_disconnected",
                        epochDuration,
                        epochStart,
                        "false",
                        chatMessage.getSender(),
                        ""
                );
            } else {
                instanaTraceSend.sendTrace(
                        "client_disconnected",
                        epochDuration,
                        epochStart,
                        "true",
                        chatMessage.getSender(),
                        event.getCloseStatus().toString()
                );
            }
        }
    }
}
