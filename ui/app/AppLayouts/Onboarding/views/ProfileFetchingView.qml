import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import AppLayouts.Onboarding.stores 1.0
import AppLayouts.Onboarding.shared 1.0

import utils 1.0

Item {
    id: root

    property StartupStore startupStore

    QtObject {
        id: d

        property int counter: Constants.onboarding.profileFetching.timeout
    }

    onStateChanged: {
        if (root.startupStore.currentStartupState.stateType === Constants.startupState.profileFetching) {
            d.counter = Constants.onboarding.profileFetching.timeout
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        height: Constants.keycard.general.onboardingHeight
        spacing: Style.current.bigPadding

        ProfileFetchingAnimation {
            id: loadingAnimation
            Layout.alignment: Qt.AlignHCenter
            state: root.state
        }

        StatusBaseText {
            id: title
            visible: text.length > 0
            Layout.alignment: Qt.AlignHCenter
            font.weight: Font.Bold
            font.pixelSize: Constants.onboarding.profileFetching.titleFontSize
        }

        ListView {
            Layout.preferredWidth: 345
            Layout.alignment: Qt.AlignCenter
            implicitHeight: contentItem.childrenRect.height

            clip: true
            spacing: 8

            model: root.startupStore.fetchingDataModel

            delegate: Item {
                width: ListView.view.width
                height: 32

                StatusIcon {
                    id: icon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    width: 20
                    height: 20

                    color: Theme.palette.baseColor1
                    icon: model.icon
                }

                Text {
                    id: entity
                    anchors.left: icon.right
                    anchors.right: indicator.visible? indicator.left : loaded.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 4
                    font.pixelSize: Constants.onboarding.profileFetching.entityFontSize
                    text: {
                        switch(model.entity) {
                        case Constants.onboarding.profileFetching.entity.profile:
                            return qsTr("Profile details")
                        case Constants.onboarding.profileFetching.entity.contacts:
                            return qsTr("Contacts")
                        case Constants.onboarding.profileFetching.entity.communities:
                            return qsTr("Community membership")
                        case Constants.onboarding.profileFetching.entity.settings:
                            return qsTr("Settings")
                        case Constants.onboarding.profileFetching.entity.keycards:
                            return qsTr("Keycards")
                        }
                    }
                }

                StatusLoadingIndicator {
                    id: indicator
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: model.totalMessages === 0
                }

                Text {
                    id: loaded
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !indicator.visible
                    rightPadding: 4
                    font.pixelSize: Constants.onboarding.profileFetching.entityProgressFontSize
                    color: Theme.palette.baseColor1
                    text: "%1/%2".arg(model.loadedMessages).arg(model.totalMessages)
                }

                StatusProgressBar {
                    id: progress
                    anchors.top: entity.bottom
                    anchors.left: entity.left
                    anchors.right: parent.right
                    anchors.topMargin: 4
                    height: 3
                    from: 0
                    to: model.totalMessages
                    value: model.loadedMessages
                    backgroundColor: Theme.palette.baseColor5
                    backgroundBorderColor: backgroundColor
                    fillColor: {
                        if (model.totalMessages > 0 && model.totalMessages === model.loadedMessages)
                            return Theme.palette.successColor1
                        return Theme.palette.primaryColor1
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }

        StatusButton {
            id: button
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.startupStore.currentStartupState.stateType === Constants.startupState.profileFetching? 80 : -1
            focus: true
            enabled: root.startupStore.currentStartupState.stateType !== Constants.startupState.profileFetching

            Timer {
                id: timer
                interval: 1000
                running: root.startupStore.currentStartupState.stateType === Constants.startupState.profileFetching
                repeat: true
                onTriggered: {
                    d.counter = d.counter - 1000 // decrease 1000 ms
                    if (d.counter == 0) {
                        root.startupStore.doPrimaryAction()
                    }
                }
            }

            onClicked: {
                root.startupStore.doPrimaryAction()
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    states: [
        State {
            name: Constants.startupState.profileFetching
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.profileFetching
            PropertyChanges {
                target: title
                text: qsTr("Fetching data...")
            }
            PropertyChanges {
                target: button
                text: {
                    let date = new Date(0)
                    date.setTime(date.getTime() + d.counter)
                    return Qt.formatTime(date, "m:ss")
                }
            }
            PropertyChanges {
                target: d
                counter: Constants.onboarding.profileFetching.timeout
            }
        },
        State {
            name: Constants.startupState.profileFetchingTimeout
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.profileFetchingTimeout
            PropertyChanges {
                target: title
                text: qsTr("Fetching data...")
            }
            PropertyChanges {
                target: button
                text: qsTr("Continue")
            }
        },
        State {
            name: Constants.startupState.profileFetchingSuccess
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.profileFetchingSuccess
            PropertyChanges {
                target: title
                text: qsTr("Fetching data...")
            }
            PropertyChanges {
                target: button
                text: qsTr("Continue")
            }
        }
    ]
}
