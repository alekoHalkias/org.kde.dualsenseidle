import QtQuick 6.0
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras

Item {
    id: controllerCard
    width: parent.width
    implicitHeight: cardWrapper.implicitHeight

    property alias controllerName: heading.text
    property int batteryLevel: 65
    property string idleTime: "14.3s"
    property string macAddress: "00:00:00:00:00:00"
    property bool expanded: false
    property bool hovered: false
    property int controllerIndex: -1


    HoverHandler {
        onHoveredChanged: controllerCard.hovered = hovered
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: false
        propagateComposedEvents: true
        z: -1

        onClicked: {
            if (!disconnectButton.containsPress) {
                controllerCard.expanded = !controllerCard.expanded
            }
        }
    }

    Item {
        id: cardWrapper
        anchors.margins: Kirigami.Units.mediumSpacing
        width: parent.width - Kirigami.Units.mediumSpacing * 2
        implicitHeight: columnContent.implicitHeight + dropdownWrapper.height

        PlasmaExtras.Highlight {
            anchors.fill: parent
            hovered: controllerCard.hovered
            z: -1
        }

        ColumnLayout {
            id: columnContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: Kirigami.Units.mediumSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                Kirigami.Icon {
                    source: "dualsense-white"
                    width: Kirigami.Units.gridUnit * 2
                    height: Kirigami.Units.gridUnit * 2
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Kirigami.Heading {
                        id: heading
                        level: 4
                        text: "DualSense Wireless Controller"
                        color: Kirigami.Theme.textColor
                    }

                    RowLayout {
                        spacing: 6
                        Layout.fillWidth: true

                        Label {
                            text: "🔋"
                            color: Kirigami.Theme.textColor
                        }

                        ProgressBar {
                            from: 0
                            to: 100
                            value: controllerCard.batteryLevel
                            Layout.fillWidth: true
                            height: 6
                        }

                        Label {
                            text: controllerCard.batteryLevel + "%"
                            color: Kirigami.Theme.textColor
                        }
                    }
                }

                Button {
                    id: disconnectButton
                    flat: true
                    padding: Kirigami.Units.mediumSpacing
                    onClicked: {
                        if (controllerIndex >= 0) {
                            bridge.disconnectByIndex(controllerIndex)
                        } else {
                            console.warn("Invalid controller index")
                        }
                    }
                    contentItem: Text {
                        text: "Disconnect"
                        color: Kirigami.Theme.negativeTextColor
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                PlasmaComponents3.ToolButton {
                    icon.name: controllerCard.expanded ? "go-up-symbolic" : "go-down-symbolic"
                    checkable: false
                    flat: true
                    onClicked: controllerCard.expanded = !controllerCard.expanded
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                }
            }
        }

        Item {
            id: dropdownWrapper
            anchors.top: columnContent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            clip: true

            property int collapsedHeight: 0
            property int expandedHeight: detailContent.implicitHeight
            height: controllerCard.expanded ? expandedHeight : collapsedHeight

            Behavior on height {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }

            Item {
                id: detailContent
                width: parent.width
                implicitHeight: detailLayout.implicitHeight

                Column {
                    id: detailLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Kirigami.Units.mediumSpacing

                    Rectangle {
                        height: 1
                        anchors.left: parent.left
                        anchors.right: parent.right
                        color: Kirigami.Theme.disabledTextColor
                        opacity: 0.5
                    }

                    Item {
                        width: parent.width
                        x: Kirigami.Units.gridUnit * 5
                        implicitHeight: textBlock.implicitHeight

                        ColumnLayout {
                            id: textBlock
                            width: parent.width
                            spacing: 4

                            Text {
                                text: "Idle Timeout: " + controllerCard.idleTime
                                color: Kirigami.Theme.disabledTextColor
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                            }

                            Text {
                                text: "Address: " + controllerCard.macAddress
                                font.family: "monospace"
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                color: Kirigami.Theme.disabledTextColor
                            }
                        }
                    }
                }
            }
        }
    }
}
