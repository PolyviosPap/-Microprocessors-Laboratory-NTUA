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
	uint32_t led_value = 0;
	uint32_t buttons_value = 0;
	uint32_t switches_value = 0;
	uint32_t delay = 0;
	uint32_t A,B,C,D,NA,ND,F0,F1,F2;

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


		/* Wait a small amount of time so the LED is visible */
		for (delay = 0; delay < LED_DELAY; delay++);

		switches_value = XGpio_DiscreteRead(&switches_inst, 1);
		xil_printf("switches value: %d\r\n", switches_value);

		A = (switches_value & 1);
		B = (switches_value & 2);
		C = (switches_value & 4);
		D = (switches_value & 8);
		ND = (!D);
		NA = (!A);

		F0 = !((A & B) | (B & C) | (C & D) | (D & A));
		F1 = ((A & B & C & D) | (NA & ND));
		F2 = (F1 | F0);

		led_value = F2;
		led_value = (led_value << 1);
		led_value = (led_value | F1);
		led_value = (led_value << 1);
		led_value = (led_value | F0);

		/* Set the LED value */
		XGpio_DiscreteWrite(&leds_inst, 1, led_value = led_value);
	}

	cleanup_platform();
	return 0;
}
