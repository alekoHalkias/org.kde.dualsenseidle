import QtQuick 6.0
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami 2.20 as Kirigami
import org.kde.dualsense 1.1

ApplicationWindow {
    visible: true
    width: 500
    height: 400
    title: "DbusBridge Test View"

    ListModel { id: controllerModel }

    DbusBridge {
        id: bridge

        onStatusChanged: {
            console.log("Raw status:", status)

            try {
                var parsed = JSON.parse(status)
                var keys = Object.keys(parsed)

                // Map current controllers by MAC
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
                        expanded: existingControllers[mac]?.data.expanded || false
                    }

                    if (mac in existingControllers) {
                        // Update only if data changed
                        let idx = existingControllers[mac].index
                        controllerModel.set(idx, updatedData)
                    } else {
                        controllerModel.append(updatedData)
                    }
                }

                // Remove any items not in the new data
                for (let i = controllerModel.count - 1; i >= 0; i--) {
                    if (!seenMACs[controllerModel.get(i).mac]) {
                        controllerModel.remove(i)
                    }
                }

            } catch (e) {
                console.log("JSON parse error:", e)
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: bridge.refreshStatus()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                width: parent.width
                spacing: Kirigami.Units.mediumSpacing

                Repeater {
                    model: controllerModel

                    ControllerCard {
                        controllerName: model.name
                        batteryLevel: model.battery
                        idleTime: model.idle
                        macAddress: model.mac

                        expanded: model.expanded
                        onExpandedChanged: model.expanded = expanded
                    }
                }
            }
        }
    }
}
