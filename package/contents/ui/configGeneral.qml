import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.ksysguard.faces as Faces
import org.kde.plasma.components as PlasmaComponents

KCM.SimpleKCM {
    id: page

    // Current values, bound to the entries in main.xml
    property string cfg_sensorIds: "[]"
    property string cfg_sensorLabels: "{}"

    // Default values, set by the config dialog
    property string cfg_sensorIdsDefault
    property string cfg_sensorLabelsDefault

    property string cfg_widgetTitle: "System stats"
    property string cfg_widgetTitleDefault: "System stats"

    property var labelMap: parseLabels(cfg_sensorLabels)

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

    function sameList(a, b) {
        return (a || []).join("\n") === (b || []).join("\n");
    }

    // config -> picker (e.g. initial load, or "Defaults" button)
    onCfg_sensorIdsChanged: {
        const ids = parseIds(cfg_sensorIds);
        if (!sameList(ids, choices.selected)) {
            choices.selected = ids;
        }
    }

    Kirigami.FormLayout {PlasmaComponents
        .TextField {
            Kirigami.FormData.label: i18n("Widget title:")
            Layout.fillWidth: true

            text: page.cfg_widgetTitle
            placeholderText: i18n("System stats")

            onTextChanged: {
                page.cfg_widgetTitle = text;
            }
        }

        Faces.Choices {
            id: choices
            Kirigami.FormData.label: i18n("Sensors:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 20

            supportsColors: false
            labelsEditable: true
            labels: page.labelMap

            Component.onCompleted: selected = page.parseIds(page.cfg_sensorIds)

            // picker -> config (add, remove, reorder)
            onSelectedChanged: {
                const ids = (selected || []).slice();
                if (!page.sameList(ids, page.parseIds(page.cfg_sensorIds))) {
                    page.cfg_sensorIds = JSON.stringify(ids);
                }
            }

            // Empty label means "use the sensor's own name"
            onSensorLabelChanged: (sensorId, label) => {
                const map = Object.assign({}, page.labelMap);
                if (label) {
                    map[sensorId] = label;
                } else {
                    delete map[sensorId];
                }
                page.cfg_sensorLabels = JSON.stringify(map);
            }
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Information
            text: i18n("Click the field to add a sensor, drag to reorder, and use the pencil to give a sensor a short custom label. Note that any sensor without a custom label displays its default name, which may cause visual overlap in the panel.")
        }
    }
}
