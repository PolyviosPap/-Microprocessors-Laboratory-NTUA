#include <avr/io.h>
#define 	F_CPU   8000000UL 
#include <util/delay.h>
#define cbi(reg,bit) (reg &= ~(1 << bit))
#define sbi(reg,bit) (reg |= (1 << bit))

unsigned char one_wire_receive_bit(){
	unsigned char bit,temp;
	sbi(DDRA,PA4);
	cbi(PORTA,PA4);
	_delay_us(2);
	cbi(DDRA,PA4);
	cbi(PORTA,PA4);
	_delay_us(10);
	temp = (PINA & 0x10);
	bit = 0x00;
	if (temp == 0x10) bit = 0x01;
	_delay_us(49);
	return bit;
}

unsigned char one_wire_receive_byte(){
	unsigned char bit;
	unsigned char byte = 0x00;
	unsigned char i = 0x08;
	while(i != 0){
		bit = one_wire_receive_bit();
		byte = (byte >> 1);
		if (bit == 0x01) bit = 0x80;
		byte = (byte | bit);
		i--;
	}
	return byte;
}

void one_wire_transmit_bit(unsigned char bit){
	sbi(DDRA,PA4);
	cbi(PORTA,PA4);
	_delay_us(2);
	if (bit == 0x01) sbi(PORTA,PA4);
	if (bit == 0x00) cbi(PORTA,PA4);
	_delay_us(58);
	cbi(DDRA,PA4);
	cbi(PORTA,PA4);
	_delay_us(1);
	return;
}

void one_wire_transmit_byte(unsigned char byte){
	unsigned char bit;
	unsigned char i = 0x08;
	while(i != 0){
		bit = (byte & 0x01);
		one_wire_transmit_bit(bit);
		byte = (byte >> 1);
		i--;
	}
	return;
}

unsigned char one_wire_reset(){ 
	sbi(DDRA,PA4);
	cbi(PORTA,PA4);
	_delay_us(480);
	cbi(DDRA,PA4);
	cbi(PORTA,PA4);
	_delay_us(100);
	unsigned char temp = PINA;
	_delay_us(380);
	temp = (temp & 0x10);
	unsigned char res = 0x00;
	if (temp == 0x00) res = 0x01;
	return res;
}

int main(void)
{
    /*Setting I/O for PORTs.*/
	DDRA = 0xFF;
	DDRB = 0xFF;
	DDRD = 0xFF;
    
	unsigned char sign_byte,temperature_byte;
	while (1) 
    {
		/*Check if device is connected.*/
		if (!one_wire_reset()) {
			PORTB = 0x80;
			continue;
		}
		one_wire_transmit_byte(0xCC); //Send command 0xCC.
		one_wire_transmit_byte(0x44); //Send command 0x44.
		while(one_wire_receive_bit() != 0x01);
		/*Recheck if device is connected.*/
		if (!one_wire_reset()) {
			PORTB = 0x80;
			continue;
		}
		one_wire_transmit_byte(0xCC); //Send command 0xCC.
		one_wire_transmit_byte(0xBE); //Send command 0xBE.
		temperature_byte = one_wire_receive_byte(); //Receive the first byte which is the temp. 
		sign_byte = one_wire_receive_byte(); //Receive the second byte which is the sign of the temp.
		/*Check if temp is negative or positive.*/
		if (sign_byte == 0xFF) PORTB = ~(temperature_byte) + 1;
		else PORTB = temperature_byte;
    }
}