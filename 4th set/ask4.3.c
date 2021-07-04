#include <avr/io.h>
#include <avr/interrupt.h>



unsigned char input,flag1,flag2,flag3,output;

ISR(INT0_vect)
{
	/*Delay for another 0.5 seconds.*/
	TCNT1H = 0xF0;
	TCNT1L = 0xBE;
	if (flag3 == 0) output = 0x80;
	else output = 0xFF;
	PORTA = output;
	flag1 = 0x00;
	flag2 = 0x00;
	flag3 = 0x01;
}


ISR(TIMER1_OVF_vect)
{
	/*If 3 seconds have passed.*/
	if (flag1 == 1)
	{
		output = 0x00;
		flag3 = 0x00;
		PORTA = output;
	}
	/*If only 0.5 seconds have passed.*/
	if (flag2 == 0)
	{
		/*Set another delay for 2.5 seconds.*/
		TCNT1H = 0xB3;
		TCNT1L = 0xB5;
		output = 0x80;
		PORTA = output;
		flag1 = 0x01;
		flag2 = 0x01;
	}
}



int main(void)
{
	/*Setting I/O for PORTS.*/
    DDRB = 0x00;					//input PORT B.
    DDRA = 0xFF;					//output PORT B.
	/*Setting INT0 interrupts.*/
	GICR = ( 1 << INT0);
	MCUCR = (1<<ISC01) | (1<<ISC00) ;;
	/*Setting timer1 interrupts.*/
	TIMSK = (1 << TOIE1) ;
	//TCCR1A = 0x00;
	TCCR1B = (1<<CS10) | (1<<CS12);;
	/*Enable global interrupts.*/
	sei();
	flag1 = 0x00;	//flag1 shows if 3 seconds have passed or not.
	flag2 = 0x00;	//flag2 shows if 2.5 seconds have passed or not.
	flag3 = 0x00;	//flag3 shows if led PA7 is on or not.
	while(1)
	{
		input = PINB;
		if (input%2 == 1){
			/*We apply this while so we dont take more than two inputs from PB0.*/
			while(input%2 == 1){input = PINB;}
			/*Set delay for 0.5 seconds.*/
			TCNT1H = 0xF0;
			TCNT1L = 0xBE;
			
			if (flag3 == 0) output = 0x80;
			else output = 0xFF;
			PORTA = output;
			/*Re-init flags.*/
			flag1 = 0x00;
			flag2 = 0x00;
			flag3 = 0x01;

		}
	}
}

