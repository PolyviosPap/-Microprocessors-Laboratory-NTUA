#include <avr/io.h>
#include <stdio.h>

int z, check, out;


int main(void) {
	DDRD = 0x00;					//input PORT D.
	DDRB = 0xFF;					//output PORT B.
	
	out = 0x01;						//anavoume to 1o led.
	PORTB = out;
	
	while (1){
	
	
	z = PIND;						//diavase eisodo.
	int max = 0;					//arxika max = 0, den exei patithei kati.
	
	while(z!=0) {					//oso exoume eisodo,
		z = PIND;
		if (z>=max) max = z;		//max = z, an z >= max.
	}
		
	if(max >= 0x08) {				//an exei patithei o 4os diakoptis,
		out = 0x01;					//theloume na anapsoume to 1o led.
		goto PRINT;					//pigaine gia ektipwsi.
	}
	
	if(max >= 0x04) {				//idia logiki.
		out = 0x80;
		goto PRINT;
	}
	
	if(max >= 0x02) {
		if (out == 0x01) {			//an to led eftase sto deksia akro,
			out = 0x80;				//metefere to terma aristera.
			} else {				//alliws mia deksia olisthisi.
			out = out>>1;
		}
		goto PRINT;
	}
	
	if(max >= 0x01) {
		if(out == 0x80) {
			out = 0x01;
			} else {
			out = out<<1;
		}
		goto PRINT;
	}
	
	PRINT: PORTB = out;				//ektipwsi.
	}
}