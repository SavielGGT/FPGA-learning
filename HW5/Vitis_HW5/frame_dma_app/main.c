#include "xil_io.h"
#include "xil_types.h"

/* Address map from Vivado */
#define GPIO_BASE       0x40000000U
#define DMA_BASE        0x41E00000U
#define FRAME_RAM_BASE  0x00010000U

/* 320 x 200 pixels x 1 byte */
#define FRAME_BYTES     64000U

/* AXI GPIO registers */
#define GPIO_DATA_CH1   (GPIO_BASE + 0x00U)
#define GPIO_TRI_CH1    (GPIO_BASE + 0x04U)
#define GPIO_DATA_CH2   (GPIO_BASE + 0x08U)
#define GPIO_TRI_CH2    (GPIO_BASE + 0x0CU)

/* AXI DMA S2MM registers */
#define S2MM_DMACR      (DMA_BASE + 0x30U)
#define S2MM_DMASR      (DMA_BASE + 0x34U)
#define S2MM_DA         (DMA_BASE + 0x48U)
#define S2MM_LENGTH     (DMA_BASE + 0x58U)

/* DMA control/status bits */
#define DMA_RS          0x00000001U
#define DMA_RESET       0x00000004U
#define DMA_IDLE        0x00000002U

static void dma_init(void)
{
    /* Reset S2MM channel */
    Xil_Out32(S2MM_DMACR, DMA_RESET);

    while (Xil_In32(S2MM_DMACR) & DMA_RESET) {
        /* wait for reset */
    }

    /* Run S2MM channel */
    Xil_Out32(S2MM_DMACR, DMA_RS);
}

int main(void)
{
    u32 button;

    /*
     * GPIO channel 1 = button input
     * 1 in TRI means input
     */
    Xil_Out32(GPIO_TRI_CH1, 0x00000001U);

    /*
     * GPIO channel 2 = start output
     * 0 in TRI means output
     */
    Xil_Out32(GPIO_TRI_CH2, 0x00000000U);

    /* Receiver initially stopped */
    Xil_Out32(GPIO_DATA_CH2, 0x00000000U);

    dma_init();

    while (1) {

        /* Wait for BTN0 */
        do {
            button = Xil_In32(GPIO_DATA_CH1);
        } while ((button & 0x01U) == 0U);

        /*
         * First arm DMA.
         * Incoming AXI Stream will be written from 0x00010000.
         */
        Xil_Out32(S2MM_DA, FRAME_RAM_BASE);
        Xil_Out32(S2MM_LENGTH, FRAME_BYTES);

        /*
         * Now allow frame_receiver to accept pixels.
         */
        Xil_Out32(GPIO_DATA_CH2, 0x00000001U);

        /* Wait until DMA writes the whole frame */
        while ((Xil_In32(S2MM_DMASR) & DMA_IDLE) == 0U) {
            /* wait */
        }

        /* Stop receiver */
        Xil_Out32(GPIO_DATA_CH2, 0x00000000U);

        /* Wait until button is released */
        do {
            button = Xil_In32(GPIO_DATA_CH1);
        } while ((button & 0x01U) != 0U);
    }

    return 0;
}