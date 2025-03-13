import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: parent.width
    height: parent.height
    Image {
        source: "qrc:/fond1.png"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        z: -1
    }
    Button {
        text: "retour"
        width: 100
        height: 40
        anchors {
            top: parent.top
            left: parent.left
            margins: 10
            leftMargin: 680
        }
        onClicked: {
            livre.direction = 2;
            livre.pop()
        }
    }
}
