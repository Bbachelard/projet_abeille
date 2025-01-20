#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::Administrateur()
{
    ui->pushButton->setVisible(false);
    ui->pushButton_2->setVisible(false);
}










void MainWindow::Utilisateur()
{
    ui->pushButton->setVisible(false);
    ui->pushButton_2->setVisible(false);
}
