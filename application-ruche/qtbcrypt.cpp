// ----------------------------------------------------------------------------
// QtBCrypt
//
// https://github.com/andreybutov/qt-bcrypt
//
// Andrey Butov
// andreybutov@antair.com
//
// ----------------------------------------------------------------------------



#include "qtbcrypt.h"



#include "qtbcrypt.h"
#include <time.h>
#include <crypt.h>


extern "C" {
#define HAVE_CRYPT_R 1
// ou
#define __SKIP_GNU 1
#include <ow-crypt.h>
}



QString QtBCrypt::generateSalt()
{
    const int randomBytesSize = 16;
    char randomBytes[randomBytesSize];
    QtBCrypt::generateRandomBytes(randomBytes, randomBytesSize);

    int iterationCount = 12;

    const char* bcryptPrefix = "$2a$";

    char* salt = crypt_gensalt(bcryptPrefix,
                               iterationCount,
                               randomBytes,
                               randomBytesSize);

    return salt ? salt : "";
}



QString QtBCrypt::hashPassword(const QString& password, const QString& salt)
{
    char* hash = crypt(password.toLocal8Bit().data(), salt.toLocal8Bit().data());
    return  hash ? hash : "";
}



void QtBCrypt::generateRandomBytes(char* outBuffer, int bufferSize)
{
    srand(time(0x00));
    for ( int i = 0 ; i < bufferSize ; ++i ) {
        outBuffer[i] = rand() % 256;
    }
}
