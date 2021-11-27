#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
//

typedef float  float32;
typedef uint16_t  Uint16;
typedef uint32_t  Uint32;

#define PI  3.141592653589f

typedef struct {
	float32 Vin;   				// Input: Sine Signal
	float32 SampleFreq;   		// Input: Signal Sampling Freq
	float32 Threshold;   		// Input: Voltage level corresponding to zero i/p
	float32 Vrms;   			// Output: RMS Value
	float32 Vavg;   			// Output: Average Value
	float32 Vema;				// Output: Exponential Moving Average Value
	float32 SigFreq;   			// Output: Signal Freq
	float32 Iin;   				// Input Current Signal
	float32 Irms;   			// Output: RMS Value of current
	float32 Prms;   			// Output: RMS Value of input power
	float32 Srms;
	Uint16  ZCD;   				// Output: Zero Cross detected
	float32 sum_Vacc_avg;		// Internal : running sum for vacc_avg calculation over one sine cycle
	float32 sum_Vacc_rms;      	// Internal : running sum for vacc_rms calculation over one sine cycle
	float32 sum_Vacc_ema;		// Internal : running sum fir vacc_ema calculation over one sine cycle
	float32 sum_Iacc_rms;      	// Internal : running sum for Iacc_rms calculation over one sine cycle
	float32 sum_Pacc_rms;      	// Internal : running sum for Pacc_rms calculation over one sine cycle
	float32 sum_Sacc_rms;
	float32 curr_vin_norm; 		// Internal: Normalized value of the input voltage
	float32 curr_iin_norm; 		// Internal: Normalized value of the input current
	Uint16  prev_sign;			// Internal: Flag to detect ZCD
	Uint16  curr_sign;         	// Internal: Flag to detect ZCD
	Uint32  nsamples;			// Internal: No of samples in one cycle of the sine wave
	Uint32  nsamplesMin;		// Internal: Lowerbound for no of samples in one sine wave cycle
	Uint32  nsamplesMax;		// Internal: Upperbound for no of samples in one sine wave cycle
	float32 inv_nsamples;		// Internal: 1/( No of samples in one cycle of the sine wave)
	float32 inv_sqrt_nsamples;	// Internal: sqrt(1/( No of samples in one cycle of the sine wave))
	Uint16  slew_power_update; 	// Internal: used to slew update of the power value
	float32 sum_Pacc_mul;		// Internal: used to sum Pac value over multiple sine cycles (100)
	float32 sum_Sacc_mul;
} SINEANALYZER_DIFF_wPWR_F;

typedef SINEANALYZER_DIFF_wPWR_F *SINEANALYZER_DIFF_wPWR_F_HANDLE;

//*********** Function Declarations *******//
void SINEANALYZER_DIFF_wPWR_F_init(SINEANALYZER_DIFF_wPWR_F *v);
void SINEANALYZER_DIFF_wPWR_F_FUNC(SINEANALYZER_DIFF_wPWR_F *v);
void Delay(int n)
{
    for(int i=0;i<n;i++);
}


SINEANALYZER_DIFF_wPWR_F Vtest ;

int main()
{
    SINEANALYZER_DIFF_wPWR_F_init(&Vtest);
    for(;;)
    {
       for(int j=0;j<20;j++)
       {
           Vtest.Vin = sin(2*PI*j/20);
           Vtest.Iin = sin(2*PI*j/20 - PI/3);
           SINEANALYZER_DIFF_wPWR_F_FUNC(&Vtest);
       }

    }


    return 0;
}



//*********** Structure Init Function ****//
void SINEANALYZER_DIFF_wPWR_F_init(SINEANALYZER_DIFF_wPWR_F *v)
{
    v->Vin=0;
    v->SampleFreq=0;
    v->Threshold=0;
    v->Vrms=0;
    v->Vavg=0;
    v->Vema=0;
    v->SigFreq=0;
    v->Iin=0;
    v->Irms=0;
    v->Prms=0;
    v->Srms=0;
    v->ZCD=0;
    v->sum_Vacc_avg=0;
    v->sum_Vacc_rms=0;
    v->sum_Vacc_ema=0;
    v->sum_Iacc_rms=0;
    v->sum_Pacc_rms=0;
    v->sum_Sacc_rms=0;
    v->curr_vin_norm=0;
    v->curr_iin_norm=0;
    v->prev_sign=1;
    v->curr_sign=1;
    v->nsamples=0;
    v->nsamplesMin = 0;
    v->nsamplesMax = 0;
    v->inv_nsamples=0;
    v->inv_sqrt_nsamples=0;
    v->slew_power_update=0;
    v->sum_Pacc_mul=0;
    v->sum_Sacc_mul=0;
}

//*********** Function Definition ********//
void SINEANALYZER_DIFF_wPWR_F_FUNC(SINEANALYZER_DIFF_wPWR_F *v)
{
    if ( v->Vin > v->Threshold)
    {
        v->curr_vin_norm = v->Vin;
        v->curr_iin_norm = v->Iin;
        v->curr_sign = 1;
    }
    else
    {
        v->curr_vin_norm = fabs(v->Vin);
        v->curr_iin_norm = fabs(v->Iin);
        v->curr_sign = 0;
    }
    if((v->prev_sign != v->curr_sign) && (v->curr_sign == 1))
    {
        v->ZCD=1;
        v->inv_nsamples = (1.0)/(v->nsamples);
        v->inv_sqrt_nsamples = (1.0)/sqrt(v->nsamples);
        if(v->nsamplesMin < v->nsamples && v->nsamples< v->nsamplesMax)
        {
            v->Vavg = (v->sum_Vacc_avg*v->inv_nsamples);
            v->Vrms = (sqrt(v->sum_Vacc_rms)*v->inv_sqrt_nsamples);
            v->Vema = v->sum_Vacc_ema;
            v->Irms = (sqrt(v->sum_Iacc_rms)*v->inv_sqrt_nsamples);
            v->slew_power_update++ ;
            if(v->slew_power_update >= 101)
            {
                v->slew_power_update=0;
                v->Prms = (v->sum_Pacc_mul*(0.01));
                v->Srms = (v->sum_Sacc_mul*(0.01));
                v->sum_Pacc_mul = 0;
                v->sum_Sacc_mul = 0;
                printf("P%f:\n ",Vtest.Prms);
                printf("hello\n");
            }
            else
            {
                v->sum_Pacc_mul = v->sum_Pacc_mul + (v->sum_Pacc_rms*v->inv_nsamples);
                v->sum_Sacc_mul = v->sum_Sacc_mul + (v->sum_Sacc_rms*v->inv_nsamples);
            }
        }
        else
        {
            v->Vavg = 0;
            v->Vrms = 0;
            v->Vema = 0;
            v->Irms = 0;
            v->Prms = 0;
            v->Srms = 0;
        }
        v->SigFreq = (v->SampleFreq*v->inv_nsamples);
        v->prev_sign = v->curr_sign;
        v->sum_Vacc_avg = 0;
        v->sum_Vacc_rms = 0;
        v->sum_Vacc_ema = 0;
        v->sum_Iacc_rms = 0;
        v->sum_Pacc_rms = 0;
        v->sum_Sacc_rms = 0;
        v->nsamples=0;
    }
    else
    {
        v->nsamples++;
        v->sum_Vacc_avg = v->sum_Vacc_avg+v->curr_vin_norm;
        v->sum_Vacc_rms = v->sum_Vacc_rms+(v->curr_vin_norm*v->curr_vin_norm);
        v->sum_Vacc_ema = v->sum_Vacc_ema+(0.01*(v->curr_vin_norm - v->sum_Vacc_ema));
        v->sum_Iacc_rms = v->sum_Iacc_rms+(v->curr_iin_norm*v->curr_iin_norm);
        v->sum_Pacc_rms = v->sum_Pacc_rms+(v->curr_iin_norm*v->curr_vin_norm);
        v->sum_Sacc_rms = v->sum_Sacc_rms+sqrt(v->curr_iin_norm*v->curr_iin_norm*v->curr_vin_norm*v->curr_vin_norm);
        v->ZCD=0;
        v->prev_sign = v->curr_sign;
    }
}





