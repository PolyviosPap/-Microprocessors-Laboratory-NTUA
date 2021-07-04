#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"

#define LEDS_DEV XPAR_LEDS_DEVICE_ID
#define BUTTONS_DEV XPAR_BUTTONS_DEVICE_ID
#define SWITCHES_DEV XPAR_SWITCHES_DEVICE_ID
#define LED_DELAY 10000000*5

XGpio leds_inst; 							// leds gpio driver instance
XGpio buttons_inst; 						// buttons gpio driver instance
XGpio switches_inst; 						// switches gpio driver instance

int main()
{
	int statusCodes = 0;
	uint32_t led_value = 1;
	uint32_t buttons_value = 0;
	uint32_t switches_value = 0;
	uint32_t delay = 0;
	uint32_t old_value , value;
	init_platform();

	/* Initialize the GPIO driver for the leds */
	statusCodes = XGpio_Initialize(&leds_inst, LEDS_DEV);
	if (statusCodes != XST_SUCCESS) {
		xil_printf("ERROR: failed to init LEDS. Aborting\r\n");
		return XST_FAILURE;
	}

	/* Initialize the GPIO driver for the buttons */
	statusCodes = XGpio_Initialize(&buttons_inst, BUTTONS_DEV);
	if (statusCodes != XST_SUCCESS) {
		xil_printf("ERROR: failed to init BUTTONS. Aborting\r\n");
		return XST_FAILURE;
	}

	/* Initialize the GPIO driver for the switches */
	statusCodes = XGpio_Initialize(&switches_inst, SWITCHES_DEV);
	if (statusCodes != XST_SUCCESS) {
		xil_printf("ERROR: failed to init SWITCHES. Aborting\r\n");
		return XST_FAILURE;
	}

	/* Set the direction for all led signals as outputs */
	XGpio_SetDataDirection(&leds_inst, 1, 0);

	/* Set the direction for all buttons signals as inputs */
	XGpio_SetDataDirection(&buttons_inst, 1, 1);

	/* Set the direction for all switches signals as inputs */
	XGpio_SetDataDirection(&switches_inst, 1, 1);

	while(1) {
		xil_printf("led_value: %d\r\n", led_value);
		/* Set the LED value */
		XGpio_DiscreteWrite(&leds_inst, 1, led_value = led_value);

		value = XGpio_DiscreteRead(&buttons_inst, 1);

		//while (XGpio_DiscreteRead(&buttons_inst, 1) != 0){};
		//xil_printf("buttons value: %d\r\n", buttons_value);

		if (old_value > value) buttons_value = old_value - value;
		else buttons_value = 0;
		if (buttons_value == 1){
			led_value = (led_value << 1);
			if (led_value == 16) led_value = 1;
		}
		if (buttons_value == 2){
			led_value = (led_value >> 1);
			if (led_value == 0) led_value = 8;
		}
		if (buttons_value == 4) led_value =  8;
		if (buttons_value == 8) led_value =  1;

		old_value = value;

	}

	cleanup_platform();
	return 0;
}
