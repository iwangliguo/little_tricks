#include<stdio.h>
#include<time.h>
main() 
{ 
    struct tm * gtmpointer;
    time_t secs;
    time(&secs);
    gtmpointer=gmtime(&secs);
	printf("\ndate %d-%d-%d;time: %d:%d:%d",gtmpointer->tm_mon,gtmpointer->tm_mday,gtmpointer->tm_year+1900,gtmpointer->tm_hour,gtmpointer->tm_min,gtmpointer->tm_sec);

}

