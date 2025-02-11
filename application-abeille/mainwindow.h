#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "administrateur.h"
#include <QMainWindow>
#include "QGridLayout"

#include <QFocusEvent>
#include <QProcess>

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void mAdministrateur();
    void Utilisateur();
    void retour();
    void Auth();
    void EXIT();
private:
    Ui::MainWindow *ui;
    Administrateur admin;
};
#endif // MAINWINDOW_H
