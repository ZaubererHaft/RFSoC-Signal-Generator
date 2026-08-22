/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */
 
#include <xil_types.h>
#include "xrfdc.h"
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h" 
#include "xiicps.h" 
#include "xrfdc_clk.c"

struct metal_device *deviceptr = NULL;

#ifndef XPS_BOARD_ZCU111
#define XPS_BOARD_ZCU111
#endif

#define TILE  1
#define BLOCK 3
#define SINGLE_CHANNEL 1
#define GPIO_ALL_OUTPUTS 0x00000000

#ifdef __BAREMETAL__
metal_phys_addr_t metal_phys;
static struct metal_device CustomDev = {
	/* RFdc device */
	.bus = NULL,
	.num_regions = 1,
	.regions = {
		{
			.physmap = &metal_phys,
			.size = 0x40000,
			.page_shift = (unsigned)(-1),
			.page_mask = (unsigned)(-1),
			.mem_flags = 0x0,
			.ops = {NULL},
		}
	},
	.node = {NULL},
	.irq_num = 0,
	.irq_info = NULL,
};
#endif

unsigned int LMK04208_CKin[1][26] = {
		{0x00160040,0x80140320,0x80140321,0x80140322,
		0xC0140023,0x40140024,0x80141E05,0x03300006,0x01300007,0x06010008,
		0x55555549,0x9102410A,0x0401100B,0xfB0C006C,0x2302886D,0x0200000E,
		0x8000800F,0xC1550410,0x00000058,0x02C9C419,0x8FA8001A,0x10001E1B,
		0x0021201C,0x0180033D,0x0200033E,0x003F001F }};


void UpdateNcoFreq(XRFdc *RFdcInst, double freq, uint32_t component, uint32_t tile, uint32_t block)
{
	XRFdc_Mixer_Settings mixer_settings;

	int Status = XRFdc_GetMixerSettings(RFdcInst, component, tile, block, &mixer_settings);

	if(Status == XST_SUCCESS) {
		mixer_settings.Freq = freq;
		mixer_settings.FineMixerScale = XRFDC_MIXER_SCALE_AUTO;
		//mixer_settings.EventSource = XRFDC_EVNT_SRC_IMMEDIATE;

		Status |= XRFdc_SetMixerSettings(RFdcInst, component, tile, block, &mixer_settings);

		Status |= XRFdc_UpdateEvent(RFdcInst, component, tile, block, XRFDC_EVENT_MIXER);
	}
	
}

int main()
{
    init_platform();

	xil_printf("Configuring the Clock...\r\n");
	LMK04208ClockConfig(XPAR_XIICPS_1_BASEADDR, LMK04208_CKin);	
	LMX2594ClockConfig(XPAR_XIICPS_1_BASEADDR, 245760);


	u32 RFdcDeviceId = XPAR_USP_RF_DATA_CONVERTER_0_BASEADDR;
    XRFdc RFdcInst; 
	XRFdc_Config *ConfigPtr;
	XRFdc *RFdcInstPtr = &RFdcInst;
	u32 Status;
		
	struct metal_init_params init_param = METAL_INIT_DEFAULTS;

	xil_printf("Initialize metal...\r\n");
	if (metal_init(&init_param)) {
		xil_printf("ERROR: Failed to run metal initialization\r\n");
		return XST_FAILURE;
	}
	
    xil_printf("Initialize the RFdc driver...\r\n");
	ConfigPtr = XRFdc_LookupConfig(RFdcDeviceId);
	if (ConfigPtr == NULL) {
        xil_printf("ERROR: Failed init RFdc\r\n");
		return XST_FAILURE;
	}

    metal_phys = ConfigPtr->BaseAddr;
    CustomDev.name = ConfigPtr->Name;
    CustomDev.regions->virt = (void *)ConfigPtr->BaseAddr;
    deviceptr = &CustomDev;

    xil_printf("Register metal...\r\n");
    Status = XRFdc_RegisterMetal(RFdcInstPtr, RFdcDeviceId, &deviceptr);
	if (Status != XST_SUCCESS) {
        xil_printf("ERROR: Failed register metal\r\n");
		return XST_FAILURE;
	}

    xil_printf("Initialize RFdc controller...\r\n");
	Status = XRFdc_CfgInitialize(RFdcInstPtr, ConfigPtr);
	if (Status != XST_SUCCESS) {
        xil_printf("ERROR: Failed init RFdc\r\n");
		return XST_FAILURE;
	}


    if (Status == XST_SUCCESS && XRFdc_IsDACBlockEnabled(RFdcInstPtr, TILE, BLOCK)) 
	{
        xil_printf("Start Up...\r\n");
        Status = XRFdc_StartUp(&RFdcInst, XRFDC_DAC_TILE, TILE); 
                				
		XRFdc_IPStatus IPStatus;
		XRFdc_GetIPStatus(&RFdcInst, &IPStatus);

		XRFdc_TileStatus tile_stat =  IPStatus.DACTileStatus[TILE];
		printf("Tile Status: Enabled=%u, TileState=%u, StatusMask=%u, PowerUp=%u, PLL=%u\r\n", tile_stat.IsEnabled, 
			tile_stat.TileState, tile_stat.BlockStatusMask, tile_stat.PowerUpState, tile_stat.PLLState);
				
		if (tile_stat.PLLState != 1) {
            printf("FEHLER: DAC PLL nicht gelockt!\r\n");
	        return XST_FAILURE;
		}
    }
    else {
        xil_printf("ERROR: DAC not enabled!\r\n");
		return XST_FAILURE;
    }
    
    print("Successfully ran Hello World application\r\n!");
    cleanup_platform();
    
    return XST_SUCCESS;
}