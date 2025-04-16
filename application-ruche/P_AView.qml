import QtQuick 2.15
import QtQuick.Controls 2.15
import com.example.ruche 1.0
import QtQuick.Layouts 1.15

RucheList {
    // Configuration spécifique pour la vue administrateur
    backgroundSource: "qrc:/fond4.png"
    returnDirection: 2
    isAdminView: true

    Button {
        text: "gestion des alertes"
        width: 250
        height: 50
        anchors {
            top: parent.top
            left: parent.left
            margins: 10
            leftMargin: 520
            topMargin: 80
        }
        visible: isAdminView
        onClicked: {

            alertesModel.clear()
            alerteManager.getAllAlertes()
            alertePopup.open()
        }
    }

    Popup {
            id: alertePopup
            width: parent.width * 0.9
            height: parent.height * 0.8
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                       color: "white"
                       radius: 10
                       border.color: "#CCCCCC"
                       border.width: 1
                   }

                   // Contenu du popup
                   ColumnLayout {
                       anchors.fill: parent
                       anchors.margins: 15
                       spacing: 8

                       // Titre
                       Text {
                           text: "Liste des alertes"
                           font.pixelSize: 18
                           font.bold: true
                           Layout.alignment: Qt.AlignHCenter
                           Layout.bottomMargin: 5
                       }
                       RowLayout {
                           Layout.fillWidth: true
                           Layout.bottomMargin: 10
                           spacing: 10

                           Button {
                               text: "Ajouter"
                               Layout.preferredWidth: 100
                               Layout.preferredHeight: 30

                               background: Rectangle {
                                   color: parent.pressed ? "#388E3C" : "#4CAF50"
                                   radius: 4
                               }

                               contentItem: Text {
                                   text: parent.text
                                   color: "white"
                                   font.pixelSize: 12
                                   horizontalAlignment: Text.AlignHCenter
                                   verticalAlignment: Text.AlignVCenter
                               }

                               onClicked: {
                                   addAlerteDialog.open()
                               }
                           }

                           Button {
                               text: "Supprimer"
                               Layout.preferredWidth: 100
                               Layout.preferredHeight: 30
                               enabled: alertesListView.currentRow >= 0

                               background: Rectangle {
                                   color: parent.enabled ? (parent.pressed ? "#C62828" : "#F44336") : "#E0E0E0"
                                   radius: 4
                               }

                               contentItem: Text {
                                   text: parent.text
                                   color: parent.enabled ? "white" : "#9E9E9E"
                                   font.pixelSize: 12
                                   horizontalAlignment: Text.AlignHCenter
                                   verticalAlignment: Text.AlignVCenter
                               }

                               onClicked: {
                                   if (alertesListView.currentRow >= 0) {
                                       var selectedAlerte = alertesModel.get(alertesListView.currentRow)
                                       confirmDeleteDialog.alerteId = selectedAlerte.id
                                       confirmDeleteDialog.alerteNom = selectedAlerte.nom
                                       confirmDeleteDialog.open()
                                   }
                               }
                           }

                           Button {
                               text: "Modifier"
                               Layout.preferredWidth: 100
                               Layout.preferredHeight: 30
                               enabled: alertesListView.currentRow >= 0

                               background: Rectangle {
                                   color: parent.enabled ? (parent.pressed ? "#FFA000" : "#FFC107") : "#E0E0E0"
                                   radius: 4
                               }

                               contentItem: Text {
                                   text: parent.text
                                   color: parent.enabled ? "white" : "#9E9E9E"
                                   font.pixelSize: 12
                                   horizontalAlignment: Text.AlignHCenter
                                   verticalAlignment: Text.AlignVCenter
                               }

                               onClicked: {
                                   if (alertesListView.currentRow >= 0) {
                                       var selectedAlerte = alertesModel.get(alertesListView.currentRow)

                                       // Préremplir les champs du dialog avec les valeurs existantes
                                       editCapteurCombo.currentIndex = editCapteurCombo.find(selectedAlerte.id_capteur)
                                       editNomField.text = selectedAlerte.nom
                                       editPhraseField.text = selectedAlerte.phrase
                                       editValeurField.text = selectedAlerte.valeur.toString()
                                       editTypeCombo.currentIndex = selectedAlerte.type
                                       editStatutSwitch.checked = selectedAlerte.statut
                                       editSensCombo.currentIndex = selectedAlerte.sens

                                       // Stocker l'ID de l'alerte à modifier
                                       editAlerteDialog.alerteId = selectedAlerte.id

                                       // Ouvrir le dialog
                                       editAlerteDialog.open()
                                   }
                               }
                           }


                           Item { Layout.fillWidth: true } // Spacer
                       }

                       // En-têtes du tableau avec lignes de séparation
                       Rectangle {
                           Layout.fillWidth: true
                           height: 36
                           color: "#EEEEEE"
                           border.color: "#BDBDBD"
                           border.width: 1

                           RowLayout {
                               anchors.fill: parent
                               anchors.leftMargin: 5
                               anchors.rightMargin: 5
                               spacing: 0

                               Rectangle {
                                   Layout.preferredWidth: 30
                                   Layout.fillHeight: true
                                   color: "transparent"
                                   border.color: "#BDBDBD"
                                   border.width: 0
                                   Text {
                                       text: "ID"
                                       font.bold: true
                                       font.pixelSize: 11
                                       anchors.centerIn: parent
                                   }
                               }

                               Rectangle {
                                   Layout.preferredWidth: 1
                                   Layout.fillHeight: true
                                   color: "#BDBDBD"
                               }

                               Rectangle {
                                   Layout.preferredWidth: 50
                                   Layout.fillHeight: true
                                   color: "transparent"
                                   Text {
                                       text: "Capteur"
                                       font.bold: true
                                       font.pixelSize: 11
                                       anchors.centerIn: parent
                                   }
                               }

                               Rectangle {
                                   Layout.preferredWidth: 1
                                   Layout.fillHeight: true
                                   color: "#BDBDBD"
                               }

                               Rectangle {
                                   Layout.preferredWidth: 80
                                   Layout.fillHeight: true
                                   color: "transparent"
                                   Text {
                                       text: "Nom"
                                       font.bold: true
                                       font.pixelSize: 11
                                       anchors.centerIn: parent
                                   }
                               }

                               Rectangle {
                                   Layout.preferredWidth: 1
                                   Layout.fillHeight: true
                                   color: "#BDBDBD"
                               }

                               Rectangle {
                                   Layout.fillWidth: true
                                   Layout.fillHeight: true
                                   color: "transparent"
                                   Text {
                                       text: "Message"
                                       font.bold: true
                                       font.pixelSize: 11
                                       anchors.centerIn: parent
                                   }
                               }

                               Rectangle {
                                   Layout.preferredWidth: 1
                                   Layout.fillHeight: true
                                   color: "#BDBDBD"
                               }

                               Rectangle {
                                   Layout.preferredWidth: 50
                                   Layout.fillHeight: true
                                   color: "transparent"
                                   Text {
                                       text: "Valeur"
                                       font.bold: true
                                       font.pixelSize: 11
                                       anchors.centerIn: parent
                                   }
                               }

                               Rectangle {
                                   Layout.preferredWidth: 1
                                   Layout.fillHeight: true
                                   color: "#BDBDBD"
                               }

                               Rectangle {
                                   Layout.preferredWidth: 70
                                   Layout.fillHeight: true
                                   color: "transparent"
                                   Text {
                                       text: "Type"
                                       font.bold: true
                                       font.pixelSize: 11
                                       anchors.centerIn: parent
                                   }
                               }
                               Rectangle {
                                   Layout.preferredWidth: 1
                                   Layout.fillHeight: true
                                   color: "#BDBDBD"
                               }
                               Rectangle {
                                   Layout.preferredWidth: 50
                                   Layout.fillHeight: true
                                   color: "transparent"
                                   Text {
                                       text: "Sens"
                                       font.bold: true
                                       font.pixelSize: 11
                                       anchors.centerIn: parent
                                   }
                               }
                           }
                       }

                       // Contenu du tableau
                       ListView {
                           id: alertesListView
                           property int currentRow: -1
                           Layout.fillWidth: true
                           Layout.fillHeight: true
                           clip: true
                           spacing: 0

                           model: ListModel {
                               id: alertesModel
                           }

                           delegate: Rectangle {
                               width: alertesListView.width
                               height: 32
                               color: index % 2 === 0 ? "#F9F9F9" : "white"
                               border.color: alertesListView.currentRow === index ? "#1976D2" : "#E0E0E0"
                               border.width: 1
                               MouseArea {
                                   anchors.fill: parent
                                   onClicked: {
                                       alertesListView.currentRow = index
                                   }
                               }
                               RowLayout {
                                   anchors.fill: parent
                                   anchors.leftMargin: 5
                                   anchors.rightMargin: 5
                                   spacing: 0

                                   Rectangle {
                                       Layout.preferredWidth: 30
                                       Layout.fillHeight: true
                                       color: "transparent"
                                       Text {
                                           text: model.id
                                           font.pixelSize: 10
                                           anchors.centerIn: parent
                                       }
                                   }

                                   Rectangle {
                                       Layout.preferredWidth: 1
                                       Layout.fillHeight: true
                                       color: "#E0E0E0"
                                   }

                                   Rectangle {
                                       Layout.preferredWidth: 50
                                       Layout.fillHeight: true
                                       color: "transparent"
                                       Text {
                                           text: model.id_capteur
                                           font.pixelSize: 10
                                           anchors.centerIn: parent
                                       }
                                   }

                                   Rectangle {
                                       Layout.preferredWidth: 1
                                       Layout.fillHeight: true
                                       color: "#E0E0E0"
                                   }

                                   Rectangle {
                                       Layout.preferredWidth: 80
                                       Layout.fillHeight: true
                                       color: "transparent"
                                       Text {
                                           text: model.nom
                                           font.pixelSize: 10
                                           elide: Text.ElideRight
                                           anchors.fill: parent
                                           anchors.margins: 4
                                           horizontalAlignment: Text.AlignHCenter
                                           verticalAlignment: Text.AlignVCenter
                                       }
                                   }

                                   Rectangle {
                                       Layout.preferredWidth: 1
                                       Layout.fillHeight: true
                                       color: "#E0E0E0"
                                   }

                                   Rectangle {
                                       Layout.fillWidth: true
                                       Layout.fillHeight: true
                                       color: "transparent"
                                       Text {
                                           text: model.phrase
                                           font.pixelSize: 10
                                           elide: Text.ElideRight
                                           anchors.fill: parent
                                           anchors.margins: 4
                                           horizontalAlignment: Text.AlignLeft
                                           verticalAlignment: Text.AlignVCenter
                                       }
                                   }

                                   Rectangle {
                                       Layout.preferredWidth: 1
                                       Layout.fillHeight: true
                                       color: "#E0E0E0"
                                   }

                                   Rectangle {
                                       Layout.preferredWidth: 50
                                       Layout.fillHeight: true
                                       color: "transparent"
                                       Text {
                                           text: model.valeur
                                           font.pixelSize: 10
                                           anchors.centerIn: parent
                                       }
                                   }

                                   Rectangle {
                                       Layout.preferredWidth: 1
                                       Layout.fillHeight: true
                                       color: "#E0E0E0"
                                   }

                                   Rectangle {
                                       Layout.preferredWidth: 70
                                       Layout.fillHeight: true
                                       color: "transparent"

                                       Rectangle {
                                           width: 60
                                           height: 18
                                           radius: 9
                                           anchors.centerIn: parent
                                           color: {
                                               if (model.type === 0) return "#C8E6C9"      // Vert
                                               else if (model.type === 1) return "#FFF9C4" // Jaune
                                               else if (model.type === 2) return "#FFCDD2" // Rouge
                                               else return "#E0E0E0"                       // Gris
                                           }

                                           Text {
                                               anchors.centerIn: parent
                                               text: {
                                                   if (model.type === 0) return "Bon"
                                                   else if (model.type === 1) return "Modérée"
                                                   else if (model.type === 2) return "Critique"
                                                   else return "Inconnu"
                                               }
                                               font.pixelSize: 9
                                               font.bold: true
                                               color: {
                                                   if (model.type === 0) return "#388E3C"      // Vert foncé
                                                   else if (model.type === 1) return "#F57F17" // Orange foncé
                                                   else if (model.type === 2) return "#D32F2F" // Rouge foncé
                                                   else return "#616161"                       // Gris foncé
                                               }
                                           }
                                       }
                                   }
                                   Rectangle {
                                       Layout.preferredWidth: 1
                                       Layout.fillHeight: true
                                       color: "#E0E0E0"
                                   }
                                   Rectangle {
                                       Layout.preferredWidth: 50
                                       Layout.fillHeight: true
                                       color: "transparent"
                                       Text {
                                           text: {
                                               if(model.sens===false){
                                                   return "max"
                                               }
                                               else return "min"
                                           }
                                           font.pixelSize: 10
                                           anchors.centerIn: parent
                                       }
                                   }
                               }
                           }

                           ScrollBar.vertical: ScrollBar {
                               active: true
                           }
                       }

                // Bouton Fermer
                Button {
                    text: "Fermer"
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 35

                    background: Rectangle {
                        color: parent.pressed ? "#9E9E9E" : "#BDBDBD"
                        radius: 5
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        alertePopup.close()
                    }
                }
            }
        }

        // Connexion au DataManager
        Connections {
            target: alerteManager
            function onAlertesReceived(id, id_capteur, nom, phrase, valeur, statut, type, sens) {
                alertesModel.append({
                    "id": id,
                    "id_capteur": id_capteur,
                    "nom": nom,
                    "phrase": phrase,
                    "valeur": valeur,
                    "statut": statut,
                    "type": type,
                    "sens": sens
                })
            }
        }


        Dialog {
            id: addAlerteDialog
            title: "Ajouter une alerte"
            width: 500
            height: 480
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            contentItem: ColumnLayout {
                spacing: 15
                anchors.margins: 15

                // Sélection du capteur
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Capteur:"
                        Layout.preferredWidth: 80
                    }

                    ComboBox {
                        id: capteurCombo
                        Layout.fillWidth: true
                        model: ListModel {
                            id: capteursListModel
                            ListElement { capteurId: 1; nom: "Température" }
                            ListElement { capteurId: 2; nom: "Humidité" }
                            ListElement { capteurId: 3; nom: "Masse" }
                            ListElement { capteurId: 4; nom: "Pression" }
                        }
                        textRole: "nom"
                        valueRole: "capteurId"  // Changé aussi ici pour correspondre à la nouvelle propriété
                    }
                }

                // Nom de l'alerte
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Nom:"
                        Layout.preferredWidth: 80
                    }

                    TextField {
                        id: nomField
                        Layout.fillWidth: true
                        placeholderText: "Nom court de l'alerte"
                    }
                }

                // Phrase de l'alerte
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Message:"
                        Layout.preferredWidth: 80
                    }

                    TextField {
                        id: phraseField
                        Layout.fillWidth: true
                        placeholderText: "Message d'alerte affiché"
                    }
                }

                // Valeur seuil
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Valeur seuil:"
                        Layout.preferredWidth: 80
                    }

                    TextField {
                        id: valeurField
                        Layout.fillWidth: true
                        placeholderText: "Seuil de déclenchement"
                        validator: DoubleValidator {}
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }
                }

                // Type d'alerte
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Type:"
                        Layout.preferredWidth: 80
                    }

                    ComboBox {
                        id: typeCombo
                        Layout.fillWidth: true
                        model: [
                            { text: "Bon (0)", value: 0 },
                            { text: "Modérée (1)", value: 1 },
                            { text: "Critique (2)", value: 2 }
                        ]
                        textRole: "text"
                        valueRole: "value"
                        currentIndex: 1 // Modérée par défaut
                    }
                }
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Sens:"
                        Layout.preferredWidth: 80
                    }

                    ComboBox {
                        id: sensCombo
                        Layout.fillWidth: true
                        model: [
                            { text: "Max (0)", value: 0 },
                            { text: "Min (1)", value: 1 },
                        ]
                        textRole: "text"
                        valueRole: "value"
                        currentIndex: 1 // Modérée par défaut
                    }
                }

                // Active/Inactive
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Active :"
                        Layout.preferredWidth: 80
                    }

                    Switch {
                        id: statutSwitch
                        checked: true
                    }
                }


                // Boutons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Item { Layout.fillWidth: true } // Spacer

                    Button {
                        text: "Annuler"
                        Layout.preferredWidth: 100

                        background: Rectangle {
                            color: parent.pressed ? "#BDBDBD" : "#E0E0E0"
                            radius: 4
                        }

                        onClicked: {
                            addAlerteDialog.close()
                        }
                    }

                    Button {
                        text: "Ajouter"
                        Layout.preferredWidth: 100

                        background: Rectangle {
                            color: parent.pressed ? "#388E3C" : "#4CAF50"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Vérification des champs
                            if (nomField.text.trim() === "" || phraseField.text.trim() === "" || valeurField.text.trim() === "") {
                                return
                            }

                            // Appel à la fonction d'ajout d'alerte
                            var success = alerteManager.addAlerte(
                                capteurCombo.currentValue,
                                nomField.text.trim(),
                                phraseField.text.trim(),
                                parseFloat(valeurField.text),
                                statutSwitch.checked ? 1 : 0,
                                typeCombo.currentValue,
                                sensCombo.currentValue
                            )

                            if (success) {
                                addAlerteDialog.close()
                                // Rafraîchir la liste
                                alertesModel.clear()
                                alerteManager.getAllAlertes()
                            }
                        }
                    }
                }
            }
        }

        // Dialog de confirmation de suppression
        Dialog {
            id: confirmDeleteDialog
            title: "Confirmer la suppression"
            width: 350
            height: 180
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            property int alerteId: -1
            property string alerteNom: ""

            contentItem: ColumnLayout {
                spacing: 20
                anchors.margins: 15

                Text {
                    text: "Êtes-vous sûr de vouloir supprimer l'alerte \"" + confirmDeleteDialog.alerteNom + "\" ?"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Item { Layout.fillWidth: true } // Spacer

                    Button {
                        text: "Annuler"
                        Layout.preferredWidth: 100

                        background: Rectangle {
                            color: parent.pressed ? "#BDBDBD" : "#E0E0E0"
                            radius: 4
                        }

                        onClicked: {
                            confirmDeleteDialog.close()
                        }
                    }

                    Button {
                        text: "Supprimer"
                        Layout.preferredWidth: 100

                        background: Rectangle {
                            color: parent.pressed ? "#C62828" : "#F44336"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var success = alerteManager.deleteAlerte(confirmDeleteDialog.alerteId)
                            if (success) {
                                confirmDeleteDialog.close()
                                // Rafraîchir la liste
                                alertesModel.clear()
                                alerteManager.getAllAlertes()
                                alertesListView.currentRow = -1
                            }
                        }
                    }
                }
            }
        }
        Dialog {
            id: editAlerteDialog
            title: "Modifier une alerte"
            width: 500
            height: 480
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            // Propriété pour stocker l'ID de l'alerte à modifier
            property int alerteId: -1

            contentItem: ColumnLayout {
                spacing: 15
                anchors.margins: 15

                // Sélection du capteur
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Capteur:"
                        Layout.preferredWidth: 80
                    }

                    ComboBox {
                        id: editCapteurCombo
                        Layout.fillWidth: true
                        model: ListModel {
                            id: editCapteursListModel
                            ListElement { capteurId: 1; nom: "Température" }
                            ListElement { capteurId: 2; nom: "Humidité" }
                            ListElement { capteurId: 3; nom: "Masse" }
                            ListElement { capteurId: 4; nom: "Pression" }
                        }
                        textRole: "nom"
                        valueRole: "capteurId"

                        // Fonction pour trouver l'index à partir de l'ID du capteur
                        function find(id) {
                            for (var i = 0; i < model.count; i++) {
                                if (model.get(i).capteurId === id) {
                                    return i;
                                }
                            }
                            return 0; // Par défaut, retourne le premier élément
                        }
                    }
                }

                // Nom de l'alerte
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Nom:"
                        Layout.preferredWidth: 80
                    }

                    TextField {
                        id: editNomField
                        Layout.fillWidth: true
                        placeholderText: "Nom court de l'alerte"
                    }
                }

                // Phrase de l'alerte
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Message:"
                        Layout.preferredWidth: 80
                    }

                    TextField {
                        id: editPhraseField
                        Layout.fillWidth: true
                        placeholderText: "Message d'alerte affiché"
                    }
                }

                // Valeur seuil
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Valeur seuil:"
                        Layout.preferredWidth: 80
                    }

                    TextField {
                        id: editValeurField
                        Layout.fillWidth: true
                        placeholderText: "Seuil de déclenchement"
                        validator: DoubleValidator {}
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }
                }

                // Type d'alerte
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Type:"
                        Layout.preferredWidth: 80
                    }

                    ComboBox {
                        id: editTypeCombo
                        Layout.fillWidth: true
                        model: [
                            { text: "Bon (0)", value: 0 },
                            { text: "Modérée (1)", value: 1 },
                            { text: "Critique (2)", value: 2 }
                        ]
                        textRole: "text"
                        valueRole: "value"
                    }
                }
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Sens:"
                        Layout.preferredWidth: 80
                    }

                    ComboBox {
                        id: editSensCombo
                        Layout.fillWidth: true
                        model: [
                            { text: "Max ", value: 0 },
                            { text: "Min ", value: 1 },
                        ]
                        textRole: "text"
                        valueRole: "value"
                    }
                }

                // Active/Inactive
                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true

                    Text {
                        text: "Active :"
                        Layout.preferredWidth: 80
                    }

                    Switch {
                        id: editStatutSwitch
                    }
                }

                // Boutons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Item { Layout.fillWidth: true } // Spacer

                    Button {
                        text: "Annuler"
                        Layout.preferredWidth: 100

                        background: Rectangle {
                            color: parent.pressed ? "#BDBDBD" : "#E0E0E0"
                            radius: 4
                        }

                        onClicked: {
                            editAlerteDialog.close()
                        }
                    }

                    Button {
                        text: "Enregistrer"
                        Layout.preferredWidth: 100

                        background: Rectangle {
                            color: parent.pressed ? "#1976D2" : "#2196F3"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Vérification des champs
                            if (editNomField.text.trim() === "" || editPhraseField.text.trim() === "" || editValeurField.text.trim() === "") {
                                return
                            }

                            // Appel à la fonction de mise à jour d'alerte
                            var success = alerteManager.updateAlerte(
                                editAlerteDialog.alerteId,
                                editCapteurCombo.currentValue,
                                editNomField.text.trim(),
                                editPhraseField.text.trim(),
                                parseFloat(editValeurField.text),
                                editStatutSwitch.checked ? 1 : 0,
                                editTypeCombo.currentValue,
                                editSensCombo.currentValue
                            )

                            if (success) {
                                editAlerteDialog.close()
                                // Rafraîchir la liste
                                alertesModel.clear()
                                alerteManager.getAllAlertes()
                            }
                        }
                    }
                }
            }
        }
}
