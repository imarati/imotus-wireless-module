/*
 * esp.h
 *
 *  Created on: Apr 9, 2026
 *      Author: grey2
 */

#ifndef INC_ESP_H_
#define INC_ESP_H_

#include "debugger.h"

void esp_receive();
void rx_irq(uint16_t len);

#define FORM1_ID  1u
#define FORM2_ID  2u
#define FORM3_ID  3u
#define FORM4_ID  4u
#define FORM5_ID  5u
#define FORM6_ID  6u
#define FORM7_ID  7u
#define FORM8_ID  8u
#define FORM9_ID  9u
#define FORM10_ID 10u
#define FORM11_ID 11u
#define FORM12_ID 12u
#define FORM13_ID 13u
#define FORM14_ID 14u
#define FORM15_ID 15u
#define FORM16_ID 16u
#define FORM17_ID 17u
#define FORM18_ID 18u
#define FORM19_ID 19u
#define FORM20_ID 20u
#define FORM21_ID 21u
#define FORM22_ID 22u
#define FORM23_ID 23u
#define FORM24_ID 24u
#define FORM25_ID 25u
#define FORM26_ID 26u
#define FORM27_ID 27u
#define FORM28_ID 28u
#define FORM29_ID 29u
#define FORM30_ID 30u
#define FORM31_ID 31u
#define FORM32_ID 32u
#define FORM33_ID 33u
#define FORM34_ID 34u
#define FORM35_ID 35u
#define FORM36_ID 36u
#define FORM37_ID 37u
#define FORM38_ID 38u
#define FORM39_ID 39u
#define FORM40_ID 40u

#define FORM5_CMD_IDLE  0u
#define FORM5_CMD_LEFT  1u
#define FORM5_CMD_RIGHT 2u

#define FORM9_CMD_STOP  0u
#define FORM9_CMD_START 1u
#define FORM9_CMD_PAUSE 2u

#define FORM14_CMD_STOP  0u
#define FORM14_CMD_START 1u
#define FORM14_CMD_PAUSE 2u

void fill_form2_status(void);
void fill_form3_initial(void);
void fill_form6_manual(void);
void fill_form8_passive(void);
void fill_form10_passive_status(void);
void fill_form13_active(void);
void fill_form17_system(void);
void fill_form18_patient_info(void);
void fill_form19_session_datetime(void);
void fill_form20_active_status(void);
void fill_form23_active_procedures(void);
void fill_form24_active_warmup_settings(void);
void fill_form27_active_cooldown_settings(void);
void fill_form30_passive_procedures(void);
void fill_form32_passive_warmup_settings(void);
void fill_form34_passive_cooldown_settings(void);
void fill_form36_passive_comfort_settings(void);
void fill_form38_active_comfort_settings(void);
void fill_form39_passive_functions(void);

void send_form2_status(void);
void send_form3_initial(void);
void send_form6_manual(void);
void send_form8_passive(void);
void send_form10_passive_status(void);
void send_form13_active(void);
void send_form17_system(void);
void send_form18_patient_info(void);
void send_form19_session_datetime(void);
void send_form20_active_status(void);
void send_form23_active_procedures(void);
void send_form24_active_warmup_settings(void);
void send_form27_active_cooldown_settings(void);
void send_form30_passive_procedures(void);
void send_form32_passive_warmup_settings(void);
void send_form34_passive_cooldown_settings(void);
void send_form36_passive_comfort_settings(void);
void send_form38_active_comfort_settings(void);
void send_form39_passive_functions(void);

extern bool connected_flag;

#pragma pack(push, 1)
typedef struct {
    uint32_t timestamp;
} form1_sync_time_t;

typedef struct {
	uint16_t year;
	uint8_t  month;
	uint8_t  day;
    uint8_t  hour;
    uint8_t  minute;
    uint8_t  second;
    int16_t  angle;
    uint16_t load;
    uint8_t  status;
} form2_status_t;

typedef struct {
    uint8_t  status;
} form3_initial_state_t;

typedef struct {
    int16_t target_angle;
} form4_set_target_angle_t;

typedef struct {
    uint8_t cmd;
} form5_manual_cmd_t;

typedef struct {
    uint16_t max_load;
    uint16_t manual_speed;
} form6_manual_settings_t;

typedef struct {
    uint16_t cycles;
    uint16_t duration_min;
    uint8_t  stop_by_cycles;
    uint8_t  stop_by_time;
    uint16_t speed;
    uint16_t max_load;
    int16_t  bend_angle;
    int16_t  exp_angle;
} form8_passive_settings_t;

typedef struct {
    uint8_t cmd;
} form9_passive_cmd_t;

typedef struct {
    uint16_t elapsed_seconds;
    uint16_t done_cycles;
    uint8_t  status;
} form10_passive_training_status_t;

typedef struct {
    uint16_t cycles;
    uint16_t duration_min;
    uint8_t  stop_by_cycles;
    uint8_t  stop_by_time;
    uint16_t speed;
    uint16_t max_load;
    int16_t  bend_angle;
    int16_t  exp_angle;
    int16_t  bend_assist_angle;
    int16_t  exp_assist_angle;
    int16_t  bend_load;
    int16_t  exp_load;
} form13_active_settings_t;

typedef struct {
    uint8_t cmd;
} form14_active_cmd_t;

typedef struct {
    uint16_t speed;
    uint16_t bend_pause_sec;
    uint16_t exp_pause_sec;
    uint8_t  pause_on_bend;
    uint8_t  pause_on_exp;
    uint16_t cycles;
    uint16_t duration_min;
    uint8_t  stop_by_cycles;
    uint8_t  stop_by_time;
    uint16_t max_load;
    uint16_t bend_max_load;
    uint16_t exp_max_load;
    uint8_t  reverse_on_load;
    uint8_t  stop_on_load;
} form17_system_settings_t;

typedef struct {
    char name[20];
    char surname[20];
    char patronymic[20];
    char patient_id[20];
} form18_patient_info_t;

typedef struct {
    uint16_t year;
    uint8_t  month;
    uint8_t  day;
    uint8_t  hour;
    uint8_t  minute;
    uint8_t  second;
} form19_session_datetime_t;

typedef struct {
    uint32_t elapsed_seconds;
    uint16_t done_cycles;
    uint8_t  status;
} form20_active_training_status_t;

typedef struct {
    uint8_t warmup_enabled;
    uint8_t cooldown_enabled;
    uint8_t comfort_enabled;
} form23_active_procedures_t;

typedef struct {
    uint16_t step;
} form24_active_warmup_settings_t;

typedef struct {
     uint16_t step;
} form27_active_cooldown_settings_t;

typedef struct {
    uint8_t warmup_enabled;
    uint8_t cooldown_enabled;
    uint8_t comfort_enabled;
} form30_passive_procedures_t;

typedef struct {
    uint16_t step;
} form32_passive_warmup_settings_t;

typedef struct {
    uint16_t step;
} form34_passive_cooldown_settings_t;

typedef struct {
    uint16_t step;
    uint16_t bend_deviation;
    uint16_t exp_deviation;
} form36_passive_comfort_settings_t;

typedef struct {
    uint16_t step;
    uint16_t bend_deviation;
    uint16_t exp_deviation;
} form38_active_comfort_settings_t;

typedef struct {
    uint8_t  extend_bend_enabled;
    uint8_t  extend_exp_enabled;
    uint16_t extend_repeats;
} form39_passive_functions_t;

#pragma pack(pop)

#define FORM1_LEN ((uint8_t)sizeof(form1_sync_time_t))
#define FORM2_LEN ((uint8_t)sizeof(form2_status_t))
#define FORM3_LEN ((uint8_t)sizeof(form3_initial_state_t))
#define FORM4_LEN ((uint8_t)sizeof(form4_set_target_angle_t))
#define FORM5_LEN ((uint8_t)sizeof(form5_manual_cmd_t))
#define FORM6_LEN ((uint8_t)sizeof(form6_manual_settings_t))
#define FORM7_LEN 0u
#define FORM8_LEN ((uint8_t)sizeof(form8_passive_settings_t))
#define FORM9_LEN ((uint8_t)sizeof(form9_passive_cmd_t))
#define FORM10_LEN ((uint8_t)sizeof(form10_passive_training_status_t))
#define FORM11_LEN 0u
#define FORM12_LEN 0u
#define FORM13_LEN ((uint8_t)sizeof(form13_active_settings_t))
#define FORM14_LEN ((uint8_t)sizeof(form14_active_cmd_t))
#define FORM15_LEN 0u
#define FORM16_LEN 0u
#define FORM17_LEN ((uint8_t)sizeof(form17_system_settings_t))
#define FORM18_LEN ((uint8_t)sizeof(form18_patient_info_t))
#define FORM19_LEN ((uint8_t)sizeof(form19_session_datetime_t))
#define FORM20_LEN ((uint8_t)sizeof(form20_active_training_status_t))
#define FORM21_LEN 0u
#define FORM22_LEN 0u
#define FORM23_LEN ((uint8_t)sizeof(form23_active_procedures_t))
#define FORM24_LEN ((uint8_t)sizeof(form24_active_warmup_settings_t))
#define FORM25_LEN 0u
#define FORM26_LEN 0u
#define FORM27_LEN ((uint8_t)sizeof(form27_active_cooldown_settings_t))
#define FORM28_LEN 0u
#define FORM29_LEN 0u
#define FORM30_LEN ((uint8_t)sizeof(form30_passive_procedures_t))
#define FORM31_LEN 0u
#define FORM32_LEN ((uint8_t)sizeof(form32_passive_warmup_settings_t))
#define FORM33_LEN 0u
#define FORM34_LEN ((uint8_t)sizeof(form34_passive_cooldown_settings_t))
#define FORM35_LEN 0u
#define FORM36_LEN ((uint8_t)sizeof(form36_passive_comfort_settings_t))
#define FORM37_LEN 0u
#define FORM38_LEN ((uint8_t)sizeof(form38_active_comfort_settings_t))
#define FORM39_LEN ((uint8_t)sizeof(form39_passive_functions_t))
#define FORM40_LEN 0u


typedef enum  {
    IDLE,
    MANUAL_LEFT,
    MANUAL_RIGHT,
    AUTO,
	PASSIVE,
    ACTIVE
}ControlMode;

// FORMS
typedef struct  {
    form1_sync_time_t                  f1;
    form4_set_target_angle_t           f4;
    form5_manual_cmd_t                 f5;
    form6_manual_settings_t            f6;
    form8_passive_settings_t           f8;
    form9_passive_cmd_t                f9;
    form13_active_settings_t           f13;
    form14_active_cmd_t                f14;
    form17_system_settings_t           f17;
    form18_patient_info_t              f18;
    form19_session_datetime_t          f19;
    form23_active_procedures_t         f23;
    form24_active_warmup_settings_t    f24;
    form27_active_cooldown_settings_t  f27;
    form30_passive_procedures_t        f30;
    form32_passive_warmup_settings_t   f32;
    form34_passive_cooldown_settings_t f34;
    form36_passive_comfort_settings_t  f36;
    form38_active_comfort_settings_t   f38;
    form39_passive_functions_t         f39;
}forms_rx_t;

typedef struct  {
    form2_status_t                     f2;
    form3_initial_state_t              f3;
    form6_manual_settings_t            f6;
    form8_passive_settings_t           f8;
    form10_passive_training_status_t   f10;
    form13_active_settings_t           f13;
    form17_system_settings_t           f17;
    form18_patient_info_t              f18;
    form19_session_datetime_t          f19;
    form20_active_training_status_t    f20;
    form23_active_procedures_t         f23;
    form24_active_warmup_settings_t    f24;
    form27_active_cooldown_settings_t  f27;
    form30_passive_procedures_t        f30;
    form32_passive_warmup_settings_t   f32;
    form34_passive_cooldown_settings_t f34;
    form36_passive_comfort_settings_t  f36;
    form38_active_comfort_settings_t   f38;
    form39_passive_functions_t         f39;
}forms_tx_t;

// RX CONTEXT
typedef enum  {
    RX_WAIT_SOF,
    RX_READ_FORM_ID,
    RX_READ_LEN,
    RX_READ_PAYLOAD,
    RX_READ_CRC
}RxState;

typedef struct  {
    uint8_t form_id;
    uint8_t len;
    uint8_t payload[256];
    bool    ready;
}rx_packet_t;

struct uart_rx_context_t {
    RxState state;
    uint8_t form_id;
    uint8_t len;
    uint8_t crc;
    uint8_t index;
    rx_packet_t packet;
};

// STATE
typedef struct  {
	float    angle;
	float    target_angle;
    int16_t  load;
    uint16_t max_load;
    uint16_t manual_speed;

    int16_t  bend_angle;
    int16_t  exp_angle;
    uint16_t cycles_target;
    uint16_t duration_min;
    bool     stop_by_cycles;
    bool     stop_by_time;
    uint16_t speed;
    uint16_t done_cycles;
    uint16_t elapsed_seconds;
    bool     paused;

    int16_t active_bend_assist_angle;
    int16_t active_exp_assist_angle;
    int16_t active_bend_load;
    int16_t active_exp_load;

    /* SYSTEM SETTINGS */
    uint16_t bend_pause_sec;
    uint16_t exp_pause_sec;
    bool     pause_on_bend;
    bool     pause_on_exp;
    uint16_t bend_max_load;
    uint16_t exp_max_load;
    bool     reverse_on_load;
    bool     stop_on_load;

    /* PATIENT INFO */
    char patient_surname[20];
    char patient_name[20];
    char patient_patronymic[20];
    char patient_id[20];

    /* SESSION DATE/TIME */
    uint16_t session_year;
    uint8_t  session_month;
    uint8_t  session_day;
    uint8_t  session_hour;
    uint8_t  session_minute;
    uint8_t  session_second;

	    /* ACTIVE PROCEDURES */
    bool     active_warmup_enabled;
    bool     active_cooldown_enabled;
    bool     active_comfort_enabled;
    uint16_t active_warmup_step;
    uint16_t active_cooldown_step;
    uint16_t active_comfort_step;
    uint16_t active_comfort_bend_deviation;
    uint16_t active_comfort_exp_deviation;

    /* PASSIVE PROCEDURES */
    bool     passive_warmup_enabled;
    bool     passive_cooldown_enabled;
    bool     passive_comfort_enabled;
    uint16_t passive_warmup_step;
    uint16_t passive_cooldown_step;
    uint16_t passive_comfort_step;
    uint16_t passive_comfort_bend_deviation;
    uint16_t passive_comfort_exp_deviation;

    /* PASSIVE FUNCTIONS */
    bool     passive_extend_bend_enabled;
    bool     passive_extend_exp_enabled;
    uint16_t passive_extend_repeats;

    ControlMode mode;
}desk_state_t;

typedef struct  {
    RxState  state;
    uint8_t  form_id;
    uint8_t  len;
    uint8_t  crc;
    uint8_t  index;
    rx_packet_t packet;
}uart_rx_context_t;

#endif /* INC_ESP_H_ */
