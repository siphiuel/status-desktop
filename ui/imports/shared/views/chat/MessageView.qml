import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.popups 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Loader {
    id: root

    property var rootStore
    property var messageStore
    property var usersStore
    property var contactsStore
    property var messageContextMenu: null
    property string channelEmoji
    property bool isActiveChannel: false

    property var chatLogView
    property var emojiPopup
    property var stickersPopup

    // Once we redo qml we will know all section/chat related details in each message form the parent components
    // without an explicit need to fetch those details via message store/module.
    property bool isChatBlocked: false

    property string messageId: ""
    property string communityId: ""

    property string senderId: ""
    property string senderDisplayName: ""
    property string senderOptionalName: ""
    property bool senderIsEnsVerified: false
    property string senderIcon: ""
    //TODO: provide the sender color hash from nim model in case of ContactVerificationRequest, OngoingContactVerificationRequest or PinnedMessagesPopupremove
    property var senderColorHash:  senderId != "" ? Utils.getColorHashAsJson(senderId, senderIsEnsVerified) : ""
    property bool amISender: false
    property bool amIChatAdmin: messageStore && messageStore.amIChatAdmin
    property bool senderIsAdded: false
    property int senderTrustStatus: Constants.trustStatus.unknown
    property string messageText: ""
    property string unparsedText: ""
    property string messageImage: ""
    property double messageTimestamp: 0 // We use double, because QML's int is too small
    property string messageOutgoingStatus: ""
    property string resendError: ""
    property int messageContentType: Constants.messageContentType.messageType

    property bool pinnedMessage: false
    property string messagePinnedBy: ""
    property var reactionsModel: []
    property string linkUrls: ""
    property string messageAttachments: ""
    property var transactionParams

    property string responseToMessageWithId: ""
    property string quotedMessageText: ""
    property string quotedMessageFrom: ""
    property int quotedMessageContentType: Constants.messageContentType.messageType
    property int quotedMessageFromIterator: -1
    property bool quotedMessageDeleted: false
    property string quotedMessageAuthorDetailsName: ""
    property string quotedMessageAuthorDetailsDisplayName: ""
    property string quotedMessageAuthorDetailsThumbnailImage: ""
    property bool quotedMessageAuthorDetailsEnsVerified: false
    property bool quotedMessageAuthorDetailsIsContact: false
    property var quotedMessageAuthorDetailsColorHash

    property var album: []
    property int albumCount: 0

    // External behavior changers
    property bool isInPinnedPopup: false // The pinned popup limits the number of buttons shown
    property bool disableHover: false // Used to force the HoverHandler to be active (useful for messages in popups)
    property bool placeholderMessage: false

    property int gapFrom: 0
    property int gapTo: 0

    property int prevMessageIndex: -1
    property int prevMessageContentType: prevMessageAsJsonObj ? prevMessageAsJsonObj.contentType : Constants.messageContentType.unknownContentType
    property double prevMessageTimestamp: prevMessageAsJsonObj ? prevMessageAsJsonObj.timestamp : 0
    property string prevMessageSenderId: prevMessageAsJsonObj ? prevMessageAsJsonObj.senderId : ""
    property var prevMessageAsJsonObj
    property int nextMessageIndex: -1
    property double nextMessageTimestamp: nextMessageAsJsonObj ? nextMessageAsJsonObj.timestamp : 0
    property var nextMessageAsJsonObj

    property bool editModeOn: false
    property bool isEdited: false

    property bool shouldRepeatHeader: d.getShouldRepeatHeader(messageTimestamp, prevMessageTimestamp, messageOutgoingStatus)

    property bool hasMention: false

    property bool stickersLoaded: false
    property string sticker
    property int stickerPack: -1

    property bool isEmoji: messageContentType === Constants.messageContentType.emojiType
    property bool isImage: messageContentType === Constants.messageContentType.imageType || (isDiscordMessage && messageImage != "")
    property bool isAudio: messageContentType === Constants.messageContentType.audioType
    property bool isStatusMessage: messageContentType === Constants.messageContentType.systemMessagePrivateGroupType
    property bool isSticker: messageContentType === Constants.messageContentType.stickerType
    property bool isDiscordMessage: messageContentType === Constants.messageContentType.discordMessageType
    property bool isText: messageContentType === Constants.messageContentType.messageType || messageContentType === Constants.messageContentType.contactRequestType || isDiscordMessage
    property bool isMessage: isEmoji || isImage || isSticker || isText || isAudio
                             || messageContentType === Constants.messageContentType.communityInviteType || messageContentType === Constants.messageContentType.transactionType

    readonly property bool isExpired: d.getIsExpired(messageTimestamp, messageOutgoingStatus)
    readonly property bool isSending: messageOutgoingStatus === Constants.sending && !isExpired

    signal imageClicked(var image)

    // WARNING: To much arguments here. Create an object argument.
    property var messageClickHandler: function(sender, point,
                                               isProfileClick,
                                               isSticker = false,
                                               isImage = false,
                                               image = null,
                                               isEmoji = false,
                                               hideEmojiPicker = false,
                                               isReply = false,
                                               isRightClickOnImage = false,
                                               imageSource = "") {

        if (placeholderMessage || !(root.rootStore.mainModuleInst.activeSection.joined || isProfileClick)) {
            return false
        }

        messageContextMenu.myPublicKey = userProfile.pubKey
        messageContextMenu.amIChatAdmin = root.amIChatAdmin
        messageContextMenu.pinMessageAllowedForMembers = messageStore.isPinMessageAllowedForMembers
        messageContextMenu.chatType = messageStore.chatType

        messageContextMenu.messageId = root.messageId
        messageContextMenu.unparsedText = root.unparsedText
        messageContextMenu.messageSenderId = root.senderId
        messageContextMenu.messageContentType = root.messageContentType
        messageContextMenu.pinnedMessage = root.pinnedMessage
        messageContextMenu.canPin = !!root.messageStore && root.messageStore.getNumberOfPinnedMessages() < Constants.maxNumberOfPins

        messageContextMenu.selectedUserPublicKey = root.senderId
        messageContextMenu.selectedUserDisplayName = root.senderDisplayName
        messageContextMenu.selectedUserIcon = root.senderIcon

        messageContextMenu.imageSource = imageSource

        messageContextMenu.isProfile = !!isProfileClick
        messageContextMenu.isRightClickOnImage = isRightClickOnImage
        messageContextMenu.isEmoji = isEmoji
        messageContextMenu.isSticker = isSticker
        messageContextMenu.hideEmojiPicker = hideEmojiPicker

        if (isReply) {
            if (!quotedMessageFrom) {
                // The responseTo message was deleted so we don't eneble to right click the unaviable profile
                return false
            }
            messageContextMenu.messageSenderId = quotedMessageFrom
            messageContextMenu.selectedUserPublicKey = quotedMessageFrom
            messageContextMenu.selectedUserDisplayName = quotedMessageAuthorDetailsDisplayName
            messageContextMenu.selectedUserIcon = quotedMessageAuthorDetailsThumbnailImage
        }

        // Emoji container is not a menu item of messageContextMenu so checking it separatly
        if (messageContextMenu.checkIfEmpty() && !isEmoji) {
            return false
        }

        messageContextMenu.parent = sender
        messageContextMenu.popup(point)
        return true
    }

    signal showReplyArea(string messageId, string author)


    function startMessageFoundAnimation() {
        root.item.startMessageFoundAnimation();
    }

    signal openStickerPackPopup(string stickerPackId)

    z: (typeof chatLogView === "undefined") ? 1 : (chatLogView.count - index)

    asynchronous: true

    sourceComponent: {
        switch(messageContentType) {
        case Constants.messageContentType.chatIdentifier:
            return channelIdentifierComponent
        case Constants.messageContentType.fetchMoreMessagesButton:
            return fetchMoreMessagesButtonComponent
        case Constants.messageContentType.systemMessagePrivateGroupType:
            return privateGroupHeaderComponent
        case Constants.messageContentType.systemMessagePinnedMessage:
            return systemMessagePinnedMessageComponent
        case Constants.messageContentType.gapType:
            return gapComponent
        case Constants.messageContentType.newMessagesMarker:
            return newMessagesMarkerComponent
        case Constants.messageContentType.messageType:
        case Constants.messageContentType.stickerType:
        case Constants.messageContentType.emojiType:
        case Constants.messageContentType.transactionType:
        case Constants.messageContentType.imageType:
        case Constants.messageContentType.audioType:
        case Constants.messageContentType.communityInviteType:
        case Constants.messageContentType.discordMessageType:
        case Constants.messageContentType.contactRequestType:
            return messageComponent
        case Constants.messageContentType.unknownContentType:
            // NOTE: We could display smth like "unknown message type, please upgrade Status to see it".
            return null
        default:
            return null
        }
    }

    QtObject {
        id: d

        readonly property int chatButtonSize: 32
        property bool hideMessage: false

        property string activeMessage
        readonly property bool isMessageActive: d.activeMessage === root.messageId

        function setMessageActive(messageId, active) {

            // TODO: Is argument messageId actually needed?
            //       It was probably used with dynamic scoping,
            //       but not this method can be moved to private `d`.
            //       Probably that it was done this way, because `MessageView` is reused as delegate.

            if (active) {
                d.activeMessage = messageId;
                return;
            }
            if (d.activeMessage === messageId) {
                d.activeMessage = "";
                return;
            }
        }

        function nextMessageHasHeader() {
            if(!root.nextMessageAsJsonObj) {
                return false
            }
            return root.senderId !== root.nextMessageAsJsonObj.senderId ||
                   d.getShouldRepeatHeader(root.nextMessageAsJsonObj.timeStamp, root.messageTimestamp, root.nextMessageAsJsonObj.outgoingStatus) ||
                   root.nextMessageAsJsonObj.responseToMessageWithId !== ""
        }

        function getShouldRepeatHeader(messageTimeStamp, prevMessageTimeStamp, messageOutgoingStatus) {
            return ((messageTimeStamp - prevMessageTimeStamp) / 60 / 1000) > Constants.repeatHeaderInterval 
                || d.getIsExpired(messageTimeStamp, messageOutgoingStatus)
        }

        function getIsExpired(messageTimeStamp, messageOutgoingStatus) {
            return (messageOutgoingStatus === Constants.sending && (Math.floor(messageTimeStamp) + 180000) < Date.now()) || messageOutgoingStatus === Constants.expired
        }

        function convertContentType(value) {
            switch (value) {
            case Constants.messageContentType.contactRequestType:
            case Constants.messageContentType.messageType:
                return StatusMessage.ContentType.Text;
            case Constants.messageContentType.stickerType:
                return StatusMessage.ContentType.Sticker;
            case Constants.messageContentType.emojiType:
                return StatusMessage.ContentType.Emoji;
            case Constants.messageContentType.transactionType:
                return StatusMessage.ContentType.Transaction;
            case Constants.messageContentType.imageType:
                return StatusMessage.ContentType.Image;
            case Constants.messageContentType.audioType:
                return StatusMessage.ContentType.Audio;
            case Constants.messageContentType.communityInviteType:
                return StatusMessage.ContentType.Invitation;
            case Constants.messageContentType.discordMessageType:
                return StatusMessage.ContentType.DiscordMessage;
            case Constants.messageContentType.systemMessagePinnedMessage:
                return StatusMessage.ContentType.SystemMessagePinnedMessage;
            case Constants.messageContentType.fetchMoreMessagesButton:
            case Constants.messageContentType.chatIdentifier:
            case Constants.messageContentType.unknownContentType:
            case Constants.messageContentType.statusType:
            case Constants.messageContentType.systemMessagePrivateGroupType:
            case Constants.messageContentType.gapType:
            default:
                return StatusMessage.ContentType.Unknown;
            }
        }
    }



    Connections {
        enabled: d.isMessageActive
        target: root.messageContextMenu
        function onClosed() {
            d.setMessageActive(root.messageId, false)
        }
    }

    Component {
        id: gapComponent
        GapComponent {
            gapFrom: root.gapFrom
            gapTo: root.gapTo
            onClicked: {
                messageStore.fillGaps(messageId)
                root.visible = false;
                root.height = 0;
            }
        }
    }

    Component {
        id: fetchMoreMessagesButtonComponent
        FetchMoreMessagesButton {
            nextMessageIndex: root.nextMessageIndex
            nextMsgTimestamp: root.nextMessageTimestamp
            onTimerTriggered: {
                messageStore.requestMoreMessages();
            }
        }
    }

    Component {
        id: channelIdentifierComponent
        ChannelIdentifierView {
            chatName: root.senderDisplayName
            chatId: root.messageStore.getChatId()
            chatType: root.messageStore.chatType
            chatColor: root.messageStore.chatColor
            chatEmoji: root.channelEmoji
            amIChatAdmin: root.amIChatAdmin
            chatIcon: {
                if (root.messageStore.chatType === Constants.chatType.privateGroupChat &&
                        root.messageStore.chatIcon !== "") {
                    return root.messageStore.chatIcon
                }
                return root.senderIcon
            }
        }
    }

    // Private group Messages
    Component {
        id: privateGroupHeaderComponent
        StyledText {
            wrapMode: Text.Wrap
            text: {
                return `<html>`+
                        `<head>`+
                        `<style type="text/css">`+
                        `a {`+
                        `color: ${Style.current.textColor};`+
                        `text-decoration: none;`+
                        `}`+
                        `</style>`+
                        `</head>`+
                        `<body>`+
                        `${messageText}`+
                        `</body>`+
                        `</html>`;
            }
            visible: isStatusMessage
            font.pixelSize: 14
            color: Style.current.secondaryText
            width:  parent.width - 120
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: Text.RichText
            topPadding: root.prevMessageIndex === 1 ? Style.current.bigPadding : 0
        }
    }

    Component {
        id: systemMessagePinnedMessageComponent

        StatusBaseText {
            width: parent.width - 120
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("%1 pinned a message").arg(senderDisplayName)
            color: Theme.palette.directColor3
            font.family: Theme.palette.baseFont.name
            font.pixelSize: Theme.primaryTextFontSize
            textFormat: Text.RichText
            wrapMode: Text.Wrap
            topPadding: root.prevMessageIndex === 1 ? Style.current.bigPadding : 0
        }
    }

    Component {
        id: messageComponent

        ColumnLayout {
            spacing: 0

            function startMessageFoundAnimation() {
                delegate.startMessageFoundAnimation();
            }

            StatusDateGroupLabel {
                id: dateGroupLabel
                Layout.fillWidth: true
                Layout.topMargin: 16
                Layout.bottomMargin: 16
                messageTimestamp: root.messageTimestamp
                previousMessageTimestamp: root.prevMessageIndex === -1 ? 0 : root.prevMessageTimestamp
                visible: text !== "" && !root.isInPinnedPopup
            }

            StatusMessage {
                id: delegate
                Layout.fillWidth: true
                Layout.topMargin: showHeader && !root.isInPinnedPopup ? 2 : 0
                Layout.bottomMargin: !root.isInPinnedPopup ? 2 : 0

                readonly property int contentType: d.convertContentType(root.messageContentType)
                property string originalMessageText: ""
                readonly property bool hideQuickActions: root.isChatBlocked ||
                                  root.placeholderMessage ||
                                  root.isInPinnedPopup ||
                                  root.editModeOn ||
                                  !root.rootStore.mainModuleInst.activeSection.joined

                function editCancelledHandler() {
                    root.messageStore.setEditModeOff(root.messageId)
                }

                function editCompletedHandler(newMessageText) {

                    if (delegate.originalMessageText === newMessageText) {
                        delegate.editCancelledHandler()
                        return
                    }

                    const message = root.rootStore.plainText(StatusQUtils.Emoji.deparse(newMessageText))

                    if (message.length <= 0)
                        return;

                    const interpretedMessage = root.messageStore.interpretMessage(message)
                    root.messageStore.setEditModeOff(root.messageId)
                    root.messageStore.editMessage(root.messageId, root.messageContentType, interpretedMessage)
                }

                pinnedMsgInfoText: root.isDiscordMessage ? qsTr("Pinned") : qsTr("Pinned by")
                reactionIcons: [
                    Style.svg("emojiReactions/heart"),
                    Style.svg("emojiReactions/thumbsUp"),
                    Style.svg("emojiReactions/thumbsDown"),
                    Style.svg("emojiReactions/laughing"),
                    Style.svg("emojiReactions/sad"),
                    Style.svg("emojiReactions/angry"),
                ]

                timestamp: root.messageTimestamp
                editMode: root.editModeOn
                isAReply: root.responseToMessageWithId !== ""
                isEdited: root.isEdited
                hasMention: root.hasMention
                isPinned: root.pinnedMessage
                pinnedBy: {
                    if (!root.pinnedMessage || root.isDiscordMessage)
                        return ""
                    const contact = Utils.getContactDetailsAsJson(root.messagePinnedBy, false)
                    return ProfileUtils.displayName(contact.localNickname, contact.name, contact.displayName, contact.alias)
                }
                isInPinnedPopup: root.isInPinnedPopup
                hasExpired: root.isExpired
                isSending: root.isSending
                resendError: root.resendError
                reactionsModel: root.reactionsModel

                showHeader: root.shouldRepeatHeader || dateGroupLabel.visible || isAReply ||
                            root.prevMessageContentType === Constants.messageContentType.systemMessagePrivateGroupType ||
                            root.prevMessageContentType === Constants.messageContentType.systemMessagePinnedMessage ||
                            root.senderId !== root.prevMessageSenderId
                isActiveMessage: d.isMessageActive
                topPadding: showHeader ? Style.current.halfPadding : 0
                bottomPadding: showHeader && d.nextMessageHasHeader() ? Style.current.halfPadding : 2
                disableHover: root.disableHover ||
                              delegate.hideQuickActions ||
                              (root.chatLogView && root.chatLogView.moving) ||
                              (root.messageContextMenu && root.messageContextMenu.opened) ||
                              Global.popupOpened

                disableEmojis: root.isChatBlocked
                hideMessage: d.hideMessage

                overrideBackground: root.placeholderMessage
                profileClickable: !root.isDiscordMessage
                messageAttachments: root.messageAttachments

                onEditCancelled: {
                    delegate.editCancelledHandler()
                }

                onEditCompleted: delegate.editCompletedHandler(newMsgText)

                onImageClicked: {
                    switch (mouse.button) {
                    case Qt.LeftButton:
                        root.imageClicked(image, mouse);
                        break;
                    case Qt.RightButton:
                        root.messageClickHandler(image, Qt.point(mouse.x, mouse.y), false, false, true, image, false, true, false, true, imageSource)
                        break;
                    }
                }

                onLinkActivated: {
                    if (link.startsWith('//')) {
                        const pubkey = link.replace("//", "");
                        Global.openProfilePopup(pubkey)
                        return
                    } else if (link.startsWith('#')) {
                        rootStore.chatCommunitySectionModule.switchToChannel(link.replace("#", ""))
                        return
                    } else if (Utils.isStatusDeepLink(link)) {
                        rootStore.activateStatusDeepLink(link)
                        return
                    }

                    Global.openLink(link)
                }

                onProfilePictureClicked: {
                    if (root.messageClickHandler(sender, Qt.point(mouse.x, mouse.y), true))
                        d.setMessageActive(root.messageId, true)
                }

                onReplyProfileClicked: {
                    if (root.messageClickHandler(sender, Qt.point(mouse.x, mouse.y), true, false, false, null, false, false, true))
                        d.setMessageActive(root.messageId, true)
                }

                onReplyMessageClicked: {
                    if (!root.quotedMessageDeleted && root.quotedMessageFrom)
                        root.messageStore.messageModule.jumpToMessage(root.responseToMessageWithId)
                }

                onSenderNameClicked: {
                    if (root.messageClickHandler(sender, Qt.point(mouse.x, mouse.y), true))
                        d.setMessageActive(root.messageId, true)
                }

                onToggleReactionClicked: {
                    if (root.isChatBlocked)
                        return

                    if (!root.messageStore) {
                        console.error("Reaction can not be toggled, message store is not valid")
                        return
                    }

                    root.messageStore.toggleReaction(root.messageId, emojiId)
                }

                onAddReactionClicked: {
                    if (root.isChatBlocked)
                        return

                    if (root.messageClickHandler(sender, Qt.point(mouse.x, mouse.y), false, false, false, null, true, false))
                        d.setMessageActive(root.messageId, true)
                }

                onStickerClicked: {
                    root.openStickerPackPopup(root.stickerPack);
                }

                onResendClicked: {
                    root.messageStore.resendMessage(root.messageId)
                }

                mouseArea {
                    acceptedButtons: Qt.RightButton
                    enabled: !root.isChatBlocked &&
                             !root.placeholderMessage &&
                             delegate.contentType !== StatusMessage.ContentType.Image
                    onClicked: {
                        if (root.messageClickHandler(this, Qt.point(mouse.x, mouse.y),
                            false, false, false, null, root.isEmoji, false, false, false, ""))
                            d.setMessageActive(root.messageId, true)
                    }
                }

                messageDetails: StatusMessageDetails {
                    contentType: delegate.contentType
                    messageOriginInfo: isDiscordMessage ? qsTr("Imported from discord") : ""
                    messageText: root.messageText
                    messageContent: {
                        switch (delegate.contentType)
                        {
                        case StatusMessage.ContentType.Sticker:
                            return root.sticker;
                        case StatusMessage.ContentType.Image:

                            return root.messageImage;
                        }
                        if (root.isDiscordMessage && root.messageImage != "") {
                            return root.messageImage
                        }
                        return "";
                    }
                    album: root.album
                    albumCount: root.albumCount

                    amISender: root.amISender
                    sender.id: root.senderIsEnsVerified ? "" :  Utils.getCompressedPk(root.senderId)
                    sender.displayName: root.senderDisplayName
                    sender.secondaryName: root.senderOptionalName
                    sender.isEnsVerified: root.senderIsEnsVerified
                    sender.isContact: root.senderIsAdded
                    sender.trustIndicator: root.senderTrustStatus
                    sender.profileImage {
                        width: 40
                        height: 40
                        name: root.senderIcon || ""
                        assetSettings.isImage: root.isDiscordMessage || root.senderIcon.startsWith("data")
                        pubkey: root.senderId
                        colorId: Utils.colorIdForPubkey(root.senderId)
                        colorHash: root.senderColorHash
                        showRing: !root.isDiscordMessage && !root.senderIsEnsVerified
                    }
                }

                replyDetails: StatusMessageDetails {
                    readonly property var responseMessage: contentType === StatusMessage.ContentType.Sticker || contentType === StatusMessage.ContentType.Image
                                                           ? root.messageStore.getMessageByIdAsJson(responseToMessageWithId)
                                                           : null
                    onResponseMessageChanged: {
                        if (!responseMessage)
                            return

                        switch (contentType) {
                        case StatusMessage.ContentType.Sticker:
                            messageContent = responseMessage.sticker;
                            return
                        case StatusMessage.ContentType.Image:
                            messageContent = responseMessage.messageImage;
                            albumCount = responseMessage.albumImagesCount
                            album = responseMessage.albumMessageImages
                            return
                        default:
                            messageContent = ""
                        }
                    }

                    messageText: {
                        if (root.quotedMessageDeleted) {
                            return qsTr("Message deleted")
                        }
                        if (!root.quotedMessageText && !root.quotedMessageFrom) {
                            return qsTr("Unknown message. Try fetching more messages")
                        }
                        return root.quotedMessageText
                    }
                    contentType: d.convertContentType(root.quotedMessageContentType)
                    amISender: root.quotedMessageFrom === userProfile.pubKey
                    sender.id: root.quotedMessageFrom
                    sender.isContact: quotedMessageAuthorDetailsIsContact
                    sender.displayName: quotedMessageAuthorDetailsDisplayName
                    sender.isEnsVerified: quotedMessageAuthorDetailsEnsVerified
                    sender.secondaryName: quotedMessageAuthorDetailsName
                    sender.profileImage {
                        width: 20
                        height: 20
                        name: quotedMessageAuthorDetailsThumbnailImage
                        assetSettings.isImage: quotedMessageAuthorDetailsThumbnailImage
                        showRing: (root.quotedMessageContentType !== Constants.messageContentType.discordMessageType) && !sender.isEnsVerified
                        pubkey: sender.id
                        colorId: Utils.colorIdForPubkey(sender.id)
                        colorHash: quotedMessageAuthorDetailsColorHash
                    }
                }

                statusChatInput: Component {
                    StatusChatInput {
                        id: editTextInput
                        objectName: "editMessageInput"

                        readonly property string messageText: editTextInput.textInput.text

                        // TODO: Move this property and Escape handler to StatusChatInput
                        property bool suggestionsOpened: false

                        width: parent.width

                        Keys.onEscapePressed: {
                            if (!suggestionsOpened) {
                                delegate.editCancelled()
                            }
                            suggestionsOpened = false
                        }

                        store: root.rootStore
                        usersStore: root.usersStore
                        emojiPopup: root.emojiPopup
                        stickersPopup: root.stickersPopup
                        messageContextMenu: root.messageContextMenu

                        chatType: root.messageStore.chatType
                        isEdit: true

                        onSendMessage: delegate.editCompletedHandler(editTextInput.getTextWithPublicKeys())

                        Component.onCompleted: {
                            parseMessage(root.messageText);
                            delegate.originalMessageText = editTextInput.textInput.text
                        }
                    }
                }

                hasLinks: !!root.linkUrls
                linksComponent: Component {
                    LinksMessageView {
                        id: linksMessageView
                        links: root.linkUrls
                        messageStore: root.messageStore
                        store: root.rootStore
                        isCurrentUser: root.amISender
                        onImageClicked: {
                            root.imageClicked(image);
                        }
                        onLinksLoaded: {
                            // If there is only one image and no links, hide the message
                            // Handled in linksLoaded signal to evaulate it only once
                            d.hideMessage = linksMessageView.unfurledImagesCount === 1 && linksMessageView.unfurledLinksCount === 0 
                                            && `<p>${root.linkUrls}</p>` === root.messageText
                        }
                    }
                }

                transcationComponent: Component {
                    TransactionBubbleView {
                        transactionParams: root.transactionParams
                        store: root.rootStore
                        contactsStore: root.contactsStore
                    }
                }

                invitationComponent: Component {
                    InvitationBubbleView {
                        store: root.rootStore
                        communityId: root.communityId
                    }
                }

                quickActions: [
                    Loader {
                        active: !root.isInPinnedPopup && delegate.hovered && !delegate.hideQuickActions
                        visible: active
                        sourceComponent: StatusFlatRoundButton {
                            width: d.chatButtonSize
                            height: d.chatButtonSize
                            icon.name: "reaction-b"
                            type: StatusFlatRoundButton.Type.Tertiary
                            tooltip.text: qsTr("Add reaction")
                            onClicked: {
                                if (root.messageClickHandler(delegate, mapToItem(delegate, mouse.x, mouse.y), false, false, false, null, true, false))
                                    d.setMessageActive(root.messageId, true)
                            }
                        }
                    },
                    Loader {
                        active: !root.isInPinnedPopup && delegate.hovered && !delegate.hideQuickActions
                        visible: active
                        sourceComponent: StatusFlatRoundButton {
                            objectName: "replyToMessageButton"
                            width: d.chatButtonSize
                            height: d.chatButtonSize
                            icon.name: "reply"
                            type: StatusFlatRoundButton.Type.Tertiary
                            tooltip.text: qsTr("Reply")
                            onClicked: {
                                root.showReplyArea(root.messageId, root.senderId)
                                if (messageContextMenu.closeParentPopup) {
                                    messageContextMenu.closeParentPopup()
                                }
                            }
                        }
                    },
                    Loader {
                        active: !root.isInPinnedPopup && root.isText && !root.editModeOn && root.amISender && delegate.hovered && !delegate.hideQuickActions
                        visible: active
                        sourceComponent: StatusFlatRoundButton {
                            objectName: "editMessageButton"
                            width: d.chatButtonSize
                            height: d.chatButtonSize
                            icon.name: "edit_pencil"
                            type: StatusFlatRoundButton.Type.Tertiary
                            tooltip.text: qsTr("Edit")
                            onClicked: {
                                root.messageStore.setEditModeOn(root.messageId)
                            }
                        }
                    },
                    Loader {
                        active: {
                            if(!delegate.hovered)
                                return false;
                                
                            if (!root.messageStore)
                                return false
                            
                            if(delegate.hideQuickActions)
                                return false;

                            const chatType = root.messageStore.chatType;
                            const pinMessageAllowedForMembers = root.messageStore.isPinMessageAllowedForMembers

                            return chatType === Constants.chatType.oneToOne ||
                                    chatType === Constants.chatType.privateGroupChat && root.amIChatAdmin ||
                                    chatType === Constants.chatType.communityChat && (root.amIChatAdmin || pinMessageAllowedForMembers);

                        }
                        visible: active
                        sourceComponent: StatusFlatRoundButton {
                            objectName: "MessageView_toggleMessagePin"
                            width: d.chatButtonSize
                            height: d.chatButtonSize
                            icon.name: root.pinnedMessage ? "unpin" : "pin"
                            type: StatusFlatRoundButton.Type.Tertiary
                            tooltip.text: root.pinnedMessage ? qsTr("Unpin") : qsTr("Pin")
                            onClicked: {
                                if (root.pinnedMessage) {
                                    messageStore.unpinMessage(root.messageId)
                                    return;
                                }

                                if (!!root.messageStore && root.messageStore.getNumberOfPinnedMessages() < Constants.maxNumberOfPins) {
                                    messageStore.pinMessage(root.messageId)
                                    return;
                                }

                                if (!chatContentModule) {
                                    console.warn("error on open pinned messages limit reached from message context menu - chat content module is not set")
                                    return;
                                }

                                const chatId = root.messageStore.chatType === Constants.chatType.oneToOne ? chatContentModule.getMyChatId() : ""
                                Global.openPinnedMessagesPopupRequested(root.rootStore, messageStore, chatContentModule.pinnedMessagesModel, root.messageId, chatId)
                            }
                        }
                    },
                    Loader {
                        active: {
                            if(!delegate.hovered)
                                return false;
                            if (root.isInPinnedPopup)
                                return false;
                            if (!root.messageStore)
                                return false;
                            if (delegate.hideQuickActions)
                                return false;
                            return (root.amISender || root.amIChatAdmin) &&
                                    (messageContentType === Constants.messageContentType.messageType ||
                                     messageContentType === Constants.messageContentType.stickerType ||
                                     messageContentType === Constants.messageContentType.emojiType ||
                                     messageContentType === Constants.messageContentType.imageType ||
                                     messageContentType === Constants.messageContentType.audioType);
                        }
                        visible: active
                        sourceComponent: StatusFlatRoundButton {
                            objectName: "chatDeleteMessageButton"
                            width: d.chatButtonSize
                            height: d.chatButtonSize
                            icon.name: "delete"
                            type: StatusFlatRoundButton.Type.Tertiary
                            tooltip.text: qsTr("Delete")
                            onClicked: {
                                if (!localAccountSensitiveSettings.showDeleteMessageWarning) {
                                    messageStore.deleteMessage(root.messageId)
                                }
                                else {
                                    Global.openPopup(deleteMessageConfirmationDialogComponent)
                                }
                            }
                        }
                    }
                ]
            }
        }
    }

    Component {
        id: deleteMessageConfirmationDialogComponent

        ConfirmationDialog {
            confirmButtonObjectName: "chatButtonsPanelConfirmDeleteMessageButton"
            header.title: qsTr("Confirm deleting this message")
            confirmationText: qsTr("Are you sure you want to delete this message? Be aware that other clients are not guaranteed to delete the message as well.")
            height: 260
            checkbox.visible: true
            executeConfirm: function () {
                if (checkbox.checked) {
                    localAccountSensitiveSettings.showDeleteMessageWarning = false
                }

                close()
                messageStore.deleteMessage(root.messageId)
            }
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: newMessagesMarkerComponent

        NewMessagesMarker {
            count: root.messageStore.newMessagesCount
            timestamp: root.messageTimestamp
        }
    }
}
