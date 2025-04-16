import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.example.ruche 1.0
import Qt.labs.settings 1.0


Item {
    id: root
    width: parent ? parent.width : 800
    height: parent ? parent.height : 480
    property int rucheId: -1
    property string rucheName: "Ruche"
    property var rucheData: []

    StatusPopup {
       id: statusMessage
   }

    RucheView {
        id: rucheView
        anchors.fill: parent

        backgroundSource: "qrc:/fond5.png"
        returnDirection: 1
        isViewA: true

        rucheId: root.rucheId
        rucheName: root.rucheName
        rucheData: root.rucheData
    }

    Component.onCompleted: {
        console.log("P_AData onCompleted - rucheId:", root.rucheId);
        rucheView.rucheId = root.rucheId;
        rucheView.rucheName = root.rucheName;
        rucheView.rucheData = root.rucheData;
    }
    Settings {
            id: intervalSettings
            category: "IntervalConfig"
            property int savedHeures: 0
            property int savedMinutes: 0
        }
    Popup {
        id: intervalPopup
        width: 400
        height: 250
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        anchors.centerIn: parent

        Column {
            anchors.fill: parent
            spacing: 20
            padding: 10

            Text {
                text: "Définir l'intervalle de temps"
                font.pixelSize: 16
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                SpinBox {
                    id: heuresSpinBox
                    from: 0
                    to: 23
                    value: 0

                    textFromValue: function(value) {
                        return value.toString().padStart(2, "0")
                    }
                }

                Text {
                    text: "h "
                    anchors.verticalCenter: parent.verticalCenter
                }

                SpinBox {
                    id: minutesSpinBox
                    from: 0
                    to: 59
                    value: 0

                    textFromValue: function(value) {
                        return value.toString().padStart(2, "0")
                    }
                }

                Text {
                    text: "min"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    width: 100
                    height: 40
                    text: "Annuler"
                    background: Rectangle {
                        color: parent.pressed ? "#ccc" : "#ddd"
                        radius: 5
                    }
                    onClicked: intervalPopup.close()
                }

                Button {
                    width: 100
                    height: 40
                    text: "Valider"
                    background: Rectangle {
                        color: parent.pressed ? "#2196F3" : "#3F51B5"
                        radius: 5
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        var heures = heuresSpinBox.value
                        var minutes = minutesSpinBox.value
                        var tempsMs = (heures * 60 * 60 * 1000) + (minutes * 60 * 1000)
                        var tempsFormate = (heures > 0 ? heures + "h " : "") + minutes + "min"

                        intervalSettings.savedHeures = heures
                        intervalSettings.savedMinutes = minutes
                        // Envoi du message MQTT
                        var message = "intervalle:" + tempsMs
                        mqttHandler.sendMqttMessage(rucheName, message)
                        intervalPopup.close()
                        statusMessage.show("Intervalle de " + tempsFormate + " configuré", "info")
                    }
                }
            }
        }
    }
}
