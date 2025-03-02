import 'package:flutter/material.dart';

/// Base AppTheme class with all properties
class AppTheme {
  final Color backgroundColor;
  final Color appBarColor;
  final Color textFieldBackgroundColor;
  final Color sendButtonColor;
  final Color incomingChatBubbleColor;
  final Color outgoingChatBubbleColor;
  final Color appBarTitleTextStyle;
  final Color themeIconColor;
  final Color flashingCircleBrightColor;
  final Color flashingCircleDarkColor;
  final Color backArrowColor;
  final Color messageTimeIconColor;
  final Color messageTimeTextColor;
  final Color chatHeaderColor;
  final Color cameraIconColor;
  final Color galleryIconColor;
  final Color replyMessageColor;
  final Color replyDialogColor;
  final Color replyTitleColor;
  final Color closeIconColor;
  final Color textFieldTextColor;
  final Color waveformBackgroundColor;
  final Color recordIconColor;
  final Color waveColor;
  final Color linkPreviewOutgoingChatColor;
  final TextStyle outgoingChatLinkBodyStyle;
  final TextStyle outgoingChatLinkTitleStyle;
  final Color linkPreviewIncomingChatColor;
  final TextStyle incomingChatLinkBodyStyle;
  final TextStyle incomingChatLinkTitleStyle;
  final Color replyPopupColor;
  final Color replyPopupButtonColor;
  final Color replyPopupTopBorderColor;
  final Color reactionPopupColor;
  final Color messageReactionBackGroundColor;
  final Color shareIconBackgroundColor;
  final Color shareIconColor;
  final Color repliedMessageColor;
  final Color verticalBarColor;
  final Color repliedTitleTextColor;
  final Color swipeToReplyIconColor;
  final Color replyMicIconColor;
  final Color inComingChatBubbleTextColor; // Missing properties
  final Color inComingChatBubbleColor;    // Missing properties
  final double elevation;

  AppTheme({
    required this.backgroundColor,
    required this.appBarColor,
    required this.textFieldBackgroundColor,
    required this.sendButtonColor,
    required this.incomingChatBubbleColor,
    required this.outgoingChatBubbleColor,
    required this.appBarTitleTextStyle,
    required this.themeIconColor,
    required this.flashingCircleBrightColor,
    required this.flashingCircleDarkColor,
    required this.backArrowColor,
    required this.messageTimeIconColor,
    required this.messageTimeTextColor,
    required this.chatHeaderColor,
    required this.cameraIconColor,
    required this.galleryIconColor,
    required this.replyMessageColor,
    required this.replyDialogColor,
    required this.replyTitleColor,
    required this.closeIconColor,
    required this.textFieldTextColor,
    required this.waveformBackgroundColor,
    required this.recordIconColor,
    required this.waveColor,
    required this.linkPreviewOutgoingChatColor,
    required this.outgoingChatLinkBodyStyle,
    required this.outgoingChatLinkTitleStyle,
    required this.linkPreviewIncomingChatColor,
    required this.incomingChatLinkBodyStyle,
    required this.incomingChatLinkTitleStyle,
    required this.replyPopupColor,
    required this.replyPopupButtonColor,
    required this.replyPopupTopBorderColor,
    required this.reactionPopupColor,
    required this.messageReactionBackGroundColor,
    required this.shareIconBackgroundColor,
    required this.shareIconColor,
    required this.repliedMessageColor,
    required this.verticalBarColor,
    required this.repliedTitleTextColor,
    required this.swipeToReplyIconColor,
    required this.replyMicIconColor,
    required this.inComingChatBubbleTextColor,
    required this.inComingChatBubbleColor,
    required this.elevation,
  });
}

/// LightTheme implementation
class LightTheme extends AppTheme {
  LightTheme()
      : super(
    backgroundColor: Colors.white,
    appBarColor: Colors.blue,
    textFieldBackgroundColor: Colors.grey.shade200,
    sendButtonColor: Colors.blue,
    incomingChatBubbleColor: Colors.grey.shade300,
    outgoingChatBubbleColor: Colors.blue.shade400,
    appBarTitleTextStyle: Colors.white,
    themeIconColor: Colors.black,
    flashingCircleBrightColor: Colors.green,
    flashingCircleDarkColor: Colors.greenAccent,
    backArrowColor: Colors.white,
    messageTimeIconColor: Colors.grey,
    messageTimeTextColor: Colors.black,
    chatHeaderColor: Colors.grey,
    cameraIconColor: Colors.blue,
    galleryIconColor: Colors.blue,
    replyMessageColor: Colors.blue.shade50,
    replyDialogColor: Colors.white,
    replyTitleColor: Colors.black,
    closeIconColor: Colors.black,
    textFieldTextColor: Colors.black,
    waveformBackgroundColor: Colors.grey.shade300,
    recordIconColor: Colors.red,
    waveColor: Colors.blue,
    linkPreviewOutgoingChatColor: Colors.blue.shade100,
    outgoingChatLinkBodyStyle: const TextStyle(color: Colors.black),
    outgoingChatLinkTitleStyle: const TextStyle(color: Colors.black),
    linkPreviewIncomingChatColor: Colors.grey.shade200,
    incomingChatLinkBodyStyle: const TextStyle(color: Colors.black),
    incomingChatLinkTitleStyle: const TextStyle(color: Colors.black),
    replyPopupColor: Colors.white,
    replyPopupButtonColor: Colors.blue,
    replyPopupTopBorderColor: Colors.blue.shade300,
    reactionPopupColor: Colors.white,
    messageReactionBackGroundColor: Colors.blue.shade200,
    shareIconBackgroundColor: Colors.blue,
    shareIconColor: Colors.white,
    repliedMessageColor: Colors.grey.shade200,
    verticalBarColor: Colors.blue,
    repliedTitleTextColor: Colors.black,
    swipeToReplyIconColor: Colors.blue,
    replyMicIconColor: Colors.blue,
    inComingChatBubbleTextColor: Colors.black,
    inComingChatBubbleColor: Colors.grey.shade300,
    elevation: 4.0,
  );
}

/// DarkTheme implementation
class DarkTheme extends AppTheme {
  DarkTheme()
      : super(
    backgroundColor: Colors.black,
    appBarColor: Colors.grey.shade900,
    textFieldBackgroundColor: Colors.grey.shade800,
    sendButtonColor: Colors.blueAccent,
    incomingChatBubbleColor: Colors.grey.shade700,
    outgoingChatBubbleColor: Colors.blue,
    appBarTitleTextStyle: Colors.white,
    themeIconColor: Colors.white,
    flashingCircleBrightColor: Colors.lightGreen,
    flashingCircleDarkColor: Colors.green,
    backArrowColor: Colors.white,
    messageTimeIconColor: Colors.grey.shade400,
    messageTimeTextColor: Colors.white,
    chatHeaderColor: Colors.white,
    cameraIconColor: Colors.blue,
    galleryIconColor: Colors.blue,
    replyMessageColor: Colors.blue.shade100,
    replyDialogColor: Colors.grey.shade900,
    replyTitleColor: Colors.white,
    closeIconColor: Colors.white,
    textFieldTextColor: Colors.white,
    waveformBackgroundColor: Colors.grey.shade700,
    recordIconColor: Colors.red,
    waveColor: Colors.blue,
    linkPreviewOutgoingChatColor: Colors.blue.shade200,
    outgoingChatLinkBodyStyle: const TextStyle(color: Colors.white),
    outgoingChatLinkTitleStyle: const TextStyle(color: Colors.white),
    linkPreviewIncomingChatColor: Colors.grey.shade700,
    incomingChatLinkBodyStyle: const TextStyle(color: Colors.white),
    incomingChatLinkTitleStyle: const TextStyle(color: Colors.white),
    replyPopupColor: Colors.grey.shade800,
    replyPopupButtonColor: Colors.blue,
    replyPopupTopBorderColor: Colors.blue.shade600,
    reactionPopupColor: Colors.grey.shade900,
    messageReactionBackGroundColor: Colors.blue.shade300,
    shareIconBackgroundColor: Colors.blue,
    shareIconColor: Colors.white,
    repliedMessageColor: Colors.grey.shade600,
    verticalBarColor: Colors.blue,
    repliedTitleTextColor: Colors.white,
    swipeToReplyIconColor: Colors.blue,
    replyMicIconColor: Colors.white,
    inComingChatBubbleTextColor: Colors.white,
    inComingChatBubbleColor: Colors.grey.shade700,
    elevation: 4.0,
  );
}
