#include <iostream>
#include <cstring>
#include <cerrno>
#include <dirent.h>

using namespace std;

static void processDirectory(DIR *dir);

int main(int argc, char *argv[])
{
    DIR *dir;
    struct dirent *dp;

    dir = opendir(argv[1]);
    processDirectory(dir);
    closedir(dir);

    return 0;
}

static void processDirectory(DIR *dir)
{
    if (!dir)
        return;
    struct dirent *dp;
    while (true) {
        dp = readdir(dir);
        if (dp == nullptr)
            break;
        if (strcmp(dp->d_name, ".") == 0 || strcmp(dp->d_name, "..") == 0)
            continue;
        if (dp->d_name[0] == '.')
            continue;
        if (dp->d_type != DT_DIR)
            continue;
        cout << dp->d_name << endl;
        DIR *newDir = opendir(dp->d_name);
        processDirectory(newDir);
        closedir(newDir);
    }

}
