#include <QApplication>
#include "mainwindow.h"
#include <QInputMethod>

int main(int argc, char *argv[])
{
    // Activer le Qt Virtual Keyboard
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QApplication a(argc, argv);
    MainWindow w;
    w.showFullScreen();
    w.show();

    return a.exec();
}
