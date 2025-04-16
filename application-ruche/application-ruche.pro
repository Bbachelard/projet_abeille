QT += quick virtualkeyboard
QT += sql
QT += mqtt
CONFIG += c++11 qml_debug


# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        MqttHandler.cpp \
        configurateurruche.cpp \
        datamanager_auth.cpp \
        datamanager_capteur.cpp \
        datamanager_core.cpp \
        datamanager_ruche.cpp \
        datamanger_alerte.cpp \
        main.cpp \
        openwall_crypt/crypt_blowfish.c \
        openwall_crypt/crypt_gensalt.c \
        openwall_crypt/wrapper.c \
        qtbcrypt.cpp \
        ruche.cpp

RESOURCES += qml.qrc \
    images.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.

HEADERS += \
    AlerteDataManager.h \
    MqttHandler.h \
    RucheDataManager.h \
    SensorDataManager.h \
    UserDataManager.h \
    configurateurruche.h \
    data.h \
    dataManager.h \
    openwall_crypt/crypt.h \
    openwall_crypt/crypt_blowfish.h \
    openwall_crypt/crypt_gensalt.h \
    openwall_crypt/ow-crypt.h \
    qtbcrypt.h \
    ruche.h

DISTFILES += \
    ../../../../../media/benjy/BT-7274/cours/projets/projet ruche/design IHM/arressai.png \
    openwall_crypt/x86.S


target.path = /home/pi/ruche_connectee
INSTALLS += target

