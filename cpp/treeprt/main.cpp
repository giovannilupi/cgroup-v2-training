#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <cstring>
#include <cerrno>
#include <dirent.h>

using namespace std;

#define RED     "\033[31m"
#define GREEN   "\033[32m"
#define YELLOW  "\033[33m"
#define BLUE    "\033[34m"
#define MAGENTA "\033[35m"

#define CLEAR   "\033[0m"

static void ProcessDirectory(string aBaseName, string aDirName, int aLevel = 0);
static void PrintDirectory(string aBaseName, string aDirName, int aLevel);
static string GetFileContent(string aBaseName, string aFileName);
static string Indent(int aLevel);
static string TypeTrim(string aType);
static string MakePath(string aBase, string aLast);


int main(int argc, char *argv[])
{
    if (argc < 2)
        return 1;

    string path = argv[1];

    size_t posSep = path.find_last_of("/");
    string baseName = path.substr(0, posSep);
    string dirName = path.substr(posSep+1);

    ProcessDirectory(baseName, dirName, 1);
    return 0;
}

static void ProcessDirectory(string aBaseName, string aDirName, int aLevel)
{
    string path = MakePath(aBaseName, aDirName);
    DIR *dir = opendir(path.c_str());
    if (!dir)
        return;

    PrintDirectory(aBaseName, aDirName, aLevel);

    struct dirent *dp;
    while ((dp = readdir(dir))) {
        if (dp->d_type == DT_DIR && dp->d_name[0] != '.')
            ProcessDirectory(path, dp->d_name, aLevel + 1);
    }
    closedir(dir);
}

static void PrintDirectory(string aBaseName, string aDirName, int aLevel)
{
    string fullName = MakePath(aBaseName, aDirName);
    string cgtype = GetFileContent(fullName, "cgroup.type");
    string subtreeCtrl = GetFileContent(fullName, "cgroup.subtree_control");

    cout << Indent(aLevel) << aDirName << "  [" << MAGENTA << TypeTrim(cgtype) << CLEAR << "]";
    if (!subtreeCtrl.empty())
        cout << " (" << subtreeCtrl << ")";
    cout << endl;
    if (cgtype == "domain" || cgtype == "domain threaded") {
        string fContent = GetFileContent(fullName, "cgroup.procs");
        if (!fContent.empty())
            cout << Indent(aLevel) << "PIDS: {" << GREEN << fContent << CLEAR << "}" << endl;
    } else if (cgtype == "threaded") {
        string fContent = GetFileContent(fullName, "cgroup.threads");
        if (!fContent.empty())
            cout << Indent(aLevel) << "TIDS: {" << RED << fContent << CLEAR << "}" << endl;
    }
}

static string GetFileContent(string aBaseName, string aFileName)
{
    string pathName = MakePath(aBaseName, aFileName);

    ifstream is(pathName);
    string s;
    if (is.is_open()) {
        string s2;
        while (is >> s2) {
            if (s.size() > 0)
                s.append(" ");
            s.append(s2);
        }
        is.close();
    }
    return s;
}

static string Indent(int aLevel)
{
    ostringstream os;
    for (int i = 0; i < aLevel; ++i)
        os << "    ";
    return os.str();
}

static string TypeTrim(string aType)
{
    return (aType == "domain")
                ? "d"
                : (aType == "threaded")
                        ? "t"
                        : (aType == "domain threaded")
                            ? "dt"
                            : "di";
}

static string MakePath(string aBase, string aLast)
{
    return aBase + "/" + aLast;
}
