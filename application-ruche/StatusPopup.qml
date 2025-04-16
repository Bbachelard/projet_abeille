import QtQuick 2.15
import QtQuick.Controls 2.15

Popup {
    id: statusPopup
    width: Math.min(parent.width * 0.8, statusText.width + 60)
    height: statusText.height + 40
    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    x: (parent.width - width) / 2
    y: 10

    property string message: ""
    property string type: "info"
    property int displayTime: 2500

    signal closed()

    // Timer pour fermer automatiquement
    Timer {
        id: statusTimer
        interval: displayTime
        onTriggered: {
            statusPopup.close();
            closed();
        }
    }

    background: Rectangle {
        color: {
            switch(type) {
                case "success": return "#e8f5e9";  // Vert clair
                case "warning": return "#fff8e1";  // Jaune clair
                case "error": return "#ffebee";    // Rouge clair
                default: return "#e3f2fd";         // Bleu clair (info)
            }
        }
        border.color: {
            switch(type) {
                case "success": return "#4caf50";  // Vert
                case "warning": return "#ff9800";  // Orange
                case "error": return "#f44336";    // Rouge
                default: return "#2196f3";         // Bleu (info)
            }
        }
        border.width: 1
        radius: 5
    }

    contentItem: Item {
        Text {
            id: statusText
            anchors.centerIn: parent
            text: message
            font.pixelSize: 14
            color: {
                switch(type) {
                    case "success": return "#2e7d32";  // Vert foncé
                    case "warning": return "#e65100";  // Orange foncé
                    case "error": return "#b71c1c";    // Rouge foncé
                    default: return "#0d47a1";         // Bleu foncé (info)
                }
            }
        }
    }

    // Fonction pour afficher le popup
    function show(msg, popupType) {
        message = msg;
        if (popupType) type = popupType;
        open();
        statusTimer.restart();
    }
}
