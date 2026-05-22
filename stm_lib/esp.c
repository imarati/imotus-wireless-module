/*
 * esp.c
 *
 *  Created on: Apr 9, 2026
 *      Author: grey2
 */


#include "debugger.h"


void esp_start()
{

}


bool connected_flag = false;
uart_rx_context_t rx_ctx;
desk_state_t st;
forms_rx_t rx_forms;
forms_tx_t tx_forms;

void send_form2_status()
{
    fill_form2_status();

    send_packet(FORM2_ID, (uint8_t*)(&tx_forms.f2), FORM2_LEN);
}

void send_form3_initial()
{
    fill_form3_initial();

    send_packet(FORM3_ID, (uint8_t*)&tx_forms.f3, FORM3_LEN);
}

void send_form10_passive_status(bool trn)
{
    fill_form10_passive_status(trn);
    send_packet(FORM10_ID, (uint8_t*)&tx_forms.f10, FORM10_LEN);
}

void send_form11_manual()
{
    fill_form11_manual();
    send_packet(FORM11_ID, (uint8_t*)&tx_forms.f11, FORM11_LEN);
}

void send_form12_passive()
{
    fill_form12_passive();
    send_packet(FORM12_ID, (uint8_t*)&tx_forms.f12, FORM12_LEN);
}

void send_form17_active()
{
    fill_form17_active();
    send_packet(FORM17_ID, (uint8_t*)&tx_forms.f17,FORM17_LEN);
}

void send_form20_system()
{
    fill_form20_system();
    send_packet(FORM20_ID, (uint8_t*)&tx_forms.f20, FORM20_LEN);
}

static uint8_t calc_crc(uint8_t formId, uint8_t len, const volatile uint8_t* payload)
{
    uint8_t crc = 0;
    crc ^= formId;
    crc ^= len;

    for (uint8_t i = 0; i < len; i++) {
        crc ^= payload[i];
    }
    return crc;
}

// RX HANDLERS
static bool handle_form1(const uint8_t* payload, uint8_t len)
{
    if (len != FORM1_LEN) {
        return false;
    }

    memcpy(&rx_forms.f1, payload, sizeof(rx_forms.f1));

    /*	УСТАНОВИТЬ ВРЕМЯ НА СТМ*/
    //rtc_set_unix_time_u32(rx_forms.f1.timestamp);
    /*					*/
    return true;
}

static bool handle_form4(const uint8_t* payload, uint8_t len)
{
    if (len != FORM4_LEN) {
        return false;
    }

    memcpy(&rx_forms.f4, payload, sizeof(rx_forms.f4));

    pMan_data[pMan_nTargetAngle] = rx_forms.f4.target_angle;
    pMan_data[pMan_bMoveToTarget] = 1;
    //st.mode = AUTO;

    return true;
}

static bool handle_form5(const uint8_t* payload, uint8_t len)
{
    if (len != FORM5_LEN) {
        return false;
    }

    memcpy(&rx_forms.f5, payload, sizeof(rx_forms.f5));
    display_data.screen_num = pMan;
    switch (rx_forms.f5.cmd) {
        case FORM5_CMD_IDLE:
            //st.mode = IDLE; //stop
        	pMan_data[pMan_bStop] = 1;
        	pMan_data[pMan_bBending] = 0;
        	pMan_data[pMan_bExpansion] = 0;
            return true;

        case FORM5_CMD_LEFT:
            //st.mode = MANUAL_LEFT;
        	pMan_data[pMan_bStop] = 0;
        	pMan_data[pMan_bBending] = 1;
        	pMan_data[pMan_bExpansion] = 0;
            return true;

        case FORM5_CMD_RIGHT:
            //st.mode = MANUAL_RIGHT;
        	pMan_data[pMan_bStop] = 0;
        	pMan_data[pMan_bBending] = 0;
        	pMan_data[pMan_bExpansion] = 1;
            return true;

        default:
            return false;
    }
}

static bool handle_form6(const uint8_t* payload, uint8_t len)
{
    if (len != FORM6_LEN) {
        return false;
    }

    memcpy(&rx_forms.f6, payload, sizeof(rx_forms.f6));

    pSetEfforts_data[pSetEfforts_nEffortMaxSP] = rx_forms.f6.max_load;
    pManFunc_data[pManFunc_nVelocity] = rx_forms.f6.manual_speed;
   // st.max_weight   = ;
   // st.manual_speed = (rx_forms.f6.speed > 100u) ? 100u : rx_forms.f6.speed;

    return true;
}

static bool handle_form7(const uint8_t* payload, uint8_t len)
{
    if (len != FORM7_LEN) {
        return false;
    }

    send_form3_initial();
    connected_flag = true;
    return true;
}

static bool handle_form8(const uint8_t* payload, uint8_t len)
{
    if (len != FORM8_LEN) {
        return false;
    }

    memcpy(&rx_forms.f8, payload, sizeof(rx_forms.f8));

//    st.passive_cycles_target  = rx_forms.f8.cycles;
//    st.passive_duration_min   = rx_forms.f8.duration_min;
//    st.passive_stop_by_cycles = (rx_forms.f8.stop_by_cycles != 0);
//    st.passive_stop_by_time   = (rx_forms.f8.stop_by_time   != 0);

    pSetCycleTime_data[pSetCycleTime_cStopByCycle] = rx_forms.f8.stop_by_cycles;
    pSetCycleTime_data[pSetCycleTime_cStopByTime] = rx_forms.f8.stop_by_time;
    pSetCycleTime_data[pSetCycleTime_nCycleSP] = rx_forms.f8.cycles;
    pSetCycleTime_data[pSetCycleTime_nTimeSP] = rx_forms.f8.duration_min;

    pSet_data[pSet_nVelocity] = rx_forms.f8.speed;
    pSetEfforts_data[pSetEfforts_nEffortMaxSP] = rx_forms.f8.max_load;

    pPT_data[pPT_nBendAngleSP] = rx_forms.f8.bend_angle;
    pPT_data[pPT_nExpAngleSP] = rx_forms.f8.exp_angle;

//    st.passive_speed          = rx_forms.f8.speed;
//    st.max_weight             = rx_forms.f8.max_load;
//    st.passive_flexion_angle    = rx_forms.f8.lower_angle;
//    st.passive_extension_angle    = rx_forms.f8.upper_angle;
    return true;
}

static bool handle_form9(const uint8_t* payload, uint8_t len)
{
    if (len != FORM9_LEN) {
        return false;
    }

    memcpy(&rx_forms.f9, payload, sizeof(rx_forms.f9));
    display_data.screen_num = pPT;
    switch (rx_forms.f9.cmd) {
        case FORM9_CMD_START:

        	pPT_data[pPT_bStart] = 1;
        	pPT_data[pPT_bStop] = 0;
        	pPT_data[pPT_bPause] = 0;

/*            st.mode = PASSIVE;
            st.passive_done_cycles    = 0;
            st.passive_elapsed_seconds = 0;*/
            return true;
        case FORM9_CMD_STOP:

        	pPT_data[pPT_bStart] = 0;
        	pPT_data[pPT_bStop] = 1;
        	pPT_data[pPT_bPause] = 0;

/*            st.mode = IDLE;*/
            return true;
        default:
            return false;
    }
}

static bool handle_form13(uint8_t len)
{
    if (len != FORM13_LEN) {
        return false;
    }

    send_form11_manual();
    return true;
}

static bool handle_form14(uint8_t len)
{
    if (len != FORM14_LEN) {
        return false;
    }

    send_form12_passive();
    return true;
}

static bool handle_form15(const uint8_t* payload, uint8_t len)
{
    if (len != FORM15_LEN) {
        return false;
    }

    memcpy(&rx_forms.f15, payload, sizeof(rx_forms.f15));

/*    st.cycles_target     = rx_forms.f15.cycles;
    st.duration_min      = rx_forms.f15.duration_min;
    st.stop_by_cycles    = (rx_forms.f15.stop_by_cycles != 0);
    st.stop_by_time      = (rx_forms.f15.stop_by_time   != 0);
    st.speed             = rx_forms.f15.speed;
    st.max_load               = rx_forms.f15.max_load;

    st.bend_angle        = rx_forms.f15.bend_angle;
    st.exp_angle         = rx_forms.f15.exp_angle;

    st.active_bend_assist_angle = rx_forms.f15.bend_assist_angle;
    st.active_exp_assist_angle  = rx_forms.f15.exp_assist_angle;

    st.active_bend_load         = rx_forms.f15.bend_load;
    st.active_exp_load          = rx_forms.f15.exp_load;*/

    pSetCycleTime_data[pSetCycleTime_cStopByCycle] = rx_forms.f15.stop_by_cycles;
    pSetCycleTime_data[pSetCycleTime_cStopByTime] = rx_forms.f15.stop_by_time;
    pSetCycleTime_data[pSetCycleTime_nCycleSP] = rx_forms.f15.cycles;
    pSetCycleTime_data[pSetCycleTime_nTimeSP] = rx_forms.f15.duration_min;
    pSet_data[pSet_nVelocity] = rx_forms.f15.speed;
    pSetEfforts_data[pSetEfforts_nEffortMaxSP] = rx_forms.f15.max_load;


	//pAT_nPBendAngleSP,

	//pAT_nABendAngleSP,
	//pAT_nAExpAngleSP,
	//pAT_nPExpAngleSP,
	//pAT_nEffortExpSP,
	//pAT_nEffortBendSP,

    pAT_data[pAT_nABendAngleSP]        = rx_forms.f15.bend_angle;  //актиная стадия
    pAT_data[pAT_nAExpAngleSP]         = rx_forms.f15.exp_angle;					 //актиная стадия

    pAT_data[pAT_nPBendAngleSP]  = rx_forms.f15.bend_assist_angle; //пассивная стадия
    pAT_data[pAT_nPExpAngleSP]   = rx_forms.f15.exp_assist_angle; //пассивная стадия

    pAT_data[pAT_nEffortBendSP]         = rx_forms.f15.bend_load;
    pAT_data[pAT_nEffortExpSP]          = rx_forms.f15.exp_load;

    send_form17_active();
    return true;
}

static bool handle_form16(const uint8_t* payload, uint8_t len)
{
    if (len != FORM16_LEN) {
        return false;
    }

    memcpy(&rx_forms.f16, payload, sizeof(rx_forms.f16));
    display_data.screen_num = pAT;
    switch (rx_forms.f16.cmd) {
        case 0: // STOP
/*            st.mode = IDLE;
            st.paused = false;*/
        	pAT_data[pAT_bStart] = 0;
        	pAT_data[pAT_bStop] = 1;
        	pAT_data[pAT_bPause] = 0;
            return true;

        case 1: // START
            st.mode = ACTIVE;
/*            if (!st.paused) {
                st.done_cycles = 0;
                st.elapsed_seconds = 0;
            }
            st.paused = false;*/
        	pAT_data[pAT_bStart] = 1;
        	pAT_data[pAT_bStop] = 0;
        	pAT_data[pAT_bPause] = 0;
            return true;

        case 2: // PAUSE
/*            st.paused = true;*/

        	pAT_data[pAT_bStart] = 0;
        	pAT_data[pAT_bStop] = 0;
        	pAT_data[pAT_bPause] = 1;

            return true;

        default:
            return false;
    }
}

static bool handle_form18(uint8_t len)
{
    if (len != FORM18_LEN) {
        return false;
    }
    send_form17_active();
    return true;
}

static bool handle_form19(uint8_t len)
{
    if (len != FORM19_LEN) {
        return false;
    }
    send_form20_system();
    return true;
}

static bool handle_form21(const uint8_t* payload, uint8_t len)
{
    if (len != FORM21_LEN) {
        return false;
    }

    form21_update_system_settings_t f21;
    memcpy(&f21, payload, sizeof(f21));

    st.max_load      = f21.max_load;
    st.speed         = f21.speed;
    st.cycles_target = f21.cycles;
    st.duration_min  = f21.duration_min;

    st.stop_by_cycles = (f21.stop_by_cycles != 0);
    st.stop_by_time   = (f21.stop_by_time   != 0);

    st.bend_angle = f21.bend_angle;
    st.exp_angle  = f21.exp_angle;

    return true;
}

void send_packet(uint8_t formId, const uint8_t* payload, uint8_t len)
{
    uint8_t crc = calc_crc(formId, len, payload);

    string_tx3[0] = 0xaa;
    string_tx3[1] = formId;
    string_tx3[2] = len;

    memcpy(string_tx3+3, payload, len);
    string_tx3[3+len] = crc;

    HAL_UART_Transmit_DMA(&huart3, string_tx3, 3+len+1);

}

// TX HELPERS (нужны для ответов Form2/3 из обработчиков)
void fill_form2_status()
{
    tx_forms.f2.timestamp = 0;//rtc_get_unix_time_u32();
    tx_forms.f2.angle     = (int16_t)current_angle;
    tx_forms.f2.load      = (int16_t)current_effort;
    tx_forms.f2.status    = 0;

    //status word
    //error_code
}

void fill_form3_initial()
{
/*   tx_forms.f3.status   = (st.weight > st.max_weight) ? 1u : 0u;*/

    tx_forms.f3.status   = 0;
}

void fill_form10_passive_status(bool trn)
{
/*    uint32_t total_seconds = pPT_data[pPT_nElepsedTime];
    uint32_t elapsed       = pPT_data[pPT_nCurrentCycle];
    uint16_t remaining     = 0;*/

/*    if (total_seconds > elapsed) {
        remaining = (uint16_t)(total_seconds - elapsed);
    }*/

	if(trn)
		tx_forms.f10.done_cycles       = pAT_data[pAT_nCurrentCycle];
	else
		tx_forms.f10.done_cycles       = pPT_data[pPT_nCurrentCycle];

    tx_forms.f10.remaining_seconds = ms_timer.sec_counter;
    //tx_forms.f10.done_cycles       = pPT_data[pPT_nCurrentCycle];
    tx_forms.f10.status            = 0;
}

void fill_form11_manual()
{
	tx_forms.f11.max_load = pSetEfforts_data[pSetEfforts_nEffortMaxSP];
	tx_forms.f11.manual_speed = pManFunc_data[pManFunc_nVelocity];

/*    tx_forms.f11.max_load     = st.max_weight;
    tx_forms.f11.manual_speed = st.manual_speed;*/
    tx_forms.f11.status       = 0;
}

void fill_form12_passive()
{
	tx_forms.f12.stop_by_cycles  = pSetCycleTime_data[pSetCycleTime_cStopByCycle];
	tx_forms.f12.stop_by_time = pSetCycleTime_data[pSetCycleTime_cStopByTime];
    tx_forms.f12.cycles   =  pSetCycleTime_data[pSetCycleTime_nCycleSP];
    tx_forms.f12.duration_min = pSetCycleTime_data[pSetCycleTime_nTimeSP];

    tx_forms.f12.speed = pSet_data[pSet_nVelocity];
    tx_forms.f12.max_load = pSetEfforts_data[pSetEfforts_nEffortMaxSP];

    tx_forms.f12.bend_angle = pPT_data[pPT_nBendAngleSP];
    tx_forms.f12.exp_angle = pPT_data[pPT_nExpAngleSP];

/*    tx_forms.f12.cycles         	= st.passive_cycles_target;
    tx_forms.f12.duration_min  	 	= st.passive_duration_min;
    tx_forms.f12.stop_by_cycles 	= st.passive_stop_by_cycles ? 1u : 0u;
    tx_forms.f12.stop_by_time   	= st.passive_stop_by_time   ? 1u : 0u;
    tx_forms.f12.speed          	= st.speed;
    tx_forms.f12.max_load       	= st.max_weight;
    tx_forms.f12.flexion_angle    	= st.passive_flexion_angle;
    tx_forms.f12.extension_angle    = st.passive_extension_angle;*/
    tx_forms.f12.status         	= 0;
}

void fill_form17_active()
{
/*    tx_forms.f17.cycles            = st.cycles_target;
    tx_forms.f17.duration_min      = st.duration_min;
    tx_forms.f17.stop_by_cycles    = st.stop_by_cycles;
    tx_forms.f17.stop_by_time      = st.stop_by_time;
    tx_forms.f17.speed             = st.speed;
    tx_forms.f17.max_load          = st.max_load;*/

	tx_forms.f17.stop_by_cycles  = pSetCycleTime_data[pSetCycleTime_cStopByCycle];
	tx_forms.f17.stop_by_time = pSetCycleTime_data[pSetCycleTime_cStopByTime];
    tx_forms.f17.cycles   =  pSetCycleTime_data[pSetCycleTime_nCycleSP];
    tx_forms.f17.duration_min = pSetCycleTime_data[pSetCycleTime_nTimeSP];

    tx_forms.f17.speed = pSet_data[pSet_nVelocity];
    tx_forms.f17.max_load = pSetEfforts_data[pSetEfforts_nEffortMaxSP];

    tx_forms.f17.bend_angle = pAT_data[pAT_nABendAngleSP];  //актиная стадия
    tx_forms.f17.exp_angle = pAT_data[pAT_nAExpAngleSP];	//актиная стадия

    tx_forms.f17.bend_assist_angle = pAT_data[pAT_nPBendAngleSP]; //пассивная стадия
    tx_forms.f17.exp_assist_angle = pAT_data[pAT_nPExpAngleSP]; //пассивная стадия

    tx_forms.f17.bend_load = pAT_data[pAT_nEffortBendSP];
    tx_forms.f17.exp_load = pAT_data[pAT_nEffortExpSP];

/*    tx_forms.f17.bend_angle        = st.bend_angle;
    tx_forms.f17.exp_angle         = st.exp_angle;

    tx_forms.f17.bend_assist_angle = st.active_bend_assist_angle;
    tx_forms.f17.exp_assist_angle  = st.active_exp_assist_angle;

    tx_forms.f17.bend_load         = st.active_bend_load;
    tx_forms.f17.exp_load          = st.active_exp_load;*/

    tx_forms.f17.status            = 0;//current_status_u8();
}

void fill_form20_system()
{
    tx_forms.f20.max_load    = st.max_load;
    tx_forms.f20.speed       = st.speed;
    tx_forms.f20.cycles      = st.cycles_target;
    tx_forms.f20.duration_min = st.duration_min;

    tx_forms.f20.stop_by_cycles = st.stop_by_cycles;
    tx_forms.f20.stop_by_time   = st.stop_by_time;

    tx_forms.f20.bend_angle = st.bend_angle;
    tx_forms.f20.exp_angle  = st.exp_angle;

    tx_forms.f20.status = 0;//current_status_u8();
}

static void process_packet()
{
    uint8_t form_id;
    uint8_t len;
    uint8_t payload_copy[64];

    //__disable_irq();
    form_id = rx_ctx.packet.form_id;
    len     = rx_ctx.packet.len;
    memcpy(payload_copy, (const void*)rx_ctx.packet.payload, len);
    rx_ctx.packet.ready = false;
   // __enable_irq();

    bool ok = true;

    switch (form_id) {
        case FORM1_ID:
            ok = handle_form1(payload_copy, len);
            break;

        case FORM4_ID:
            ok = handle_form4(payload_copy, len);
            break;

        case FORM5_ID:
            ok = handle_form5(payload_copy, len);
            break;

        case FORM6_ID:
            ok = handle_form6(payload_copy, len);
            break;

        case FORM7_ID:
            ok = handle_form7(payload_copy, len);
            break;
        case FORM8_ID:
        	ok = handle_form8(payload_copy, len);
        	break;
        case FORM9_ID:
        	ok = handle_form9(payload_copy, len);
        	break;
        case FORM13_ID:
        	ok = handle_form13(len);
        	break;
        case FORM14_ID:
        	ok = handle_form14(len);
        	break;
        case FORM15_ID:
            ok = handle_form15(payload_copy, len);
            break;
        case FORM16_ID:
            ok = handle_form16(payload_copy, len);
            break;
        case FORM18_ID:
            ok = handle_form18(len);
            break;
        case FORM19_ID:
            ok = handle_form19(len);
            break;
        case FORM21_ID:
            ok = handle_form21(payload_copy, len);
            break;
        default:
            ok = false;
            break;
    }

    (void)ok; // чтобы не ругался компилятор, если не используешь результат
}

void rx_irq(uint16_t len)
{
	for(uint16_t i = 0; i < len; i++)
	{
		uint8_t c = string_rx3[i];

        switch (rx_ctx.state) {
            case RX_WAIT_SOF:
                if (c == 0xAA) {
                    rx_ctx.state = RX_READ_FORM_ID;
                }
                break;

            case RX_READ_FORM_ID:
                rx_ctx.form_id = c;
                rx_ctx.state = RX_READ_LEN;
                break;

            case RX_READ_LEN:
                rx_ctx.len = c;
                rx_ctx.index = 0;

                if (rx_ctx.len > sizeof(rx_ctx.packet.payload)) {
                    rx_ctx.state = RX_WAIT_SOF;
                    rx_ctx.form_id = 0;
                    rx_ctx.len = 0;
                } else if (rx_ctx.len == 0) {
                    rx_ctx.state = RX_READ_CRC;
                } else {
                    rx_ctx.state = RX_READ_PAYLOAD;
                }
                break;

            case RX_READ_PAYLOAD:
                rx_ctx.packet.payload[rx_ctx.index++] = c;
                if (rx_ctx.index >= rx_ctx.len) {
                    rx_ctx.state = RX_READ_CRC;
                }
                break;

            case RX_READ_CRC:
            {
                rx_ctx.crc = c;
                uint8_t calc = calc_crc(rx_ctx.form_id, rx_ctx.len, rx_ctx.packet.payload);

                if ((calc == rx_ctx.crc) && !rx_ctx.packet.ready) {
                    rx_ctx.packet.form_id = rx_ctx.form_id;
                    rx_ctx.packet.len     = rx_ctx.len;
                    rx_ctx.packet.ready   = true;
                }

                rx_ctx.state   = RX_WAIT_SOF;
                rx_ctx.form_id = 0;
                rx_ctx.len     = 0;
                rx_ctx.crc     = 0;
                rx_ctx.index   = 0;
                break;
            }
        }
    }

	if(rx_ctx.packet.ready)
	{
		process_packet();
	}
	else
	{
		//error
	}
}

void esp_receive()
{
	DWT_Delay_us(1);
}
