/****************************************************************************
** Meta object code from reading C++ file 'data.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "data.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'data.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_Data_t {
    QByteArrayData data[7];
    char stringdata0[57];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Data_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Data_t qt_meta_stringdata_Data = {
    {
QT_MOC_LITERAL(0, 0, 4), // "Data"
QT_MOC_LITERAL(1, 5, 11), // "temperature"
QT_MOC_LITERAL(2, 17, 8), // "humidity"
QT_MOC_LITERAL(3, 26, 4), // "mass"
QT_MOC_LITERAL(4, 31, 8), // "pression"
QT_MOC_LITERAL(5, 40, 7), // "imgPath"
QT_MOC_LITERAL(6, 48, 8) // "dateTime"

    },
    "Data\0temperature\0humidity\0mass\0pression\0"
    "imgPath\0dateTime"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Data[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       6,   14, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       4,       // flags
       0,       // signalCount

 // properties: name, type, flags
       1, QMetaType::Float, 0x00095003,
       2, QMetaType::Float, 0x00095003,
       3, QMetaType::Float, 0x00095003,
       4, QMetaType::Float, 0x00095003,
       5, QMetaType::QString, 0x00095003,
       6, QMetaType::QString, 0x00095103,

       0        // eod
};

void Data::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{

#ifndef QT_NO_PROPERTIES
    if (_c == QMetaObject::ReadProperty) {
        auto *_t = reinterpret_cast<Data *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< float*>(_v) = _t->temperature; break;
        case 1: *reinterpret_cast< float*>(_v) = _t->humidity; break;
        case 2: *reinterpret_cast< float*>(_v) = _t->mass; break;
        case 3: *reinterpret_cast< float*>(_v) = _t->pression; break;
        case 4: *reinterpret_cast< QString*>(_v) = _t->imgPath; break;
        case 5: *reinterpret_cast< QString*>(_v) = _t->getDateTime(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = reinterpret_cast<Data *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0:
            if (_t->temperature != *reinterpret_cast< float*>(_v)) {
                _t->temperature = *reinterpret_cast< float*>(_v);
            }
            break;
        case 1:
            if (_t->humidity != *reinterpret_cast< float*>(_v)) {
                _t->humidity = *reinterpret_cast< float*>(_v);
            }
            break;
        case 2:
            if (_t->mass != *reinterpret_cast< float*>(_v)) {
                _t->mass = *reinterpret_cast< float*>(_v);
            }
            break;
        case 3:
            if (_t->pression != *reinterpret_cast< float*>(_v)) {
                _t->pression = *reinterpret_cast< float*>(_v);
            }
            break;
        case 4:
            if (_t->imgPath != *reinterpret_cast< QString*>(_v)) {
                _t->imgPath = *reinterpret_cast< QString*>(_v);
            }
            break;
        case 5: _t->setDateTime(*reinterpret_cast< QString*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
    Q_UNUSED(_o);
    Q_UNUSED(_id);
    Q_UNUSED(_c);
    Q_UNUSED(_a);
}

QT_INIT_METAOBJECT const QMetaObject Data::staticMetaObject = { {
    nullptr,
    qt_meta_stringdata_Data.data,
    qt_meta_data_Data,
    qt_static_metacall,
    nullptr,
    nullptr
} };

QT_WARNING_POP
QT_END_MOC_NAMESPACE
