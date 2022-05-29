#include <iostream>
#include <iomanip>
#include <sstream>
#include <vector>
#include <thread>
#include <chrono>
#include <cstdlib>
#include <sys/types.h>
#include <unistd.h>


using namespace std;

void burner()
{
    ostringstream os;
    os << "PID: " << getpid() << " TID: " << gettid() << endl;
    //os << "burner " << gettid() << endl;
    cout << os.str();

    for (;;);
}

int main(int argc, char *argv[])
{
    cout << "main starting\n";

    if (argc != 2) {
        cout << "Usage: " << argv[0] << " NUM_THREADS\n";
        exit(EXIT_FAILURE);
    }

    int nthreads = atoi(argv[1]);
    std::vector<std::thread> threads;

    for (int i = 0; i < nthreads; ++i) {
        threads.push_back(thread(burner));
    }

    for (auto &t : threads) {
        t.join();
    }

    cout << "main exiting\n";
    return EXIT_SUCCESS;
}
