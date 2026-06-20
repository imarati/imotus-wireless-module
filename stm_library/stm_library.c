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

bool connected_flag = false;
uart_rx_context_t rx_ctx;
desk_state_t st;
forms_rx_t rx_forms;
forms_tx_t tx_forms;

/*static void copy_fixed_str_from_rx(char* dst, size_t dst_size, const char* src, size_t src_size)
{
    if (dst_size == 0) return;

    size_t n = (src_size < (dst_size - 1)) ? src_size : (dst_size - 1);
    memcpy(dst, src, n);
    dst[n] = '\0';

    for (size_t i = 0; i < n; i++) {
        if (dst[i] == '\0') {
            return;
        }
    }

    dst[dst_size - 1] = '\0';
}*/

/*static void copy_fixed_str_to_tx(char* dst, size_t dst_size, const char* src)
{
    memset(dst, 0, dst_size);
    if (!src) return;

    size_t src_len = strlen(src);
    size_t n = (src_len < dst_size) ? src_len : dst_size;
    memcpy(dst, src, n);
}*/

void send_form2_status()
{
    fill_form2_status();

    send_packet(FORM2_ID, (uint8_t*)&tx_forms.f2, FORM2_LEN);
}

void send_form3_initial()
{
    fill_form3_initial();

    send_packet(FORM3_ID, (uint8_t*)&tx_forms.f3, FORM3_LEN);
}

void send_form6_manual(void)
{
    fill_form6_manual();
    send_packet(FORM6_ID, (uint8_t*)&tx_forms.f6, FORM6_LEN);
}

void send_form8_passive(void)
{
    fill_form8_passive();
    send_packet(FORM8_ID, (uint8_t*)&tx_forms.f8, FORM8_LEN);
}

void send_form10_passive_status(void)
{
    fill_form10_passive_status();
    send_packet(FORM10_ID, (uint8_t*)&tx_forms.f10, FORM10_LEN);
}

void send_form13_active(void)
{
    fill_form13_active();
    send_packet(FORM13_ID, (uint8_t*)&tx_forms.f13, FORM13_LEN);
}

void send_form17_system(void)
{
    fill_form17_system();
    send_packet(FORM17_ID, (uint8_t*)&tx_forms.f17, FORM17_LEN);
}

void send_form18_patient_info(void)
{
    fill_form18_patient_info();
    send_packet(FORM18_ID, (uint8_t*)&tx_forms.f18, FORM18_LEN);
}

void send_form19_session_datetime(void)
{
    fill_form19_session_datetime();
    send_packet(FORM19_ID, (uint8_t*)&tx_forms.f19, FORM19_LEN);
}

void send_form20_active_status(void)
{
    fill_form20_active_status();
    send_packet(FORM20_ID, (uint8_t*)&tx_forms.f20, FORM20_LEN);
}

void send_form23_active_procedures(void)
{
    fill_form23_active_procedures();
    send_packet(FORM23_ID, (uint8_t*)&tx_forms.f23, FORM23_LEN);
}

void send_form24_active_warmup_settings(void)
{
    fill_form24_active_warmup_settings();
    send_packet(FORM24_ID, (uint8_t*)&tx_forms.f24, FORM24_LEN);
}

void send_form27_active_cooldown_settings(void)
{
    fill_form27_active_cooldown_settings();
    send_packet(FORM27_ID, (uint8_t*)&tx_forms.f27, FORM27_LEN);
}

void send_form30_passive_procedures(void)
{
    fill_form30_passive_procedures();
    send_packet(FORM30_ID, (uint8_t*)&tx_forms.f30, FORM30_LEN);
}

void send_form32_passive_warmup_settings(void)
{
    fill_form32_passive_warmup_settings();
    send_packet(FORM32_ID, (uint8_t*)&tx_forms.f32, FORM32_LEN);
}

void send_form34_passive_cooldown_settings(void)
{
    fill_form34_passive_cooldown_settings();
    send_packet(FORM34_ID, (uint8_t*)&tx_forms.f34, FORM34_LEN);
}

void send_form36_passive_comfort_settings(void)
{
    fill_form36_passive_comfort_settings();
    send_packet(FORM36_ID, (uint8_t*)&tx_forms.f36, FORM36_LEN);
}

void send_form38_active_comfort_settings(void)
{
    fill_form38_active_comfort_settings();
    send_packet(FORM38_ID, (uint8_t*)&tx_forms.f38, FORM38_LEN);
}

void send_form39_passive_functions(void)
{
    fill_form39_passive_functions();
    send_packet(FORM39_ID, (uint8_t*)&tx_forms.f39, FORM39_LEN);
}



// RX HANDLERS
static bool handle_form1(const uint8_t* payload, uint8_t len)
{
    if (len != FORM1_LEN)
    {
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
    if (len != FORM6_LEN) return false;
    memcpy(&rx_forms.f6, payload, sizeof(rx_forms.f6));

    pSetEfforts_data[pSetEfforts_nEffortMaxSP] = rx_forms.f6.max_load;
    pManFunc_data[pManFunc_nVelocity]          = rx_forms.f6.manual_speed;

    send_form6_manual();
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
    send_form8_passive();
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
        case FORM9_CMD_PAUSE:
                    pPT_data[pPT_bStart] = 0;
                    pPT_data[pPT_bStop]  = 0;
                    pPT_data[pPT_bPause] = 1;
                    return true;
        default:
            return false;
    }
}

static bool handle_form11(uint8_t len)
{
    if (len != FORM11_LEN) return false;
    send_form6_manual();
    return true;
}

static bool handle_form12(uint8_t len)
{
    if (len != FORM12_LEN) return false;
    send_form8_passive();
    return true;
}

static bool handle_form13(const uint8_t* payload, uint8_t len)
{
    if (len != FORM13_LEN) return false;
    memcpy(&rx_forms.f13, payload, sizeof(rx_forms.f13));

    pSetCycleTime_data[pSetCycleTime_cStopByCycle] = rx_forms.f13.stop_by_cycles;
    pSetCycleTime_data[pSetCycleTime_cStopByTime]  = rx_forms.f13.stop_by_time;
    pSetCycleTime_data[pSetCycleTime_nCycleSP]     = rx_forms.f13.cycles;
    pSetCycleTime_data[pSetCycleTime_nTimeSP]      = rx_forms.f13.duration_min;
    pSet_data[pSet_nVelocity]                      = rx_forms.f13.speed;
    pSetEfforts_data[pSetEfforts_nEffortMaxSP]     = rx_forms.f13.max_load;
    pAT_data[pAT_nABendAngleSP]                   = rx_forms.f13.bend_angle;        /* активная стадия */
    pAT_data[pAT_nAExpAngleSP]                    = rx_forms.f13.exp_angle;          /* активная стадия */
    pAT_data[pAT_nPBendAngleSP]                   = rx_forms.f13.bend_assist_angle;  /* пассивная стадия */
    pAT_data[pAT_nPExpAngleSP]                    = rx_forms.f13.exp_assist_angle;   /* пассивная стадия */
    pAT_data[pAT_nEffortBendSP]                   = rx_forms.f13.bend_load;
    pAT_data[pAT_nEffortExpSP]                    = rx_forms.f13.exp_load;

    send_form13_active();
    return true;
}

static bool handle_form14(const uint8_t* payload, uint8_t len)
{
    if (len != FORM14_LEN) return false;
    memcpy(&rx_forms.f14, payload, sizeof(rx_forms.f14));
    display_data.screen_num = pAT;

    switch (rx_forms.f14.cmd) {
        case FORM14_CMD_STOP:
            pAT_data[pAT_bStart] = 0;
            pAT_data[pAT_bStop]  = 1;
            pAT_data[pAT_bPause] = 0;
            return true;

        case FORM14_CMD_START:
            st.mode = ACTIVE;
            pAT_data[pAT_bStart] = 1;
            pAT_data[pAT_bStop]  = 0;
            pAT_data[pAT_bPause] = 0;
            return true;

        case FORM14_CMD_PAUSE:
            pAT_data[pAT_bStart] = 0;
            pAT_data[pAT_bStop]  = 0;
            pAT_data[pAT_bPause] = 1;
            return true;

        default:
            return false;
    }
}

static bool handle_form15(uint8_t len)
{
    if (len != FORM15_LEN) return false;
    send_form13_active();
    return true;
}

static bool handle_form16(uint8_t len)
{
    if (len != FORM16_LEN) return false;
    send_form17_system();
    return true;
}

static bool handle_form17(const uint8_t* payload, uint8_t len)
{
    if (len != FORM17_LEN) return false;
    memcpy(&rx_forms.f17, payload, sizeof(rx_forms.f17));

    pSet_data[pSet_nVelocity]                      = rx_forms.f17.speed;
    pSetPauseBE_data[pSetPauseBE_nPauseBendSP]     = rx_forms.f17.bend_pause_sec;
    pSetPauseBE_data[pSetPauseBE_nPauseExpSP]      = rx_forms.f17.exp_pause_sec;
    pSetPauseBE_data[pSetPauseBE_cPauseBendEn]     = (rx_forms.f17.pause_on_bend != 0);
    pSetPauseBE_data[pSetPauseBE_cPauseExpEn]      = (rx_forms.f17.pause_on_exp  != 0);
    pSetCycleTime_data[pSetCycleTime_nCycleSP]     = rx_forms.f17.cycles;
    pSetCycleTime_data[pSetCycleTime_nTimeSP]      = rx_forms.f17.duration_min;
    pSetCycleTime_data[pSetCycleTime_cStopByCycle] = (rx_forms.f17.stop_by_cycles != 0);
    pSetCycleTime_data[pSetCycleTime_cStopByTime]  = (rx_forms.f17.stop_by_time   != 0);
    pSetEfforts_data[pSetEfforts_nEffortMaxSP]     = rx_forms.f17.max_load;
    pSetEfforts_data[pSetEfforts_nEffortBendSP]    = rx_forms.f17.bend_max_load;
    pSetEfforts_data[pSetEfforts_nEffortExpSP]     = rx_forms.f17.exp_max_load;
    pSetEfforts_data[pSetEfforts_cRevByEffort]     = (rx_forms.f17.reverse_on_load != 0);
    pSetEfforts_data[pSetEfforts_cPauseByEffort]   = (rx_forms.f17.stop_on_load    != 0);

/*    st.speed = rx_forms.f21.speed;
    st.bend_pause_sec = rx_forms.f21.bend_pause_sec;
    st.exp_pause_sec = rx_forms.f21.exp_pause_sec;
    st.pause_on_bend = (rx_forms.f21.pause_on_bend != 0);
    st.pause_on_exp = (rx_forms.f21.pause_on_exp != 0);
    st.cycles_target = rx_forms.f21.cycles;
    st.duration_min = rx_forms.f21.duration_min;
    st.stop_by_cycles = (rx_forms.f21.stop_by_cycles != 0);
    st.stop_by_time = (rx_forms.f21.stop_by_time != 0);
    st.max_load = rx_forms.f21.max_load;
    st.bend_max_load = rx_forms.f21.bend_max_load;
    st.exp_max_load = rx_forms.f21.exp_max_load;
    st.reverse_on_load = (rx_forms.f21.reverse_on_load != 0);
    st.stop_on_load = (rx_forms.f21.stop_on_load != 0);*/

    send_form17_system();
    return true;
}

static bool handle_form18(const uint8_t* payload, uint8_t len)
{
    if (len != FORM18_LEN) return false;
    memcpy(&rx_forms.f18, payload, sizeof(rx_forms.f18));

    memset(patient_data, 0, sizeof(patient_data));
    memcpy(patient_data[patient_sName],       rx_forms.f18.name,       strlen(rx_forms.f18.name));
    memcpy(patient_data[patient_sSurename],   rx_forms.f18.surname,    strlen(rx_forms.f18.surname));
    memcpy(patient_data[patient_sPatronymic], rx_forms.f18.patronymic, strlen(rx_forms.f18.patronymic));
    memcpy(patient_data[patient_sID],         rx_forms.f18.patient_id, strlen(rx_forms.f18.patient_id));
    param = param_patient_information;

    send_form18_patient_info();
    return true;
}


static bool handle_form19(const uint8_t* payload, uint8_t len)
{
    if (len != FORM19_LEN) return false;
    memcpy(&rx_forms.f19, payload, sizeof(rx_forms.f19));

    display_td_data.screen_year = rx_forms.f19.year - 2000;
    display_td_data.screen_month = rx_forms.f19.month;
    display_td_data.screen_date = rx_forms.f19.day;
    display_td_data.screen_hour = rx_forms.f19.hour;
    display_td_data.screen_minute = rx_forms.f19.minute;
    display_td_data.screen_second = rx_forms.f19.second;
    pSetDateTime_data[pSetDateTime_bSetDateTime] = 1;
    f_pSetDateTime();

    send_form19_session_datetime();
    return true;
}

static bool handle_form21(uint8_t len)
{
    if (len != FORM21_LEN) return false;
    send_form18_patient_info();
    return true;
}

static bool handle_form22(uint8_t len)
{
    if (len != FORM22_LEN) return false;
    send_form19_session_datetime();
    return true;
}

static bool handle_form23(const uint8_t* payload, uint8_t len)
{
    if (len != FORM23_LEN) return false;
    memcpy(&rx_forms.f23, payload, sizeof(rx_forms.f23));

    pATProc_data[pATProc_cHeatingEn] = rx_forms.f23.warmup_enabled;
    pATProc_data[pATProc_cCoollingEn] = rx_forms.f23.cooldown_enabled;
    pATProc_data[pATProc_cComfortEn] = rx_forms.f23.comfort_enabled;

    send_form23_active_procedures();
    return true;
}

static bool handle_form24(const uint8_t* payload, uint8_t len)
{
    if (len != FORM24_LEN) return false;
    memcpy(&rx_forms.f24, payload, sizeof(rx_forms.f24));

    pATProcHSet_data[pATProcHSet_nAngleStep]= rx_forms.f24.step;

    send_form24_active_warmup_settings();
    return true;
}

static bool handle_form25(uint8_t len)
{
    if (len != FORM25_LEN) return false;
    send_form23_active_procedures();
    return true;
}

static bool handle_form26(uint8_t len)
{
    if (len != FORM26_LEN) return false;
    send_form24_active_warmup_settings();
    return true;
}

static bool handle_form27(const uint8_t* payload, uint8_t len)
{
    if (len != FORM27_LEN) return false;
    memcpy(&rx_forms.f27, payload, sizeof(rx_forms.f27));

    pATProcCSet_data[pATProcCSet_nAngleStep] = rx_forms.f27.step;

    send_form27_active_cooldown_settings();
    return true;
}

static bool handle_form28(uint8_t len)
{
    if (len != FORM28_LEN) return false;
    send_form27_active_cooldown_settings();
    return true;
}

static bool handle_form29(uint8_t len)
{
    if (len != FORM29_LEN) return false;
    send_form38_active_comfort_settings();
    return true;
}

static bool handle_form30(const uint8_t* payload, uint8_t len)
{
    if (len != FORM30_LEN) return false;
    memcpy(&rx_forms.f30, payload, sizeof(rx_forms.f30));

    pPTProc_data[pPTProc_cHeatingEn] = rx_forms.f30.warmup_enabled;
    pPTProc_data[pPTProc_cCoollingEn] = rx_forms.f30.cooldown_enabled;
    pPTProc_data[pPTProc_cComfortEn]= rx_forms.f30.comfort_enabled;

    send_form30_passive_procedures();
    return true;
}

static bool handle_form31(uint8_t len)
{
    if (len != FORM31_LEN) return false;
    send_form30_passive_procedures();
    return true;
}

static bool handle_form32(const uint8_t* payload, uint8_t len)
{
    if (len != FORM32_LEN) return false;
    memcpy(&rx_forms.f32, payload, sizeof(rx_forms.f32));

    pPTProcHSet_data[pPTProcHSet_nAngleStep]= rx_forms.f32.step;

    send_form32_passive_warmup_settings();
    return true;
}

static bool handle_form33(uint8_t len)
{
    if (len != FORM33_LEN) return false;
    send_form32_passive_warmup_settings();
    return true;
}

static bool handle_form34(const uint8_t* payload, uint8_t len)
{
    if (len != FORM34_LEN) return false;
    memcpy(&rx_forms.f34, payload, sizeof(rx_forms.f34));

    pPTProcCSet_data[pPTProcCSet_nAngleStep]= rx_forms.f34.step;

    send_form34_passive_cooldown_settings();
    return true;
}

static bool handle_form35(uint8_t len)
{
    if (len != FORM35_LEN) return false;
    send_form34_passive_cooldown_settings();
    return true;
}

static bool handle_form36(const uint8_t* payload, uint8_t len)
{
    if (len != FORM36_LEN) return false;
    memcpy(&rx_forms.f36, payload, sizeof(rx_forms.f36));

    pPTProcFSet_data[pPTProcFSet_nAngleStep] = rx_forms.f36.step;
    pPTProcFSet_data[pPTProcFSet_nDeltaAngBend] = rx_forms.f36.bend_deviation;
    pPTProcFSet_data[pPTProcFSet_nDeltaAngExp] = rx_forms.f36.exp_deviation;

    send_form36_passive_comfort_settings();
    return true;
}

static bool handle_form37(uint8_t len)
{
    if (len != FORM37_LEN) return false;
    send_form36_passive_comfort_settings();
    return true;
}

static bool handle_form38(const uint8_t* payload, uint8_t len)
{
    if (len != FORM38_LEN) return false;
    memcpy(&rx_forms.f38, payload, sizeof(rx_forms.f38));

    pATProcFSet_data[pATProcFSet_nAngleStep]= rx_forms.f38.step;
    pATProcFSet_data[pATProcFSet_nDeltaAngBend]= rx_forms.f38.bend_deviation;
    pATProcFSet_data[pATProcFSet_nDeltaAngExp]= rx_forms.f38.exp_deviation;

    send_form38_active_comfort_settings();
    return true;
}

static bool handle_form39(const uint8_t* payload, uint8_t len)
{
    if (len != FORM39_LEN) return false;
    memcpy(&rx_forms.f39, payload, sizeof(rx_forms.f39));

    pPTFunc_data[pPTFunc_cSBEnable] = (rx_forms.f39.extend_bend_enabled != 0);
    pPTFunc_data[pPTFunc_cSEEnable] = (rx_forms.f39.extend_exp_enabled  != 0);
    flexion_cycles = rx_forms.f39.extend_repeats;

    send_form39_passive_functions();
    return true;
}

static bool handle_form40(uint8_t len)
{
    if (len != FORM40_LEN) return false;
    send_form39_passive_functions();
    return true;
}

// TX HELPERS (нужны для ответов Form2/3 из обработчиков)
void fill_form2_status()
{
	tx_forms.f2.year   = sDate.Year;
	tx_forms.f2.month  = sDate.Month;
	tx_forms.f2.day    = sDate.Date;
	tx_forms.f2.hour   = sTime.Hours;
	tx_forms.f2.minute = sTime.Minutes;
	tx_forms.f2.second = sTime.Seconds;

    //tx_forms.f2.timestamp = 0;//rtc_get_unix_time_u32();
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

void fill_form6_manual(void)
{
    tx_forms.f6.max_load     = pSetEfforts_data[pSetEfforts_nEffortMaxSP];
    tx_forms.f6.manual_speed = pManFunc_data[pManFunc_nVelocity];
}

void fill_form8_passive(void)
{
    tx_forms.f8.stop_by_cycles = pSetCycleTime_data[pSetCycleTime_cStopByCycle];
    tx_forms.f8.stop_by_time   = pSetCycleTime_data[pSetCycleTime_cStopByTime];
    tx_forms.f8.cycles         = pSetCycleTime_data[pSetCycleTime_nCycleSP];
    tx_forms.f8.duration_min   = pSetCycleTime_data[pSetCycleTime_nTimeSP];
    tx_forms.f8.speed          = pSet_data[pSet_nVelocity];
    tx_forms.f8.max_load       = pSetEfforts_data[pSetEfforts_nEffortMaxSP];
    tx_forms.f8.bend_angle     = pPT_data[pPT_nBendAngleSP];
    tx_forms.f8.exp_angle      = pPT_data[pPT_nExpAngleSP];
}

void fill_form10_passive_status(void)
{
    tx_forms.f10.done_cycles      = pPT_data[pPT_nCurrentCycle];
    tx_forms.f10.elapsed_seconds  = ms_timer.sec_counter;
    tx_forms.f10.status           = 0;
}

void fill_form13_active(void)
{
    tx_forms.f13.stop_by_cycles    = pSetCycleTime_data[pSetCycleTime_cStopByCycle];
    tx_forms.f13.stop_by_time      = pSetCycleTime_data[pSetCycleTime_cStopByTime];
    tx_forms.f13.cycles            = pSetCycleTime_data[pSetCycleTime_nCycleSP];
    tx_forms.f13.duration_min      = pSetCycleTime_data[pSetCycleTime_nTimeSP];
    tx_forms.f13.speed             = pSet_data[pSet_nVelocity];
    tx_forms.f13.max_load          = pSetEfforts_data[pSetEfforts_nEffortMaxSP];
    tx_forms.f13.bend_angle        = pAT_data[pAT_nABendAngleSP];   /* активная стадия */
    tx_forms.f13.exp_angle         = pAT_data[pAT_nAExpAngleSP];    /* активная стадия */
    tx_forms.f13.bend_assist_angle = pAT_data[pAT_nPBendAngleSP];   /* пассивная стадия */
    tx_forms.f13.exp_assist_angle  = pAT_data[pAT_nPExpAngleSP];    /* пассивная стадия */
    tx_forms.f13.bend_load         = pAT_data[pAT_nEffortBendSP];
    tx_forms.f13.exp_load          = pAT_data[pAT_nEffortExpSP];
}

void fill_form17_system(void)
{
    tx_forms.f17.speed           = pSet_data[pSet_nVelocity];
    tx_forms.f17.bend_pause_sec  = pSetPauseBE_data[pSetPauseBE_nPauseBendSP];
    tx_forms.f17.exp_pause_sec   = pSetPauseBE_data[pSetPauseBE_nPauseExpSP];
    tx_forms.f17.pause_on_bend   = pSetPauseBE_data[pSetPauseBE_cPauseBendEn];
    tx_forms.f17.pause_on_exp    = pSetPauseBE_data[pSetPauseBE_cPauseExpEn];
    tx_forms.f17.cycles          = pSetCycleTime_data[pSetCycleTime_nCycleSP];
    tx_forms.f17.duration_min    = pSetCycleTime_data[pSetCycleTime_nTimeSP];
    tx_forms.f17.stop_by_cycles  = pSetCycleTime_data[pSetCycleTime_cStopByCycle];
    tx_forms.f17.stop_by_time    = pSetCycleTime_data[pSetCycleTime_cStopByTime];
    tx_forms.f17.max_load        = pSetEfforts_data[pSetEfforts_nEffortMaxSP];
    tx_forms.f17.bend_max_load   = pSetEfforts_data[pSetEfforts_nEffortBendSP];
    tx_forms.f17.exp_max_load    = pSetEfforts_data[pSetEfforts_nEffortExpSP];
    tx_forms.f17.reverse_on_load = pSetEfforts_data[pSetEfforts_cRevByEffort];
    tx_forms.f17.stop_on_load    = pSetEfforts_data[pSetEfforts_cPauseByEffort];
}

void fill_form18_patient_info(void)
{
    memset(&tx_forms.f18, 0, sizeof(tx_forms.f18));
    memcpy(tx_forms.f18.name,       patient_data[patient_sName],       strlen(patient_data[patient_sName]));
    memcpy(tx_forms.f18.surname,    patient_data[patient_sSurename],    strlen(patient_data[patient_sSurename]));
    memcpy(tx_forms.f18.patronymic, patient_data[patient_sPatronymic],  strlen(patient_data[patient_sPatronymic]));
    memcpy(tx_forms.f18.patient_id, patient_data[patient_sID],          strlen(patient_data[patient_sID]));
}

void fill_form19_session_datetime(void)
{
    tx_forms.f19.year   = display_td_data.screen_year;
    tx_forms.f19.month  = display_td_data.screen_month;
    tx_forms.f19.day    = display_td_data.screen_date;
    tx_forms.f19.hour   = display_td_data.screen_hour;
    tx_forms.f19.minute = display_td_data.screen_minute;
    tx_forms.f19.second = display_td_data.screen_second;
}

void fill_form20_active_status(void)
{
    tx_forms.f20.elapsed_seconds = ms_timer.sec_counter;
    tx_forms.f20.done_cycles     = pAT_data[pPT_nCurrentCycle];
    tx_forms.f20.status          = 0;
}

void fill_form23_active_procedures(void)
{
    tx_forms.f23.warmup_enabled   = pATProc_data[pATProc_cHeatingEn];
    tx_forms.f23.cooldown_enabled = pATProc_data[pATProc_cCoollingEn];
    tx_forms.f23.comfort_enabled  = pATProc_data[pATProc_cComfortEn];
}

void fill_form24_active_warmup_settings(void)
{
    tx_forms.f24.step    = pATProcHSet_data[pATProcHSet_nAngleStep];
}

void fill_form27_active_cooldown_settings(void)
{
    tx_forms.f27.step    = pATProcCSet_data[pATProcCSet_nAngleStep];
}


void fill_form30_passive_procedures(void)
{
    tx_forms.f30.warmup_enabled   = pPTProc_data[pPTProc_cHeatingEn];
    tx_forms.f30.cooldown_enabled = pPTProc_data[pPTProc_cCoollingEn];
    tx_forms.f30.comfort_enabled  = pPTProc_data[pPTProc_cComfortEn];
}


void fill_form32_passive_warmup_settings(void)
{
    tx_forms.f32.step    = pPTProcHSet_data[pPTProcHSet_nAngleStep];
}


void fill_form34_passive_cooldown_settings(void)
{
    tx_forms.f34.step    = pPTProcCSet_data[pPTProcCSet_nAngleStep];
}


void fill_form36_passive_comfort_settings(void)
{
    tx_forms.f36.step           = pPTProcFSet_data[pPTProcFSet_nAngleStep];
    tx_forms.f36.bend_deviation = pPTProcFSet_data[pPTProcFSet_nDeltaAngBend];
    tx_forms.f36.exp_deviation  = pPTProcFSet_data[pPTProcFSet_nDeltaAngExp];
}


void fill_form38_active_comfort_settings(void)
{
    tx_forms.f38.step           = pATProcFSet_data[pATProcFSet_nAngleStep];
    tx_forms.f38.bend_deviation = pATProcFSet_data[pATProcFSet_nDeltaAngBend];
    tx_forms.f38.exp_deviation  = pATProcFSet_data[pATProcFSet_nDeltaAngExp];
}


void fill_form39_passive_functions(void)
{
    tx_forms.f39.extend_bend_enabled = pPTFunc_data[pPTFunc_cSBEnable];
    tx_forms.f39.extend_exp_enabled  = pPTFunc_data[pPTFunc_cSEEnable];
    tx_forms.f39.extend_repeats      = flexion_cycles;
}

static void process_packet()
{
    uint8_t form_id;
    uint8_t len;
    uint8_t payload_copy[256];

    //__disable_irq();
    form_id = rx_ctx.packet.form_id;
    len     = rx_ctx.packet.len;
    memcpy(payload_copy, (const void*)rx_ctx.packet.payload, len);
    rx_ctx.packet.ready = false;
   // __enable_irq();

    bool ok = true;

    switch (form_id) {
            /* ---------- нет payload ---------- */
            case FORM7_ID:  ok = handle_form7 (payload_copy, len); break;
            case FORM11_ID: ok = handle_form11(len);               break;
            case FORM12_ID: ok = handle_form12(len);               break;
            case FORM15_ID: ok = handle_form15(len);               break;
            case FORM16_ID: ok = handle_form16(len);               break;
            case FORM21_ID: ok = handle_form21(len);               break;
            case FORM22_ID: ok = handle_form22(len);               break;
            case FORM25_ID: ok = handle_form25(len);               break;
            case FORM26_ID: ok = handle_form26(len);               break;
            case FORM28_ID: ok = handle_form28(len);               break;
            case FORM29_ID: ok = handle_form29(len);               break;
            case FORM31_ID: ok = handle_form31(len);               break;
            case FORM33_ID: ok = handle_form33(len);               break;
            case FORM35_ID: ok = handle_form35(len);               break;
            case FORM37_ID: ok = handle_form37(len);               break;
            case FORM40_ID: ok = handle_form40(len);               break;

            /* ---------- с payload ---------- */
            case FORM1_ID:  ok = handle_form1 (payload_copy, len); break;
            case FORM4_ID:  ok = handle_form4 (payload_copy, len); break;
            case FORM5_ID:  ok = handle_form5 (payload_copy, len); break;
            case FORM6_ID:  ok = handle_form6 (payload_copy, len); break;
            case FORM8_ID:  ok = handle_form8 (payload_copy, len); break;
            case FORM9_ID:  ok = handle_form9 (payload_copy, len); break;
            case FORM13_ID: ok = handle_form13(payload_copy, len); break;
            case FORM14_ID: ok = handle_form14(payload_copy, len); break;
            case FORM17_ID: ok = handle_form17(payload_copy, len); break;
            case FORM18_ID: ok = handle_form18(payload_copy, len); break;
            case FORM19_ID: ok = handle_form19(payload_copy, len); break;
            case FORM23_ID: ok = handle_form23(payload_copy, len); break;
            case FORM24_ID: ok = handle_form24(payload_copy, len); break;
            case FORM27_ID: ok = handle_form27(payload_copy, len); break;
            case FORM30_ID: ok = handle_form30(payload_copy, len); break;
            case FORM32_ID: ok = handle_form32(payload_copy, len); break;
            case FORM34_ID: ok = handle_form34(payload_copy, len); break;
            case FORM36_ID: ok = handle_form36(payload_copy, len); break;
            case FORM38_ID: ok = handle_form38(payload_copy, len); break;
            case FORM39_ID: ok = handle_form39(payload_copy, len); break;

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
