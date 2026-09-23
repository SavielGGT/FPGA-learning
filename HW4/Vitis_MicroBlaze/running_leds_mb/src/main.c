#include "xgpio.h"
#include "xtmrctr.h"
#include "xstatus.h"

#define LED_GPIO_BASEADDR    0x40000000U
#define INPUT_GPIO_BASEADDR  0x40010000U
#define TIMER_BASEADDR       0x41C00000U

#define TIMER_NUM 0

#define BTN_FASTER 0x01U
#define BTN_SLOWER 0x02U
#define BTN_RUN    0x04U

static const u32 speed_ticks[] = {
    1000U,
    2000U,
    4000U,
    8000U
};

#define SPEED_COUNT 4

static void set_timer_period(
    XTmrCtr *timer,
    u32 ticks,
    int running
)
{
    XTmrCtr_Stop(timer, TIMER_NUM);
    XTmrCtr_SetResetValue(timer, TIMER_NUM, ticks);

    if (running)
        XTmrCtr_Start(timer, TIMER_NUM);
}

int main(void)
{
    XGpio gpio_led;
    XGpio gpio_inputs;
    XTmrCtr timer;

    u32 buttons;
    u32 previous_buttons = 0;
    u32 pressed;
    u32 switches;

    u32 led_position = 0;

    int speed_index = 2;
    int running = 1;

    if (XGpio_Initialize(
            &gpio_led,
            LED_GPIO_BASEADDR) != XST_SUCCESS)
        return XST_FAILURE;

    if (XGpio_Initialize(
            &gpio_inputs,
            INPUT_GPIO_BASEADDR) != XST_SUCCESS)
        return XST_FAILURE;

    if (XTmrCtr_Initialize(
            &timer,
            TIMER_BASEADDR) != XST_SUCCESS)
        return XST_FAILURE;

    XGpio_SetDataDirection(
        &gpio_led,
        1,
        0x0
    );

    XGpio_SetDataDirection(
        &gpio_inputs,
        1,
        0xF
    );

    XGpio_SetDataDirection(
        &gpio_inputs,
        2,
        0xF
    );

    XGpio_DiscreteWrite(
        &gpio_led,
        1,
        1U << led_position
    );

    XTmrCtr_SetOptions(
        &timer,
        TIMER_NUM,
        XTC_DOWN_COUNT_OPTION
    );

    XTmrCtr_SetResetValue(
        &timer,
        TIMER_NUM,
        speed_ticks[speed_index]
    );

    XTmrCtr_Start(
        &timer,
        TIMER_NUM
    );

    while (1) {

        buttons = XGpio_DiscreteRead(
            &gpio_inputs,
            1
        ) & 0xF;

        switches = XGpio_DiscreteRead(
            &gpio_inputs,
            2
        ) & 0xF;

        pressed = buttons & ~previous_buttons;
        previous_buttons = buttons;

        if (pressed & BTN_FASTER) {
            if (speed_index > 0) {
                speed_index--;

                set_timer_period(
                    &timer,
                    speed_ticks[speed_index],
                    running
                );
            }
        }

        if (pressed & BTN_SLOWER) {
            if (speed_index < SPEED_COUNT - 1) {
                speed_index++;

                set_timer_period(
                    &timer,
                    speed_ticks[speed_index],
                    running
                );
            }
        }

        if (pressed & BTN_RUN) {
            running = !running;

            if (running) {
                XTmrCtr_Start(
                    &timer,
                    TIMER_NUM
                );
            }
            else {
                XTmrCtr_Stop(
                    &timer,
                    TIMER_NUM
                );
            }
        }

        if (running &&
            XTmrCtr_IsExpired(&timer, TIMER_NUM)) {

            XTmrCtr_Start(
                &timer,
                TIMER_NUM
            );

            if (switches & 0x01U) {
                if (led_position == 0)
                    led_position = 3;
                else
                    led_position--;
            }
            else {
                led_position++;

                if (led_position >= 4)
                    led_position = 0;
            }

            XGpio_DiscreteWrite(
                &gpio_led,
                1,
                1U << led_position
            );
        }
    }

    return 0;
}