import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Chat.layouts 1.0
import AppLayouts.Chat.views.communities 1.0
import AppLayouts.Chat.popups.community 1.0

import utils 1.0
import SortFilterProxyModel 0.2

SettingsPageLayout {
    id: root

    // Models:
    property var tokensModel

    property string feeText
    property string errorText
    property bool isFeeLoading: true

    // Network related properties:
    property var layer1Networks
    property var layer2Networks
    property var testNetworks
    property var enabledNetworks
    property var allNetworks

    // Account expected roles: address, name, color, emoji
    property var accounts

    property int viewWidth: 560 // by design

    signal mintCollectible(url artworkSource,
                           string name,
                           string symbol,
                           string description,
                           int supply,
                           bool infiniteSupply,
                           bool transferable,
                           bool selfDestruct,
                           int chainId,
                           string accountName,
                           string accountAddress,
                           var artworkCropRect)

    signal signMintTransactionOpened(int chainId, string accountAddress)

    signal remoteSelfDestructCollectibles(var selfDestructTokensList, // [key , amount]
                                          int chainId,
                                          string accountName,
                                          string accountAddress)

    signal signSelfDestructTransactionOpened(int chainId)

    signal airdropCollectible(string key)

    function setFeeLoading() {
        root.isFeeLoading = true
        root.feeText = ""
        root.errorText = ""
    }

    function navigateBack() {
        stackManager.pop(StackView.Immediate)
    }

    QtObject {
        id: d

        readonly property string initialViewState: "WELCOME_OR_LIST_COLLECTIBLES"
        readonly property string newCollectibleViewState: "NEW_COLLECTIBLE"
        readonly property string previewCollectibleViewState: "PREVIEW_COLLECTIBLE"
        readonly property string collectibleViewState: "VIEW_COLLECTIBLE"

        readonly property string welcomePageTitle: qsTr("Tokens")
        readonly property string newCollectiblePageTitle: qsTr("Mint collectible")
        readonly property string newTokenButtonText: qsTr("Mint token")
        readonly property string backButtonText: qsTr("Back")

        property string accountAddress
        property string accountName
        property int chainId
        property string chainName

        property var tokenOwnersModel
        property var selfDestructTokensList
        property bool selfDestruct

        readonly property var initialItem: (root.tokensModel && root.tokensModel.count > 0) ? mintedTokensView : welcomeView
        onInitialItemChanged: updateInitialStackView()

        signal airdropClicked()

        function updateInitialStackView() {
            if(stackManager.stackView) {
                if(initialItem === welcomeView)
                    stackManager.stackView.replace(mintedTokensView, welcomeView, StackView.Immediate)
                if(initialItem === mintedTokensView)
                    stackManager.stackView.replace(welcomeView, mintedTokensView, StackView.Immediate)
            }
        }
    }

    content: StackView {
        anchors.fill: parent
        initialItem: d.initialItem

        Component.onCompleted: stackManager.pushInitialState(d.initialViewState)
    }

    state: stackManager.currentState
    states: [
        State {
            name: d.initialViewState
            PropertyChanges {target: root; title: d.welcomePageTitle}
            PropertyChanges {target: root; subTitle: ""}
            PropertyChanges {target: root; previousPageName: ""}
            PropertyChanges {target: root; headerButtonVisible: true}
            PropertyChanges {target: root; headerButtonText: d.newTokenButtonText}
            PropertyChanges {target: root; headerWidth: root.viewWidth}
        },
        State {
            name: d.newCollectibleViewState
            PropertyChanges {target: root; title: d.newCollectiblePageTitle}
            PropertyChanges {target: root; subTitle: ""}
            PropertyChanges {target: root; previousPageName: d.backButtonText}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
        },
        State {
            name: d.previewCollectibleViewState
            PropertyChanges {target: root; previousPageName: d.backButtonText}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
        },
        State {
            name: d.collectibleViewState
            PropertyChanges {target: root; previousPageName: d.backButtonText}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
            PropertyChanges {target: root; footer: mintTokenFooter}
        }
    ]

    onHeaderButtonClicked: stackManager.push(d.newCollectibleViewState, newCollectiblesView, null, StackView.Immediate)

    StackViewStates {
        id: stackManager

        stackView: root.contentItem
    }

    // Mint tokens possible view contents:
    Component {
        id: welcomeView

        CommunityWelcomeSettingsView {
            viewWidth: root.viewWidth
            image: Style.png("community/mint2_1")
            title: qsTr("Community tokens")
            subtitle: qsTr("You can mint custom tokens and import tokens for your community")
            checkersModel: [
                qsTr("Create remotely destructible soulbound tokens for admin permissions"),
                qsTr("Reward individual members with custom tokens for their contribution"),
                qsTr("Mint tokens for use with community and channel permissions")
            ]
        }
    }

    Component {
        id: newCollectiblesView

        CommunityNewCollectibleView {
            viewWidth: root.viewWidth
            layer1Networks: root.layer1Networks
            layer2Networks: root.layer2Networks
            testNetworks: root.testNetworks
            enabledNetworks: root.testNetworks
            allNetworks: root.allNetworks
            accounts: root.accounts

            onPreviewClicked: {
                d.accountAddress = accountAddress
                stackManager.push(d.previewCollectibleViewState,
                                  previewCollectibleView,
                                  {
                                      preview: true,
                                      name,
                                      artworkSource,
                                      artworkCropRect,
                                      symbol,
                                      description,
                                      supplyAmount,
                                      infiniteSupply,
                                      transferable: !notTransferable,
                                      selfDestruct,
                                      chainId,
                                      chainName,
                                      chainIcon,
                                      accountName
                                  },
                                  StackView.Immediate)
            }
        }
    }

    Component {
        id: previewCollectibleView

        CommunityCollectibleView {
            id: preview

            function signMintTransaction() {
                root.setFeeLoading()
                root.mintCollectible(artworkSource,
                                     name,
                                     symbol,
                                     description,
                                     supplyAmount,
                                     infiniteSupply,
                                     transferable,
                                     selfDestruct,
                                     chainId,
                                     accountName,
                                     d.accountAddress,
                                     artworkCropRect)

                stackManager.clear(d.initialViewState, StackView.Immediate)
            }

            viewWidth: root.viewWidth

            onMintCollectible: popup.open()

            Binding {
                target: root
                property: "title"
                value: preview.name
            }

            Binding {
                target: root
                property: "subTitle"
                value: preview.symbol
                restoreMode: Binding.RestoreBindingOrValue
            }

            SignMintTokenTransactionPopup {
                id: popup

                anchors.centerIn: Overlay.overlay
                collectibleName: parent.name
                accountName: parent.accountName
                networkName: parent.chainName
                feeText: root.feeText
                errorText: root.errorText
                isFeeLoading: root.isFeeLoading

                onOpened: {
                    root.setFeeLoading()
                    root.signMintTransactionOpened(parent.chainId, d.accountAddress)
                }
                onCancelClicked: close()
                onSignTransactionClicked: parent.signMintTransaction()
            }
        }
    }

    Component {
        id: mintTokenFooter

        MintTokensFooterPanel {
            id: footerPanel

            function closePopups() {
                remoteSelfdestructPopup.close()
                alertPopup.close()
                signSelfDestructPopup.close()
            }

            airdropEnabled: true
            retailEnabled: false
            remotelySelfDestructVisible: d.selfDestruct
            burnEnabled: false

            onAirdropClicked: d.airdropClicked()
            onRemotelySelfDestructClicked: remoteSelfdestructPopup.open()

            RemoteSelfDestructPopup {
                id: remoteSelfdestructPopup

                collectibleName: root.title
                model: d.tokenOwnersModel

                onSelfDestructClicked: {
                    d.selfDestructTokensList = selfDestructTokensList
                    alertPopup.tokenCount = tokenCount
                    alertPopup.open()
                }
            }

            SelfDestructAlertPopup {
                id: alertPopup

                onSelfDestructClicked: signSelfDestructPopup.open()
            }

            SignMintTokenTransactionPopup {
                id: signSelfDestructPopup

                function signSelfRemoteDestructTransaction() {
                    root.isFeeLoading = true
                    root.feeText = ""
                    root.remoteSelfDestructCollectibles(d.selfDestructTokensList,
                                                        d.chainId,
                                                        d.accountName,
                                                        d.accountAddress)

                    footerPanel.closePopups()
                }

                title: qsTr("Sign transaction - Self-destruct %1 tokens").arg(root.title)
                collectibleName: root.title
                accountName: d.accountName
                networkName: d.chainName
                feeText: root.feeText
                isFeeLoading: root.isFeeLoading

                onOpened: root.signSelfDestructTransactionOpened(d.chainId)
                onCancelClicked: close()
                onSignTransactionClicked: signSelfRemoteDestructTransaction()
            }
        }
    }

    Component {
        id: mintedTokensView

        CommunityMintedTokensView {
            viewWidth: root.viewWidth
            model: root.tokensModel
            onItemClicked: {
                d.accountAddress = accountAddress
                d.chainId = chainId
                d.chainName = chainName
                d.accountName = accountName
                stackManager.push(d.collectibleViewState,
                                  collectibleView,
                                  {
                                      preview: false,
                                      index
                                  },
                                  StackView.Immediate)
            }
        }
    }

    Component {
        id: collectibleView

        CommunityCollectibleView {
            id: view

            property int index // TODO: Update it to key when model has role key implemented

            viewWidth: root.viewWidth

            Binding {
                target: root
                property: "title"
                value: view.name
            }

            Binding {
                target: root
                property: "subTitle"
                value: view.symbol
                restoreMode: Binding.RestoreBindingOrValue
            }

            Binding {
                target: d
                property: "tokenOwnersModel"
                value: view.tokenOwnersModel
            }

            Binding {
                target: d
                property: "selfDestruct"
                value: view.selfDestruct
            }

            Instantiator {
                id: instantiator


                model: SortFilterProxyModel {
                    sourceModel: root.tokensModel
                    filters: IndexFilter {
                        minimumIndex: view.index
                        maximumIndex: view.index
                    }
                }
                delegate: QtObject {
                    component Bind: Binding { target: view }
                    readonly property list<Binding> bindings: [
                        Bind { property: "deployState"; value: model.deployState },
                        Bind { property: "name"; value: model.name },
                        Bind { property: "artworkSource"; value: model.image },
                        Bind { property: "symbol"; value: model.symbol },
                        Bind { property: "description"; value: model.description },
                        Bind { property: "supplyAmount"; value: model.supply },
                        Bind { property: "infiniteSupply"; value: model.infiniteSupply },
                        Bind { property: "remainingTokens"; value: model.remainingTokens },
                        Bind { property: "selfDestruct"; value: model.remoteSelfDestruct },
                        Bind { property: "chainId"; value: model.chainId },
                        Bind { property: "chainName"; value: model.chainName },
                        Bind { property: "chainIcon"; value: model.chainIcon },
                        Bind { property: "accountName"; value: model.accountName },
                        Bind { property: "tokenOwnersModel"; value: model.tokenOwnersModel }
                    ]
                }
            }

            Connections {
                target: d

                function onAirdropClicked() {
                    root.airdropCollectible(view.symbol) // TODO: Backend. It should just be the key (hash(chainId + contractAddress)
                }
            }
        }
    }
}
