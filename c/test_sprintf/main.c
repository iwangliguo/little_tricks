#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main()
{
    int num_int = 123;
    char  str_int[5] = {};
    sprintf(str_int,"%-05d%\n",num_int);

    printf(str_int);
    printf("Hello world!\n");

    float num_float = 3.11;
    char str_float[5] = {};

    sprintf(str_float,"%5.2f\n",num_float);
    printf(str_float);

    sprintf(str_float,"%.4f\n",num_float);
    printf(str_float);

    sprintf(str_float,"%5f\n",num_float);
    printf(str_float);


    sprintf(str_float,"%f\n",num_float);
    printf(str_float);
   // printf('\n');
    printf("%c %f",'\n',num_float);

    return 0;
}
