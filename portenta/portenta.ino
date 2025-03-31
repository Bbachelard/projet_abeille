#include "SDMMCBlockDevice.h" // Multi Media Card APIs
#include "FATFileSystem.h"    // API to run operations on a FAT file system
#include "mbed_rtc_time.h"    // Pour utiliser le RTC intégré de la Portenta

SDMMCBlockDevice blockDevice;
mbed::FATFileSystem fileSystem("fs");

#include "camera.h" // Arduino Mbed Core Camera APIs
#include "himax.h"  // API to read from the Himax camera found on the Portenta Vision Shield
HM01B0 himax;
Camera cam(himax);

FrameBuffer frameBuffer; // Buffer to save the camera stream

// Settings for our setup
#define IMAGE_HEIGHT (unsigned int)240
#define IMAGE_WIDTH (unsigned int)320
#define IMAGE_MODE CAMERA_GRAYSCALE
#define BITS_PER_PIXEL (unsigned int)8
#define PALETTE_COLORS_AMOUNT (unsigned int)(pow(2, BITS_PER_PIXEL))
#define PALETTE_SIZE  (unsigned int)(PALETTE_COLORS_AMOUNT * 4) // 4 bytes = 32bit per color (3 bytes RGB and 1 byte 0x00)
#define IMAGE_PATH_PREFIX "/fs/" // Préfixe du chemin des images

// Headers info
#define BITMAP_FILE_HEADER_SIZE (unsigned int)14 // For storing general information about the bitmap image file
#define DIB_HEADER_SIZE (unsigned int)40 // For storing information about the image and define the pixel format
#define HEADER_SIZE (BITMAP_FILE_HEADER_SIZE + DIB_HEADER_SIZE)

void setup() {
    Serial.begin(115200);
    while (!Serial && millis() < 5000);
    
    Serial.println("Mounting SD Card...");
    mountSDCard();
    Serial.println("SD Card mounted.");

    // Régler l'horloge en utilisant les macros de date et heure de compilation
    // Convertir la date et l'heure de compilation en timestamp
    char compile_date[12];
    char compile_time[9];
    sprintf(compile_date, "%s", __DATE__); // Format: "MMM DD YYYY"
    sprintf(compile_time, "%s", __TIME__); // Format: "HH:MM:SS"
    
    Serial.print("Compilation date: ");
    Serial.println(compile_date);
    Serial.print("Compilation time: ");
    Serial.println(compile_time);
    
    // Convertir la date et l'heure de compilation en structure tm
    struct tm compile_tm;
    static const char month_names[] = "JanFebMarAprMayJunJulAugSepOctNovDec";
    char month_str[4];
    sscanf(compile_date, "%s %d %d", month_str, &compile_tm.tm_mday, &compile_tm.tm_year);
    sscanf(compile_time, "%d:%d:%d", &compile_tm.tm_hour, &compile_tm.tm_min, &compile_tm.tm_sec);
    
    // Convertir le mois en nombre (0-11)
    compile_tm.tm_mon = (strstr(month_names, month_str) - month_names) / 3;
    compile_tm.tm_year -= 1900; // Ajuster l'année
    
    // Convertir la structure tm en timestamp Unix et définir l'horloge
    time_t compile_timestamp = mktime(&compile_tm);
    set_time(compile_timestamp);
    
    Serial.print("RTC set to compilation timestamp: ");
    Serial.println(compile_timestamp);
    
    // Init the cam QVGA, 30FPS, Grayscale
    if (!cam.begin(CAMERA_R320x240, IMAGE_MODE, 30)) {
        Serial.println("Unable to find the camera");
    }
    
    countDownBlink();
    Serial.println("Fetching camera image...");
    unsigned char *imageData = captureImage();
    digitalWrite(LEDB, HIGH);
    
    Serial.println("Saving image to SD card...");
    
    // Générer le nom du fichier avec la date et l'heure réelles
    char filename[100];
    
    // Obtenir l'heure actuelle
    time_t rawtime;
    struct tm * timeinfo;
    
    time(&rawtime);           // Obtenir l'heure Unix actuelle
    timeinfo = localtime(&rawtime); // Convertir en structure de temps local
    
    // Créer le nom de fichier avec le format souhaité
    sprintf(filename, "/fs/%04d-%02d-%02dT%02d-%02d-%02d_%03d.jpg", 
            timeinfo->tm_year + 1900,  // Année (à partir de 1900)
            timeinfo->tm_mon + 1,      // Mois (0-11, donc +1)
            timeinfo->tm_mday,         // Jour
            timeinfo->tm_hour,         // Heure
            timeinfo->tm_min,          // Minutes
            timeinfo->tm_sec,          // Secondes
            millis() % 1000);          // Millisecondes
    
    Serial.print("Attempting to save as: ");
    Serial.println(filename);
    
    // Afficher l'heure actuelle pour vérification
    Serial.print("Current time: ");
    Serial.print(timeinfo->tm_year + 1900);
    Serial.print("-");
    Serial.print(timeinfo->tm_mon + 1);
    Serial.print("-");
    Serial.print(timeinfo->tm_mday);
    Serial.print(" ");
    Serial.print(timeinfo->tm_hour);
    Serial.print(":");
    Serial.print(timeinfo->tm_min);
    Serial.print(":");
    Serial.println(timeinfo->tm_sec);
    
    // Sauvegarder l'image
    saveImage(imageData, filename);
    
    fileSystem.unmount();
    Serial.println("Done. You can now remove the SD card.");
}

void loop() {
    // Pour capture périodique, décommentez le code ci-dessous
    /*
    delay(60000); // Attendre 1 minute
    
    // Capturer une nouvelle image
    unsigned char *imageData = captureImage();
    
    // Génerer un nouveau nom de fichier avec l'horodatage actuel
    char filename[100];
    time_t rawtime;
    struct tm * timeinfo;
    
    time(&rawtime);
    timeinfo = localtime(&rawtime);
    
    sprintf(filename, "/fs/%04d-%02d-%02dT%02d-%02d-%02d_%03d.jpg", 
            timeinfo->tm_year + 1900, timeinfo->tm_mon + 1, timeinfo->tm_mday,
            timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec,
            millis() % 1000);
    
    Serial.print("Saving as: ");
    Serial.println(filename);
    
    // Sauvegarder l'image
    saveImage(imageData, filename);
    */
}

// Mount File system block
void mountSDCard() {
    int error = fileSystem.mount(&blockDevice);
    if (error) {
        Serial.println("Trying to reformat...");
        int formattingError = fileSystem.reformat(&blockDevice);
        if (formattingError) {            
            Serial.println("No SD Card found");
            while (1);
        }
    }
}

// Get the raw image data (8bpp grayscale)
unsigned char * captureImage() {
    if (cam.grabFrame(frameBuffer, 3000) == 0) {
        return frameBuffer.getBuffer();
    } else {
        Serial.println("could not grab the frame");
        while (1);
    }
}

// Set the headers data
void setFileHeaders(unsigned char *bitmapFileHeader, unsigned char *bitmapDIBHeader, int fileSize) {
    // Set the headers to 0
    memset(bitmapFileHeader, (unsigned char)(0), BITMAP_FILE_HEADER_SIZE);
    memset(bitmapDIBHeader, (unsigned char)(0), DIB_HEADER_SIZE);

    // File header
    bitmapFileHeader[0] = 'B';
    bitmapFileHeader[1] = 'M';
    bitmapFileHeader[2] = (unsigned char)(fileSize);
    bitmapFileHeader[3] = (unsigned char)(fileSize >> 8);
    bitmapFileHeader[4] = (unsigned char)(fileSize >> 16);
    bitmapFileHeader[5] = (unsigned char)(fileSize >> 24);
    bitmapFileHeader[10] = (unsigned char)HEADER_SIZE + PALETTE_SIZE;

    // Info header
    bitmapDIBHeader[0] = (unsigned char)(DIB_HEADER_SIZE);
    bitmapDIBHeader[4] = (unsigned char)(IMAGE_WIDTH);
    bitmapDIBHeader[5] = (unsigned char)(IMAGE_WIDTH >> 8);
    bitmapDIBHeader[8] = (unsigned char)(IMAGE_HEIGHT);
    bitmapDIBHeader[9] = (unsigned char)(IMAGE_HEIGHT >> 8);
    bitmapDIBHeader[14] = (unsigned char)(BITS_PER_PIXEL);
}

void setColorMap(unsigned char *colorMap) {
    //Init the palette with zeroes
    memset(colorMap, (unsigned char)(0), PALETTE_SIZE);
    
    // Gray scale color palette, 4 bytes per color (R, G, B, 0x00)
    for (int i = 0; i < PALETTE_COLORS_AMOUNT; i++) {
        colorMap[i * 4] = i;
        colorMap[i * 4 + 1] = i;
        colorMap[i * 4 + 2] = i;
    }
}

// Save the headers and the image data into the .jpg file
void saveImage(unsigned char *imageData, const char* imagePath) {
    int fileSize = BITMAP_FILE_HEADER_SIZE + DIB_HEADER_SIZE + IMAGE_WIDTH * IMAGE_HEIGHT;
    
    Serial.print("Opening file: ");
    Serial.println(imagePath);
    
    FILE *file = fopen(imagePath, "w");
    if (file == NULL) {
        Serial.println("Error opening file! Using default path.");
        file = fopen("/fs/image.jpg", "w"); // Fallback to default name
        if (file == NULL) {
            Serial.println("Still cannot open file. Aborting save.");
            return;
        }
        Serial.println("Opened default file successfully.");
    } else {
        Serial.println("Opened custom filename successfully!");
    }

    // Bitmap structure (Head + DIB Head + ColorMap + binary image)
    unsigned char bitmapFileHeader[BITMAP_FILE_HEADER_SIZE];
    unsigned char bitmapDIBHeader[DIB_HEADER_SIZE];
    unsigned char colorMap[PALETTE_SIZE]; // Needed for <= 8bpp grayscale bitmaps    

    setFileHeaders(bitmapFileHeader, bitmapDIBHeader, fileSize);
    setColorMap(colorMap);

    // Write the bitmap file
    fwrite(bitmapFileHeader, 1, BITMAP_FILE_HEADER_SIZE, file);
    fwrite(bitmapDIBHeader, 1, DIB_HEADER_SIZE, file);
    fwrite(colorMap, 1, PALETTE_SIZE, file);
    fwrite(imageData, 1, IMAGE_HEIGHT * IMAGE_WIDTH, file);

    // Close the file stream
    fclose(file);
    Serial.println("File saved successfully.");
}

void countDownBlink() {
    for (int i = 0; i < 6; i++) {
        digitalWrite(LEDG, i % 2);
        delay(500);
    }
    digitalWrite(LEDG, HIGH);
    digitalWrite(LEDB, LOW);
}
