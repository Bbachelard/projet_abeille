#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "utilisateur.h"
#include "ruche.h"
#include "administrateur.h"

#include <iostream>
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QLineEdit>
#include <QStackedLayout>
#include <QWidget>
#include "QString"


MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    admin.creerCompte("nom","moi");
}


MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::EXIT()
{
    QApplication::quit();
}


void MainWindow::mAdministrateur()
{
    ui->livre->setCurrentWidget(ui->p1);
}

void MainWindow::Auth()
{
    if(admin.authentification(ui->idt_2->text(), ui->pwd_2->text())==true){
        qDebug("juste");
        ui->livre->setCurrentWidget(ui->p3);
    }
    else{
        qDebug("pas juste");
     //   ui->autherror->set.text("")
    }
}


void MainWindow::Utilisateur()
{
    ui->livre->setCurrentWidget(ui->p2);
}

void MainWindow::retour()
{
    QWidget *widgets[7];
    widgets[0] = ui->p0;
    widgets[1] = ui->p1;
    widgets[2] = ui->p2;
    widgets[3] = ui->p3;
    widgets[4] = ui->p4;
    widgets[5] = ui->p5;

    for(int i=1;i<=5;i++)
    {
        if(ui->livre->currentWidget()==widgets[i])
        {
            int a = i-2;
            if (a<0)
            {
                a=0;
            }
            ui->livre->setCurrentWidget(widgets[a]);
        }
    }
}

    /*

    if(ui->livre->currentWidget()==widgets[1])
    {
        ui->livre->setCurrentWidget(widgets[0]);
    }
    else
    {
        if(ui->livre->currentWidget()==widgets[2])
        {
            ui->livre->setCurrentWidget(widgets[1]);
        }
        else
        {
            if(ui->livre->currentWidget()==widgets[3])
            {
                ui->livre->setCurrentWidget(widgets[2]);
            }
            else
            {

            }
        }
    }
}
    */
