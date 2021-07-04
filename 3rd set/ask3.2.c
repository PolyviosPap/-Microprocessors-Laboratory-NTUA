#include <avr/io.h>
#include <stdio.h>

int main(void) {
	
	int A, B, C, D, E, DN, EN, DATA, F0, F1, F2, OUT;		
	
	DDRC = 0x00;											
	DDRA = 0xFF;											
	
	while(1){
		DATA = PINC;
		
		A = DATA & 0x01;						
		
		DATA = DATA >> 1;
		B = DATA & 0x01;
		
		DATA = DATA >> 1;
		C = DATA & 0x01;
		
		DATA = DATA >> 1;
		D = DATA & 0x01;
		
		DN = ~D;
		DN = DN & 0x01;
		
		DATA = DATA >> 1;
		E = DATA & 0x01;
		
		EN = ~E;
		EN = EN & 0x01;
		
		F0 = ~((A&B)|(B&C)|(C&D)|(D&E));
		F0 = F0 & 0x01;
		F1 = (A&B&C&D)|(DN&EN);
		F2 = F0|F1;
		
		OUT = F2;
		OUT = OUT << 1;
		OUT = OUT|F1;
		OUT = OUT << 1;
		OUT = OUT|F0;
		
		PORTA = OUT;
	}
}