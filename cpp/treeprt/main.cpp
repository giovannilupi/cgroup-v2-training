#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <cerrno>
#include <dirent.h>

using namespace std;

static void ProcessDirectory(string aDirName, int aLevel = 0);
static void PrintDirectory(string aPathName, string aDirName, int aLevel);
static string GetFileContent(string aDirName, string aFileName);
static void Indent(int aLevel);

int main(int argc, char *argv[])
{
    cout << argv[1] << endl;
    ProcessDirectory(argv[1], 1);
    return 0;
}

static void ProcessDirectory(string aDirName, int aLevel)
{
    DIR *dir;
    struct dirent *dp;

    dir = opendir(aDirName.c_str());
    if (!dir)
        return;

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

        PrintDirectory(aDirName, dp->d_name, aLevel);
        string newDirName = aDirName + "/" + dp->d_name;
        ProcessDirectory(newDirName, aLevel + 1);
    }
    closedir(dir);
}

static void PrintDirectory(string aPathName, string aDirName, int aLevel)
{
    string fullName = aPathName + "/" + aDirName;
    string cgtype = GetFileContent(fullName, "cgroup.type");
    string subtreeCtrl = GetFileContent(fullName, "cgroup.subtree_control");
    Indent(aLevel);
    cout << aDirName << "  [" << cgtype << "] (" << subtreeCtrl << ")" << endl;
}

static string GetFileContent(string aDirName, string aFileName)
{
    string pathName = aDirName + "/" + aFileName;
    //cout << ">>>>> opening " << pathName << endl;
    ifstream is(pathName);
    string s;
    if (is.is_open()) {
        is >> s;
        is.close();
    }
    return s;
}

static void Indent(int aLevel)
{
    for (int i = 0; i < aLevel; ++i)
        cout << "    ";
}

