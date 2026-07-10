# Competitive landscape

Research completed July 10, 2026.

## Bottom line

Animated emoji and GIF keyboards already exist, but no current iPhone product found in this pass is explicitly positioned around curated reaction GIFs intentionally kept near large-emoji size to preserve conversation space. That positioning appears meaningfully differentiated.

## Closest products

- [Gifmoji](https://apps.apple.com/us/app/gifmoji-emoji-animated-gif-keyboard/id917420423) mixes animated emoji with curated GIFs. It is the closest naming and concept precedent, but its listing is stale and does not promise compact transcript sizing.
- [AIKeyMoji](https://apps.apple.com/us/app/aikeymoji-ai-sticker-keyboard/id6767867186) is a newer animated-sticker keyboard with built-in animated emoji. Its focus is animated sticker creation and selection rather than compact reaction GIFs.
- [Animated Emoji 3D Sticker GIF](https://apps.apple.com/us/app/animated-emoji-3d-sticker-gif/id624554947) provides animated emojis and talking clips, with a larger-is-more-expressive direction.
- [Dynamojis](https://apps.apple.com/us/app/dynamojis-animated-gif-emojis/id1047118525) composes text and animated faces into GIFs rather than focusing on compact reactions.
- [Tenor GIF Keyboard](https://apps.apple.com/us/app/gif-keyboard/id917932200) is the broad incumbent for GIF search and stickers, but standard GIFs remain visually large.

## Product caveat

iOS custom keyboards generally put image data on the pasteboard for users to paste into the receiving app. The receiving app can influence final display size, so the product should not promise exact universal emoji sizing before it has been tested in Messages, WhatsApp, Telegram, and other targets.

Primary references:

- [Apple Custom Keyboard Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
- [UIPasteboard documentation](https://developer.apple.com/documentation/uikit/uipasteboard)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

Apple review guideline 4.4.1 is relevant to image keyboard extensions: the keyboard must include keyboard input, provide a next-keyboard mechanism, and remain useful without unrestricted network access.

