package com.mlpt.websocketserver.controller;

import com.mlpt.websocketserver.instanatrace.InstanaTraceSend;
import com.mlpt.websocketserver.model.ChatMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.stereotype.Controller;

@Controller
public class ChatController {
    private static final Logger logger = LoggerFactory.getLogger(WebSocketEventListener.class);

    @Autowired
    private InstanaTraceSend instanaTraceSend;

    @MessageMapping("/chat.register")
    @SendTo("/topic/public")
    public ChatMessage register(@Payload ChatMessage chatMessage, SimpMessageHeaderAccessor headerAccessor) {
        Long epochStart = chatMessage.getTimestamp();
        headerAccessor.getSessionAttributes().put("username", chatMessage.getSender());

        Long epochEnd = System.currentTimeMillis();
        Long epochDuration = epochEnd - epochStart;
        instanaTraceSend.sendTrace(
                "user_connected",
                epochDuration,
                epochStart,
                "false",
                chatMessage.getSender(),
                ""
        );

        chatMessage.setTimestamp(System.currentTimeMillis());

        return chatMessage;
    }

    @MessageMapping("/chat.send")
    @SendTo("/topic/public")
    public ChatMessage sendMessage(@Payload ChatMessage chatMessage) {
        Long epochStart = chatMessage.getTimestamp();
        Long epochEnd = System.currentTimeMillis();
        Long epochDuration = epochEnd - epochStart;

        logger.info("epochStart : " + epochStart + "   " + " epochEnd: " + epochEnd);

        instanaTraceSend.sendTrace(
                "chat_received",
                epochDuration,
                epochStart,
                "false",
                chatMessage.getSender(),
                ""
        );

        chatMessage.setTimestamp(System.currentTimeMillis());

        logger.info(String.valueOf(System.currentTimeMillis()));

        return chatMessage;
    }
}
