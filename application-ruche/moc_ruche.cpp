/****************************************************************************
** Meta object code from reading C++ file 'ruche.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "ruche.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ruche.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_Ruche_t {
    QByteArrayData data[20];
    char stringdata0[222];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Ruche_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Ruche_t qt_meta_stringdata_Ruche = {
    {
QT_MOC_LITERAL(0, 0, 5), // "Ruche"
QT_MOC_LITERAL(1, 6, 9), // "idChanged"
QT_MOC_LITERAL(2, 16, 0), // ""
QT_MOC_LITERAL(3, 17, 11), // "nameChanged"
QT_MOC_LITERAL(4, 29, 18), // "mqttAdresseChanged"
QT_MOC_LITERAL(5, 48, 18), // "temperatureChanged"
QT_MOC_LITERAL(6, 67, 15), // "humidityChanged"
QT_MOC_LITERAL(7, 83, 11), // "massChanged"
QT_MOC_LITERAL(8, 95, 15), // "pressureChanged"
QT_MOC_LITERAL(9, 111, 16), // "imagePathChanged"
QT_MOC_LITERAL(10, 128, 17), // "lastUpdateChanged"
QT_MOC_LITERAL(11, 146, 2), // "id"
QT_MOC_LITERAL(12, 149, 4), // "name"
QT_MOC_LITERAL(13, 154, 11), // "mqttAdresse"
QT_MOC_LITERAL(14, 166, 11), // "temperature"
QT_MOC_LITERAL(15, 178, 8), // "humidity"
QT_MOC_LITERAL(16, 187, 4), // "mass"
QT_MOC_LITERAL(17, 192, 8), // "pressure"
QT_MOC_LITERAL(18, 201, 9), // "imagePath"
QT_MOC_LITERAL(19, 211, 10) // "lastUpdate"

    },
    "Ruche\0idChanged\0\0nameChanged\0"
    "mqttAdresseChanged\0temperatureChanged\0"
    "humidityChanged\0massChanged\0pressureChanged\0"
    "imagePathChanged\0lastUpdateChanged\0"
    "id\0name\0mqttAdresse\0temperature\0"
    "humidity\0mass\0pressure\0imagePath\0"
    "lastUpdate"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Ruche[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       9,   68, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       9,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   59,    2, 0x06 /* Public */,
       3,    0,   60,    2, 0x06 /* Public */,
       4,    0,   61,    2, 0x06 /* Public */,
       5,    0,   62,    2, 0x06 /* Public */,
       6,    0,   63,    2, 0x06 /* Public */,
       7,    0,   64,    2, 0x06 /* Public */,
       8,    0,   65,    2, 0x06 /* Public */,
       9,    0,   66,    2, 0x06 /* Public */,
      10,    0,   67,    2, 0x06 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // properties: name, type, flags
      11, QMetaType::Int, 0x00495103,
      12, QMetaType::QString, 0x00495103,
      13, QMetaType::QString, 0x00495103,
      14, QMetaType::Float, 0x00495001,
      15, QMetaType::Float, 0x00495001,
      16, QMetaType::Float, 0x00495001,
      17, QMetaType::Float, 0x00495001,
      18, QMetaType::QString, 0x00495001,
      19, QMetaType::QDateTime, 0x00495001,

 // properties: notify_signal_id
       0,
       1,
       2,
       3,
       4,
       5,
       6,
       7,
       8,

       0        // eod
};

void Ruche::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<Ruche *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->idChanged(); break;
        case 1: _t->nameChanged(); break;
        case 2: _t->mqttAdresseChanged(); break;
        case 3: _t->temperatureChanged(); break;
        case 4: _t->humidityChanged(); break;
        case 5: _t->massChanged(); break;
        case 6: _t->pressureChanged(); break;
        case 7: _t->imagePathChanged(); break;
        case 8: _t->lastUpdateChanged(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (Ruche::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Ruche::idChanged)) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (Ruche::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Ruche::nameChanged)) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (Ruche::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Ruche::mqttAdresseChanged)) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (Ruche::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Ruche::temperatureChanged)) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (Ruche::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Ruche::humidityChanged)) {
                *result = 4;
                return;
            }
        }
        {
            using _t = void (Ruche::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Ruche::massChanged)) {
                *result = 5;
                return;
            }
        }
        {
            using _t = void (Ruche::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Ruche::pressureChanged)) {
                *result = 6;
                return;
            }
        }
        {
            using _t = void (Ruche::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Ruche::imagePathChanged)) {
                *result = 7;
                return;
            }
        }
        {
            using _t = void (Ruche::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Ruche::lastUpdateChanged)) {
                *result = 8;
                return;
            }
        }
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<Ruche *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< int*>(_v) = _t->getId(); break;
        case 1: *reinterpret_cast< QString*>(_v) = _t->getName(); break;
        case 2: *reinterpret_cast< QString*>(_v) = _t->getMqttAdresse(); break;
        case 3: *reinterpret_cast< float*>(_v) = _t->getTemperature(); break;
        case 4: *reinterpret_cast< float*>(_v) = _t->getHumidity(); break;
        case 5: *reinterpret_cast< float*>(_v) = _t->getMass(); break;
        case 6: *reinterpret_cast< float*>(_v) = _t->getPressure(); break;
        case 7: *reinterpret_cast< QString*>(_v) = _t->getImagePath(); break;
        case 8: *reinterpret_cast< QDateTime*>(_v) = _t->getLastUpdate(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<Ruche *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setId(*reinterpret_cast< int*>(_v)); break;
        case 1: _t->setName(*reinterpret_cast< QString*>(_v)); break;
        case 2: _t->setMqttAdresse(*reinterpret_cast< QString*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
    Q_UNUSED(_a);
}

QT_INIT_METAOBJECT const QMetaObject Ruche::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_Ruche.data,
    qt_meta_data_Ruche,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *Ruche::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Ruche::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_Ruche.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int Ruche::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 9)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 9)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 9;
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 9;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 9;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 9;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 9;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 9;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void Ruche::idChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void Ruche::nameChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void Ruche::mqttAdresseChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void Ruche::temperatureChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void Ruche::humidityChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void Ruche::massChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void Ruche::pressureChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void Ruche::imagePathChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void Ruche::lastUpdateChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
