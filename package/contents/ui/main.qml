import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.ksysguard.sensors as Sensors
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

PlasmoidItem {
    id: root

    // Configuration

    readonly property var sensorIds: parseIds(Plasmoid.configuration.sensorIds)
    readonly property var customLabels: parseLabels(Plasmoid.configuration.sensorLabels)
    readonly property bool showAnySensor: sensorIds.length > 0
    readonly property string widgetTitle: Plasmoid.configuration.widgetTitle || i18n("System stats")

    // The sensor list is stored as a JSON array in a plain string entry
    function parseIds(json) {
        try {
            const parsed = JSON.parse(json || "[]");
            return Array.isArray(parsed) ? parsed.filter(id => typeof id === "string" && id !== "") : [];
        } catch (e) {
            return [];
        }
    }

    function parseLabels(json) {
        try {
            const parsed = JSON.parse(json || "{}");
            return (parsed && typeof parsed === "object") ? parsed : {};
        } catch (e) {
            return {};
        }
    }

    function valueText(sensor, fallback) {
        return sensor && sensor.formattedValue ? sensor.formattedValue : fallback;
    }

    function labelFor(sensorId, sensor) {
        return customLabels[sensorId] || (sensor && sensor.name) || sensorId;
    }

    // Tooltip
    toolTipSubText: ""

    // Compact representation

    compactRepresentation: Item {
        id: compact

        readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

        Layout.minimumWidth: compact.vertical ? 0 : grid.implicitWidth
        Layout.preferredWidth: compact.vertical ? 0 : grid.implicitWidth
        Layout.minimumHeight: compact.vertical ? grid.implicitHeight : 0
        Layout.preferredHeight: compact.vertical ? grid.implicitHeight : 0

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }

        // Fallback icon so the widget never collapses to nothing
        Kirigami.Icon {
            anchors.fill: parent
            source: Plasmoid.icon
            visible: !root.showAnySensor
        }

        // Horizontal panel: sensors side by side. Vertical panel: stacked.
        GridLayout {
            id: grid
            anchors.centerIn: parent
            width: compact.vertical ? compact.width : implicitWidth
            visible: root.showAnySensor
            columns: compact.vertical ? 1 : Math.max(1, root.sensorIds.length)
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.smallSpacing * 2

            Repeater {
                model: root.sensorIds

                delegate: GridLayout {
                    id: item
                    required property string modelData

                    readonly property string customLabel: root.customLabels[modelData] || ""

                    Sensors.Sensor {
                        id: compactSensor
                        sensorId: item.modelData
                    }

                    // Sensor name beside the value in horizontal panels, above it in vertical ones
                    columns: compact.vertical ? 1 : 2
                    rowSpacing: 0
                    columnSpacing: Kirigami.Units.smallSpacing / 2
                    Layout.fillWidth: compact.vertical
                    Layout.alignment: Qt.AlignCenter

                    PlasmaComponents.Label {
                        text: root.labelFor(item.modelData, compactSensor)
                        font: Kirigami.Theme.smallFont
                        opacity: 0.7
                        Layout.alignment: Qt.AlignCenter
                    }

                    PlasmaComponents.Label {
                        text: root.valueText(compactSensor, "--")
                        font: Kirigami.Theme.smallFont
                        Layout.fillWidth: compact.vertical
                        horizontalAlignment: Text.AlignHCenter
                        // Shrink text to fit narrow vertical panels
                        fontSizeMode: compact.vertical ? Text.HorizontalFit : Text.FixedSize
                        minimumPixelSize: 8
                    }
                }
            }
        }
    }

    // Full representation

    fullRepresentation: Item {
        id: full

        readonly property int margin: Kirigami.Units.largeSpacing

        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: Math.min(content.implicitHeight + margin * 2, Kirigami.Units.gridUnit * 24)
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: full.margin
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Heading {
                level: 3
                text: root.widgetTitle
                Layout.alignment: Qt.AlignHCenter
            }

            ListView {
                id: list
                visible: root.showAnySensor
                model: root.sensorIds
                clip: true
                spacing: Kirigami.Units.smallSpacing
                boundsBehavior: Flickable.StopAtBounds

                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: contentHeight

                PlasmaComponents.ScrollBar.vertical: PlasmaComponents.ScrollBar {}

                delegate: RowLayout {
                    id: row
                    required property string modelData
                    width: list.width

                    Sensors.Sensor {
                        id: rowSensor
                        sensorId: row.modelData
                    }

                    PlasmaComponents.Label {
                        text: root.labelFor(row.modelData, rowSensor)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    PlasmaComponents.Label {
                        text: root.valueText(rowSensor, "--")
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            PlasmaComponents.Label {
                visible: !root.showAnySensor
                text: i18n("No sensors selected. Right-click the widget and choose Configure to add some.")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }
}
