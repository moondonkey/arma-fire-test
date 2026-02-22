/*
    fire_bridge.c
    Arma 3 callExtension DLL - reads and deletes fire mission files.

    Compile (MinGW-w64):
        gcc -shared -o fire_bridge_x64.dll fire_bridge.c -static

    Place fire_bridge_x64.dll in Arma 3 root directory (next to arma3server_x64.exe).

    SQF usage:
        _content = "fire_bridge" callExtension "C:\path\to\fire_mission.txt";
        // Returns file content as string, or "" if no file
        // File is deleted after reading
*/

#include <stdio.h>
#include <string.h>

__declspec(dllexport) void __stdcall RVExtensionVersion(char *output, int outputSize) {
    strncpy(output, "fire_bridge v1.0", outputSize - 1);
    output[outputSize - 1] = '\0';
}

__declspec(dllexport) void __stdcall RVExtension(char *output, int outputSize, const char *function) {
    // function = file path to read
    output[0] = '\0';

    FILE *f = fopen(function, "r");
    if (!f) return;

    size_t len = fread(output, 1, outputSize - 1, f);
    output[len] = '\0';
    fclose(f);

    // Delete file after reading
    remove(function);
}

__declspec(dllexport) int __stdcall RVExtensionArgs(char *output, int outputSize, const char *function, const char **argv, int argc) {
    // Not used, but required by Arma 3
    output[0] = '\0';
    return 0;
}
