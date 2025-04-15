import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.example.ruche 1.0


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
}
