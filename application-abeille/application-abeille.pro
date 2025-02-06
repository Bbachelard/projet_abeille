QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    acquisition.cpp \
    administrateur.cpp \
    dataexporter.cpp \
    dataimporter.cpp \
    main.cpp \
    mainwindow.cpp \
    ruche.cpp \
    utilisateur.cpp

HEADERS += \
    acquisition.h \
    administrateur.h \
    dataexporter.h \
    dataimporter.h \
    mainwindow.h \
    ruche.h \
    utilisateur.h

FORMS += \
    mainwindow.ui

# Default rules for deployment.
target.path = /home/pi
INSTALLS += target

RESOURCES += \
    ressource.qrc
