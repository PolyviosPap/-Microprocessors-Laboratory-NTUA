#include <avr/io.h>
#include <stdio.h>

void TransmitUSART(char data)
{
	while(!(UCSRA & (1<<UDRE)))
		;
	UDR = data;
}

unsigned char ReceiveUSART()
{
	while(!(UCSRA & (1<<RXC)))
		;
	return UDR;
}

void InitUSART()
{
	UCSRA = 0x00;
	UCSRB = 0x18;
	UCSRC = 0x86;
	UBRRH = 0x00;
	UBRRL = 51;
}

int main(void)
{
	/*Init PORTs for I/O.*/
	DDRC = 0xFF;
	/*Init USART for driver use.*/
	InitUSART();
    while (1) 
    {
		unsigned char temp = ReceiveUSART();
		if (temp >= '0' && temp <= '8')
		{
			TransmitUSART('R');
			TransmitUSART('e');
			TransmitUSART('a');
			TransmitUSART('d');
			TransmitUSART(temp);
			TransmitUSART('\n');
			temp = temp - 0x30;
			if (temp == 0) PORTC =  0x00;
			else PORTC = (1<<(temp-1));
		}
		else
		{
			TransmitUSART('I');
			TransmitUSART('n');
			TransmitUSART('v');
			TransmitUSART('a');
			TransmitUSART('l');
			TransmitUSART('i');
			TransmitUSART('d');
			TransmitUSART('N');
			TransmitUSART('u');
			TransmitUSART('m');
			TransmitUSART('b');
			TransmitUSART('e');
			TransmitUSART('r');
			TransmitUSART('\n');			
			
		}
    }
}

