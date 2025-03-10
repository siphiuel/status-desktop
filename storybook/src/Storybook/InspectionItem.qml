import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    readonly property color visualItemColor: "black"
    readonly property color nonVisualItemColor: "green"

    readonly property color visualItemSelectionColor: "red"
    readonly property color nonVisualItemSelectionColor: "orange"

    readonly property bool selected: containsMouse || forceSelect

    readonly property color baseColor:
        isVisual ? visualItemColor
                 : (showNonVisual ? nonVisualItemColor : "transparent")

    readonly property color selectionColor: isVisual ? visualItemSelectionColor
                                                     : nonVisualItemSelectionColor

    border.color: selected ? selectionColor : baseColor
    border.width: selected ? 2 : 1
    color: 'transparent'

    required property string name
    required property bool isVisual
    property bool showNonVisual: false
    property bool forceSelect: false
    required property Item visualParent

    readonly property real topSpacing: mapToItem(visualParent, 0, 0).y

    readonly property real bottomSpacing:
        visualParent.height - mapToItem(visualParent, 0, height).y

    readonly property real leftSpacing: mapToItem(visualParent, 0, 0).x

    readonly property real rightSpacing:
        visualParent.width - mapToItem(visualParent, width, 0).x

    readonly property alias containsMouse: mouseArea.containsMouse

    component DistanceRectangle: Rectangle {
        width: 1
        height: 1
        color: selectionColor
        visible: root.selected
        parent: root.parent
    }

    // top
    DistanceRectangle {
        height: topSpacing
        anchors.bottom: root.top
        anchors.horizontalCenter: root.horizontalCenter
    }

    // left
    DistanceRectangle {
        width: leftSpacing
        anchors.right: root.left
        anchors.verticalCenter: root.verticalCenter
    }

    // right
    DistanceRectangle {
        width: rightSpacing
        anchors.left: root.right
        anchors.verticalCenter: root.verticalCenter
    }

    // bottom
    DistanceRectangle {
        height: bottomSpacing
        anchors.top: root.bottom
        anchors.horizontalCenter: root.horizontalCenter
    }

    Popup {
        x: parent.width + padding / 2
        y: parent.height + padding / 2

        visible: root.selected
        margins: 0

        ColumnLayout {
            Label {
                text: root.name
                font.bold: true
            }
            Label {
                text: `x: ${root.x}, y: ${root.y}`
            }
            Label {
                text: `size: ${root.width} x ${root.height}`
            }
            Label {
                text: `top space: ${root.topSpacing}`
            }
            Label {
                text: `bottom space: ${root.bottomSpacing}`
            }
            Label {
                text: `left space: ${root.leftSpacing}`
            }
            Label {
                text: `right space: ${root.rightSpacing}`
            }
        }
    }

    MouseArea {
        id: mouseArea

        visible: isVisual || showNonVisual
        anchors.fill: parent
        hoverEnabled: true
    }
}
