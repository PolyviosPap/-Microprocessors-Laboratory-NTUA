#include <avr/io.h>
#define F_CPU 8000000UL
#include <util/delay.h>
//#include <avr/interrupt.h>

unsigned char x,y;

unsigned char scan_row(unsigned char i){
	unsigned char temp = 0x08;
	temp = temp << i;
	PORTC =  temp;
	_delay_ms(1);
	temp = PINC;
	temp = (temp & 0x0F);
	return (temp);
}


void scan_keybord(){
		int j;
		int temp;
		x = 0;
		y = 0;
	for (j = 1; j < 5; j++){
		temp = scan_row(j);
		switch(temp)
		{
			case 0x00: temp = 0; break;
			case 0x01: temp = 1; break;
			case 0x02: temp = 2; break;
			case 0x04: temp = 3; break;
			case 0x08: temp = 4; break;
		}
		if (temp!=0){
			x = j;
			y = temp;
		}
	}
	return;
}

int main(void)
{
	/*Setting I/O for PORTs.*/
	DDRA = 0xFF;
	DDRB = 0xFF;
	DDRD = 0xFF;
	/*Setting PORTC for keypad.*/
	DDRC = 0xF0;
    while (1) 
    {
		unsigned char first_key = 0;
		unsigned char second_key = 0;
		x = 0;
		y = 0;
		while((x==0) && (y==0)){scan_keybord();}
		if ((x==1) & (y==1)) first_key = 1;
		while((x!=0) && (y!=0)){scan_keybord();}
		while((x==0) && (y==0)){scan_keybord();}
		if ((x==1) & (y==3)) second_key = 1;
		/*Check if input is valid.*/
		if ((first_key == 1) && (second_key == 1)){
			PORTA = 0xFF;
			_delay_ms(4000);
			PORTA = 0x00;
		}
		else{
			for (int i = 0; i < 8; i++){
				PORTA = 0xFF;
				_delay_ms(250);
				PORTA = 0x00;
				_delay_ms(250);
			}
		}
    }
}