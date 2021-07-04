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

void adc_init()
{
 
    ADMUX = (1<<REFS0);
 
    ADCSRA = (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);
}

uint16_t adc_read()
{
 
  ADCSRA |= (1<<ADSC);
 
 
  while(ADCSRA & (1<<ADSC));
 
  return (ADC);
}

int main(void)
{
	/*Initialiazations*/
	InitUSART();
	adc_init();
	uint16_t temp;
	unsigned char digit1;
	unsigned char digit2;
    while (1) 
    {
		temp = adc_read();
		temp = (temp * 50);
		temp = (temp >> 10);
		digit1 = (unsigned char)(temp / 10);
		digit2 = (unsigned char)(temp % 10);
		digit1 = digit1 + 48;
		digit2 = digit2 + 48;
		TransmitUSART(digit1);
		TransmitUSART(',');
		TransmitUSART(digit2);
		TransmitUSART('\n');
    }
}

