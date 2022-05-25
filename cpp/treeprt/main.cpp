#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <cstring>
#include <cerrno>
#include <dirent.h>

using namespace std;

static void ProcessDirectory(string aBaseName, string aDirName, int aLevel = 0);
static void PrintDirectory(string aBaseName, string aDirName, int aLevel);
static string GetFileContent(string aBaseName, string aFileName);
static string Indent(int aLevel);
static string TypeTrim(string type);
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
    DIR *dir;
    struct dirent *dp;

    string path = MakePath(aBaseName, aDirName);
    dir = opendir(path.c_str());
    if (!dir)
        return;

    PrintDirectory(aBaseName, aDirName, aLevel);

    while ((dp = readdir(dir))) {
        // skip all files and all folders whose name starts with a dot
        if (dp->d_name[0] == '.' || dp->d_type != DT_DIR)
            continue;
        ProcessDirectory(aBaseName, dp->d_name, aLevel + 1);
    }
    closedir(dir);
}

static void PrintDirectory(string aBaseName, string aDirName, int aLevel)
{
    string fullName = MakePath(aBaseName, aDirName);
    string cgtype = GetFileContent(fullName, "cgroup.type");
    string subtreeCtrl = GetFileContent(fullName, "cgroup.subtree_control");

    cout << Indent(aLevel) << aDirName << "  [" << TypeTrim(cgtype) << "]";
    if (!subtreeCtrl.empty())
        cout << " (" << subtreeCtrl << ")";
    cout << endl;
    if (cgtype == "domain" || cgtype == "domain threaded") {
        string fContent = GetFileContent(fullName, "cgroup.procs");
        if (!fContent.empty())
            cout << Indent(aLevel) << "PIDS: {" << fContent << "}" << endl;
    } else if (cgtype == "threaded") {
        string fContent = GetFileContent(fullName, "cgroup.threads");
        if (!fContent.empty())
        cout << Indent(aLevel) << "TIDS: {" << fContent << "}" << endl;
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

static string TypeTrim(string type)
{
    return (type == "domain")
                ? "d"
                : (type == "threaded")
                        ? "t"
                        : (type == "domain threaded")
                            ? "dt"
                            : "di";
}

static string MakePath(string aBase, string aLast)
{
    return aBase + "/" + aLast;
}
