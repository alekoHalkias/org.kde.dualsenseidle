import QtQuick 6.0
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami 2.20 as Kirigami
import "../code/org.kde.dualsense" as Dualsense 

PlasmoidItem {
    id: root 
    // Data model
    ListModel {
        id: controllerModel
    }

    // D-Bus bridge
    Dualsense.DbusBridge {
        id: bridge

        onStatusChanged: {
            Qt.callLater(() => {
                try {
                    var parsed = JSON.parse(status)
                    var keys = Object.keys(parsed)

                    let existingControllers = {}
                    for (let i = 0; i < controllerModel.count; i++) {
                        let entry = controllerModel.get(i)
                        existingControllers[entry.mac] = { index: i, data: entry }
                    }

                    let seenMACs = {}

                    for (let i = 0; i < keys.length; i++) {
                        let device = parsed[keys[i]]
                        let mac = device.mac
                        seenMACs[mac] = true

                        let updatedData = {
                            name: device.name,
                            battery: parseInt(device.battery),
                            idle: device.idle_remaining.toFixed(1) + "s",
                            mac: mac,
                            player: device.player ?? -1,
                            expanded: existingControllers[mac]?.data.expanded || false
                        }

                        if (mac in existingControllers) {
                            let idx = existingControllers[mac].index
                            controllerModel.set(idx, updatedData)
                        } else {
                            controllerModel.append(updatedData)
                        }
                    }

                    for (let i = controllerModel.count - 1; i >= 0; i--) {
                        if (!seenMACs[controllerModel.get(i).mac]) {
                            controllerModel.remove(i)
                        }
                    }
                } catch (e) {
                    console.log("JSON parse error:", e)
                }
            })
        }
    }

    // Start polling only when plasmoid is open
    onExpandedChanged: {
        if (root.expanded) {
            bridge.refreshStatus()  // immediate refresh on open
        }
    }

    Timer {
        id: poller
        interval: 1000
        running: root.expanded
        repeat: true
        triggeredOnStart: true
        onTriggered: bridge.refreshStatus()
    }

    // Main view
    fullRepresentation: ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        contentItem: Flickable {
            contentWidth: parent.width
            contentHeight: controllerList.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            interactive: true
            clip: true

            Column {
                id: controllerList
                width: parent.width - Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.mediumSpacing
                padding: Kirigami.Units.largeSpacing

                Repeater {
                    model: controllerModel

                    delegate: ControllerCard {
                        controllerName: model.name
                        batteryLevel: model.battery
                        idleTime: model.idle
                        macAddress: model.mac
                        controllerIndex: model.player
                        expanded: model.expanded
                        onExpandedChanged: model.expanded = expanded
                    }
                }
            }
        }
    }
}
