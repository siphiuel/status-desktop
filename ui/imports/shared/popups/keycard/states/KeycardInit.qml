import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

import "../helpers"

Item {
    id: root

    property var sharedKeycardModule

    Component.onCompleted: {
        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhrase ||
                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhrase ||
                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycard ||
                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.renamingKeycard ||
                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockingKeycard ||
                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycard) {
            root.sharedKeycardModule.currentState.doPrimaryAction()
        }
    }

    QtObject {
        id: d

        readonly property bool hideKeyPair: root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.hideKeyPair
        readonly property bool copyFromAKeycardPartDone: root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.copyFromAKeycardPartDone
        readonly property bool continuousProcessingAnimation: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhrase ||
                                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhrase ||
                                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycard ||
                                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockingKeycard ||
                                                              root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycard
    }

    Timer {
        id: timer
        interval: 1000
        running: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                 root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPin ||
                 root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPuk ||
                 root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCode
        onTriggered: {
            root.sharedKeycardModule.currentState.doSecondaryAction()
        }
    }

    Component {
        id: keyPairForProcessingComponent
        KeyPairItem {
            keyPairType:  root.sharedKeycardModule.keyPairForProcessing.pairType
            keyPairPubKey: root.sharedKeycardModule.keyPairForProcessing.pubKey
            keyPairName: root.sharedKeycardModule.keyPairForProcessing.name
            keyPairIcon: root.sharedKeycardModule.keyPairForProcessing.icon
            keyPairImage: root.sharedKeycardModule.keyPairForProcessing.image
            keyPairDerivedFrom: root.sharedKeycardModule.keyPairForProcessing.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.keyPairForProcessing.accounts
            keyPairCardLocked: root.sharedKeycardModule.keyPairForProcessing.locked
        }
    }

    Component {
        id: unknownKeyPairCompontnt
        KeyPairUnknownItem {
            keyPairPubKey: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard?
                               root.sharedKeycardModule.keyPairHelper.pubKey
                             : root.sharedKeycardModule.keyPairForProcessing.pubKey
            keyPairName: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard?
                             root.sharedKeycardModule.keyPairHelper.name
                           : root.sharedKeycardModule.keyPairForProcessing.name
            keyPairIcon: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard?
                             root.sharedKeycardModule.keyPairHelper.icon
                           : root.sharedKeycardModule.keyPairForProcessing.icon
            keyPairImage: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard?
                              root.sharedKeycardModule.keyPairHelper.image
                            : root.sharedKeycardModule.keyPairForProcessing.image
            keyPairDerivedFrom: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard?
                                    root.sharedKeycardModule.keyPairHelper.derivedFrom
                                  : root.sharedKeycardModule.keyPairForProcessing.derivedFrom
            keyPairAccounts: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard?
                                 root.sharedKeycardModule.keyPairHelper.accounts
                               : root.sharedKeycardModule.keyPairForProcessing.accounts
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: Style.current.padding
        clip: true

        KeycardImage {
            id: image
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Constants.keycard.shared.imageHeight
            Layout.preferredWidth: Constants.keycard.shared.imageWidth

            onAnimationCompleted: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard) {
                    root.sharedKeycardModule.currentState.doSecondaryAction()
                }
            }
        }

        Row {
            spacing: Style.current.halfPadding
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: Constants.keycard.general.titleHeight

            StatusIcon {
                id: icon
                visible: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard
                width: Style.current.padding
                height: Style.current.padding
                icon: "checkmark"
                color: Theme.palette.baseColor1
            }
            StatusLoadingIndicator {
                id: loading
                visible: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhrase ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhrase ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycard ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.renamingKeycard ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockingKeycard ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPin ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPuk ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCode ||
                         root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycard
            }
            StatusBaseText {
                id: title
                wrapMode: Text.WordWrap
            }
        }

        StatusBaseText {
            id: message
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: Constants.keycard.general.messageHeight
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Loader {
            id: loader
            Layout.preferredWidth: parent.width
            active: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if((root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard && !d.hideKeyPair) ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhrase ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhraseSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhraseFailure) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhrase ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhraseSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhraseFailure ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseAlreadyInUse) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycardSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycardFailure ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseAlreadyInUse) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication &&
                        !!root.sharedKeycardModule.keyPairForProcessing &&
                        root.sharedKeycardModule.keyPairForProcessing.name !== "") {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.displayKeycardContent) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.renameKeycard && !d.hideKeyPair) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameFailure)
                            return true
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin && !d.hideKeyPair) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard)
                            return true
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPuk && !d.hideKeyPair) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard)
                            return true
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changePairingCode && !d.hideKeyPair) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard)
                            return true
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.createCopyOfAKeycard && !d.hideKeyPair) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.removeKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyToKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycardFailure ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycardSuccess)
                            return true
                }

                return false
            }

            sourceComponent: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        if (root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                            return keyPairForProcessingComponent
                        }
                        return unknownKeyPairCompontnt
                    }
                    if ((root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted && !d.hideKeyPair) ||
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard && !d.hideKeyPair) ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure) {
                        return keyPairForProcessingComponent
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        if (root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                            return keyPairForProcessingComponent
                        }
                        return unknownKeyPairCompontnt
                    }

                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhrase ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhraseSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhraseFailure) {
                        return keyPairForProcessingComponent
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        if (root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                            return keyPairForProcessingComponent
                        }
                        return unknownKeyPairCompontnt
                    }

                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhrase ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhraseSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhraseFailure ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseAlreadyInUse) {
                        return keyPairForProcessingComponent
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        if (root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                            return keyPairForProcessingComponent
                        }
                        return unknownKeyPairCompontnt
                    }

                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycardSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycardFailure ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseAlreadyInUse) {
                        return keyPairForProcessingComponent
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        if (root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                            return keyPairForProcessingComponent
                        }
                        return unknownKeyPairCompontnt
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard) {
                        return keyPairForProcessingComponent
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.displayKeycardContent) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        if (root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                            return keyPairForProcessingComponent
                        }
                        return unknownKeyPairCompontnt
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.renameKeycard) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameFailure) {
                        return keyPairForProcessingComponent
                    }
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard)
                        return keyPairForProcessingComponent
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard)
                        return keyPairForProcessingComponent
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPuk) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard)
                        return keyPairForProcessingComponent
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changePairingCode) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard)
                        return keyPairForProcessingComponent
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.createCopyOfAKeycard) {
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.removeKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyToKeycard) {
                        if (root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
                            return keyPairForProcessingComponent
                        }
                        return unknownKeyPairCompontnt
                    }
                    if(root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycardFailure ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycardSuccess)
                        return keyPairForProcessingComponent
                }

                return undefined
            }
        }

        Item {
            visible: !loader.active
            Layout.fillWidth: true
            Layout.fillHeight: visible
        }
    }

    states: [
        State {
            name: Constants.keycardSharedState.pluginReader
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader
            PropertyChanges {
                target: title
                text: qsTr("Plug in Keycard reader...")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/empty-reader")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.insertKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard
            PropertyChanges {
                target: title
                text: {
                    if (d.copyFromAKeycardPartDone) {
                        return qsTr("Insert empty Keycard...")
                    }
                    return qsTr("Insert Keycard...")
                }
                font.weight: Font.Bold
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.cardInsert.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.cardInsert.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.cardInsert.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.cardInsert.endImgIndex
                duration: Constants.keycardAnimations.cardInsert.duration
                loops: Constants.keycardAnimations.cardInsert.loops
            }
            PropertyChanges {
                target: message
                text: root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.wronglyInsertedCard?
                          qsTr("Check the card, it might be wrongly inserted") :
                          ""
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
            }
        },
        State {
            name: Constants.keycardSharedState.keycardInserted
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted
            PropertyChanges {
                target: title
                text: qsTr("Keycard inserted...")
                font.weight: Font.Bold
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.cardInserted.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.cardInserted.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.cardInserted.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.cardInserted.endImgIndex
                duration: Constants.keycardAnimations.cardInserted.duration
                loops: Constants.keycardAnimations.cardInserted.loops
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: "processing"
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhrase ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhrase ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycard ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.renamingKeycard ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockingKeycard ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPin ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPuk ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCode ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycard
            PropertyChanges {
                target: title
                text: {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard) {
                        return qsTr("Reading Keycard...")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair) {
                        return qsTr("Migrating key pair to Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhrase) {
                        return qsTr("Creating new account...")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhrase) {
                        return qsTr("Setting a new Keycard...")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycard) {
                        return qsTr("Importing from Keycard...")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.renamingKeycard) {
                        return qsTr("Renaming keycard...")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockingKeycard) {
                        return qsTr("Unlocking keycard...")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPin) {
                        return qsTr("Updating PIN")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPuk) {
                        return qsTr("Setting your Keycard PUK...")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCode) {
                        return qsTr("Setting your pairing code...")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycard) {
                        return qsTr("Copying Keycard...")
                    }
                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize2
                font.weight: Font.Bold
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: image
                pattern: d.continuousProcessingAnimation?
                             Constants.keycardAnimations.processing.pattern :
                             Constants.keycardAnimations.warning.pattern
                source: ""
                startImgIndexForTheFirstLoop: d.continuousProcessingAnimation?
                                                  Constants.keycardAnimations.processing.startImgIndexForTheFirstLoop :
                                                  Constants.keycardAnimations.warning.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: d.continuousProcessingAnimation?
                                                Constants.keycardAnimations.processing.startImgIndexForOtherLoops :
                                                Constants.keycardAnimations.warning.startImgIndexForOtherLoops
                endImgIndex: d.continuousProcessingAnimation?
                                 Constants.keycardAnimations.processing.endImgIndex :
                                 Constants.keycardAnimations.warning.endImgIndex
                duration: d.continuousProcessingAnimation?
                              Constants.keycardAnimations.processing.duration :
                              Constants.keycardAnimations.warning.duration
                loops: d.continuousProcessingAnimation?
                           Constants.keycardAnimations.processing.loops :
                           Constants.keycardAnimations.warning.loops
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.noPCSCService
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.noPCSCService
            PropertyChanges {
                target: title
                text: qsTr("PCSC not available")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: message
                text: qsTr("The Smartcard reader (PCSC service), required\nfor using Keycard, is not currently working.\nEnsure PCSC is installed and running and try again")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
            }
        },
        State {
            name: Constants.keycardSharedState.notKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard
            PropertyChanges {
                target: title
                text: qsTr("This is not a Keycard")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: image
                pattern: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication?
                             "" : Constants.keycardAnimations.strongError.pattern
                source: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication?
                            Style.png("keycard/plain-error") : ""
                startImgIndexForTheFirstLoop: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication?
                                                  0 : Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication?
                                                0 : Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication?
                                 0 : Constants.keycardAnimations.strongError.endImgIndex
                duration: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication?
                              0 : Constants.keycardAnimations.strongError.duration
                loops: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication?
                           -1 : Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: message
                text: qsTr("The card inserted is not a recognised Keycard,\nplease remove and try and again")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
            }
        },
        State {
            name: Constants.keycardSharedState.unlockKeycardOptions
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardOptions
            PropertyChanges {
                target: title
                text: qsTr("Unlock this Keycard")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: message
                text: {
                    if (root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.disableSeedPhraseForUnlock &&
                            !(root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.offerPukForUnlock)) {
                        return qsTr("Please run \"Unlock Keycard\" flow directly")
                    }
                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycardSharedState.wrongKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard
            PropertyChanges {
                target: title
                text: qsTr("Wrong Keycard inserted")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/plain-error")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication ||
                            root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.renameKeycard ||
                            root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPin ||
                            root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changeKeycardPuk ||
                            root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.changePairingCode ||
                            root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.createCopyOfAKeycard) {
                        return qsTr("Keycard inserted does not match the Keycard below")
                    }
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.unlockKeycard) {
                        return qsTr("Keycard inserted does not match the Keycard you're trying to unlock")
                    }
                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.dangerColor1
            }
        },
        State {
            name: Constants.keycardSharedState.keycardEmptyMetadata
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata
            PropertyChanges {
                target: title
                text: qsTr("This Keycard has empty metadata")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: qsTr("This Keycard already stores keys\nbut doesn't store any metadata")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycardSharedState.keycardEmpty
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty
            PropertyChanges {
                target: title
                text: qsTr("Keycard is empty")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-empty")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: qsTr("There is no key pair on this Keycard")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycardSharedState.keycardNotEmpty
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty
            PropertyChanges {
                target: title
                text: qsTr("This Keycard already stores keys")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                        return qsTr("To migrate %1 on to this Keycard, you\nwill need to perform a factory reset first")
                        .arg(root.sharedKeycardModule.keyPairForProcessing.name)
                    }
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase ||
                            root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase) {
                        return qsTr("To create a new account on to this Keycard, you\nwill need to perform a factory reset first")
                    }
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.createCopyOfAKeycard) {
                        return qsTr("To copy %1 on to this Keycard, you\nwill need to perform a factory reset first")
                        .arg(root.sharedKeycardModule.keyPairForProcessing.name)
                    }

                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: "sharedLockedState"
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached
            PropertyChanges {
                target: title
                text: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard ||
                      root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase ||
                      root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase ||
                      root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.createCopyOfAKeycard?
                          qsTr("Keycard locked and already stores keys") : qsTr("Keycard locked")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard ||
                       root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase ||
                       root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase ||
                       root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.createCopyOfAKeycard?
                           Theme.palette.directColor1 : Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: message
                text: {
                    if (root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.useGeneralMessageForLockedState) {
                        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard ||
                                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase ||
                                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase ||
                                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.createCopyOfAKeycard)
                            return qsTr("The Keycard you have inserted is locked,\nyou will need to factory reset it before proceeding")
                        return qsTr("You will need to unlock it before proceeding")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached)
                        return qsTr("Pin entered incorrectly too many times")
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPukRetriesReached)
                        return qsTr("Puk entered incorrectly too many times")
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPairingSlotsReached)
                        return qsTr("Max pairing slots reached for the entered keycard")
                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize2
                color: root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard ||
                       root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase ||
                       root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase ||
                       root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.createCopyOfAKeycard?
                           Theme.palette.directColor1 : Theme.palette.dangerColor1
            }
        },
        State {
            name: Constants.keycardSharedState.keycardAlreadyUnlocked
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardAlreadyUnlocked
            PropertyChanges {
                target: title
                text: qsTr("Your Keycard is already unlocked!")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.success.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.success.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.success.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.success.endImgIndex
                duration: Constants.keycardAnimations.success.duration
                loops: Constants.keycardAnimations.success.loops
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.recognizedKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard
            PropertyChanges {
                target: title
                text: qsTr("Keycard recognized")
                font.pixelSize: Constants.keycard.general.fontSize2
                font.weight: Font.Normal
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.success.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.success.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.success.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.success.endImgIndex
                duration: Constants.keycardAnimations.success.duration
                loops: Constants.keycardAnimations.success.loops
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: "processing-success"
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhraseSuccess ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhraseSuccess ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycardSuccess ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardSuccess ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameSuccess ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPukSuccess ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCodeSuccess ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycardSuccess
            PropertyChanges {
                target: title
                text: {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess) {
                        return qsTr("Key pair successfully migrated")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhraseSuccess) {
                        return qsTr("New account successfully created")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhraseSuccess) {
                        return qsTr("Keycard is ready to use!")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycardSuccess) {
                        return qsTr("Account successfully imported")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess) {
                        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard ||
                                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase ||
                                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase ||
                                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.createCopyOfAKeycard)
                            return qsTr("Your Keycard has been reset")
                        return qsTr("Keycard successfully factory reset")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardSuccess) {
                        return qsTr("Unlock successful")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameSuccess) {
                        return qsTr("Keycard successfully renamed")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPukSuccess) {
                        return qsTr("Keycard’s PUK successfully set")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCodeSuccess) {
                        return qsTr("Pairing code successfully set")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycardSuccess) {
                        return qsTr("This Keycard is now a copy of %1")
                        .arg(root.sharedKeycardModule.keyPairForProcessing.name)
                    }
                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongSuccess.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongSuccess.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongSuccess.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongSuccess.endImgIndex
                duration: Constants.keycardAnimations.strongSuccess.duration
                loops: Constants.keycardAnimations.strongSuccess.loops
            }
            PropertyChanges {
                target: message
                text: {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess) {
                        return qsTr("To complete migration close Status and log in with your new Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess) {
                        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard ||
                                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardNewSeedPhrase ||
                                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase ||
                                root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.createCopyOfAKeycard)
                            return qsTr("You can now create a new key pair on this Keycard")
                        return qsTr("You can now use this Keycard as if it\nwas a brand new empty Keycard")
                    }
                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: "processing-failure"
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhraseFailure ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhraseFailure ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycardFailure ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameFailure ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardFailure ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPukFailure ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCodeFailure ||
                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycardFailure
            PropertyChanges {
                target: title
                text: {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure) {
                        return qsTr("Key pair failed to migrated")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountNewSeedPhraseFailure) {
                        return qsTr("Creating new account failed")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.creatingAccountOldSeedPhraseFailure) {
                        return qsTr("Setting a Keycard failed")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.importingFromKeycardFailure) {
                        return qsTr("Importing account failed")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardRenameFailure) {
                        return qsTr("Keycard renaming failed")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.unlockKeycardFailure) {
                        return qsTr("Unlock a Keycard failed")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPukFailure) {
                        return qsTr("Setting Keycard’s PUK failed")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.changingKeycardPairingCodeFailure) {
                        return qsTr("Setting pairing code failed")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyingKeycardFailure) {
                        return qsTr("Copying %1 Keycard failed")
                        .arg(root.sharedKeycardModule.keyPairForProcessing.name)
                    }
                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.keycardMetadataDisplay
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay
            PropertyChanges {
                target: title
                text: qsTr("Accounts on this Keycard")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.biometricsReadyToSign
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign
            PropertyChanges {
                target: title
                text: qsTr("Ready to authenticate...")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.biometricsPasswordFailed
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed
            PropertyChanges {
                target: image
                source: Style.png("keycard/biometrics-fail")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Biometric scan failed")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: message
                text: qsTr("Biometrics incorrect")
                color: Theme.palette.dangerColor1
            }
        },
        State {
            name: Constants.keycardSharedState.biometricsPinFailed
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed
            PropertyChanges {
                target: image
                source: Style.png("keycard/plain-error")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Biometric scan failed")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: message
                text: qsTr("Biometrics incorrect")
                color: Theme.palette.dangerColor1
            }
        },
        State {
            name: Constants.keycardSharedState.biometricsPinInvalid
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid
            PropertyChanges {
                target: image
                source: Style.png("keycard/plain-error")
                pattern: ""
            }
            PropertyChanges {
                target: title
                text: qsTr("Biometric pin invalid")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: message
                text: qsTr("The PIN length doesn't match Keycard's PIN length")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
            }
        },
        State {
            name: Constants.keycardSharedState.removeKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.removeKeycard
            PropertyChanges {
                target: title
                text: qsTr("Remove Keycard")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.cardRemoved.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.cardRemoved.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.cardRemoved.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.cardRemoved.endImgIndex
                duration: Constants.keycardAnimations.cardRemoved.duration
                loops: Constants.keycardAnimations.cardRemoved.loops
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.sameKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.sameKeycard
            PropertyChanges {
                target: title
                text: qsTr("Oops this is the same Keycard!")
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongError.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongError.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongError.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongError.endImgIndex
                duration: Constants.keycardAnimations.strongError.duration
                loops: Constants.keycardAnimations.strongError.loops
            }
            PropertyChanges {
                target: message
                text: qsTr("You need to remove this Keycard and insert\nan empty new or factory reset Keycard")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycardSharedState.copyToKeycard
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.copyToKeycard
            PropertyChanges {
                target: title
                text: qsTr("Copy “%1” to inserted keycard")
                .arg(root.sharedKeycardModule.keyPairForProcessing.name)
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                source: Style.png("keycard/card-inserted")
                pattern: ""
            }
            PropertyChanges {
                target: message
                text: ""
            }
        },
        State {
            name: Constants.keycardSharedState.seedPhraseAlreadyInUse
            when: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseAlreadyInUse
            PropertyChanges {
                target: title
                text: {
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycardOldSeedPhrase) {
                        return qsTr("This seed phrase has already been imported")
                    }
                    if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.importFromKeycard) {
                        return qsTr("This keycard has already been imported")
                    }
                    return ""
                }
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: image
                pattern: Constants.keycardAnimations.strongSuccess.pattern
                source: ""
                startImgIndexForTheFirstLoop: Constants.keycardAnimations.strongSuccess.startImgIndexForTheFirstLoop
                startImgIndexForOtherLoops: Constants.keycardAnimations.strongSuccess.startImgIndexForOtherLoops
                endImgIndex: Constants.keycardAnimations.strongSuccess.endImgIndex
                duration: Constants.keycardAnimations.strongSuccess.duration
                loops: Constants.keycardAnimations.strongSuccess.loops
            }
            PropertyChanges {
                target: message
                text: ""
            }
        }
    ]
}
