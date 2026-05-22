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

#define FORM1_ID 1u
#define FORM2_ID 2u
#define FORM3_ID 3u
#define FORM4_ID 4u
#define FORM5_ID 5u
#define FORM6_ID 6u
#define FORM7_ID 7u
#define FORM8_ID 8u
#define FORM9_ID 9u
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

#define FORM5_CMD_IDLE  0u
#define FORM5_CMD_LEFT  1u
#define FORM5_CMD_RIGHT 2u

#define FORM9_CMD_STOP  0u
#define FORM9_CMD_START 1u

#define FORM16_CMD_STOP   0u
#define FORM16_CMD_START  1u
#define FORM16_CMD_PAUSE  2u

void fill_form3_initial();
void fill_form2_status();
void fill_form10_passive_status(bool trn);
void fill_form11_manual();
void fill_form12_passive();
void fill_form17_active();
void fill_form20_system();
void send_packet(uint8_t formId, const uint8_t* payload, uint8_t len);
void send_form2_status();
void send_form3_initial();
void send_form10_passive_status(bool trn);
void send_form11_manual();
void send_form12_passive();
void send_form17_active();
void send_form20_system();

extern bool connected_flag;

#pragma pack(push, 1)
typedef struct {
    uint32_t timestamp;
} form1_sync_time_t;

typedef struct {
    uint32_t timestamp;
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
} form6_update_manual_settings_t;

typedef struct {
    uint16_t cycles;
    uint16_t duration_min;
    uint8_t stop_by_cycles;
    uint8_t stop_by_time;
    uint16_t speed;
    uint16_t max_load;
    int16_t bend_angle;
    int16_t exp_angle;
} form8_update_passive_settings_t;

typedef struct {
    uint8_t cmd;
} form9_passive_cmd_t;

typedef struct {
    uint16_t remaining_seconds;
    uint16_t done_cycles;
    uint8_t status;
} form10_passive_status_t;

typedef struct {
    uint16_t max_load;
    uint16_t manual_speed;
    uint8_t status;
} form11_manual_settings_t;

typedef struct {
    uint16_t cycles;
    uint16_t duration_min;
    uint8_t stop_by_cycles;
    uint8_t stop_by_time;
    uint16_t speed;
    uint16_t max_load;
    int16_t bend_angle;
    int16_t exp_angle;
    uint8_t status;
} form12_passive_settings_t;

typedef struct {
    uint16_t cycles;
    uint16_t duration_min;
    uint8_t stop_by_cycles;
    uint8_t stop_by_time;
    uint16_t speed;
    uint16_t max_load;
    int16_t bend_angle;
    int16_t exp_angle;
    int16_t bend_assist_angle;
    int16_t exp_assist_angle;
    int16_t bend_load;
    int16_t exp_load;
} form15_update_active_settings_t;

typedef struct {
    uint8_t cmd;
} form16_active_cmd_t;

typedef struct {
    uint16_t cycles;
    uint16_t duration_min;
    uint8_t stop_by_cycles;
    uint8_t stop_by_time;
    uint16_t speed;
    uint16_t max_load;
    int16_t bend_angle;
    int16_t exp_angle;
    int16_t bend_assist_angle;
    int16_t exp_assist_angle;
    int16_t bend_load;
    int16_t exp_load;
    uint8_t status;
} form17_active_settings_t;

typedef struct {
    uint16_t max_load;
    uint16_t speed;
    uint16_t manual_speed;
    uint16_t cycles;
    uint16_t duration_min;

    uint8_t  stop_by_cycles;
    uint8_t  stop_by_time;

    int16_t  bend_angle;
    int16_t  exp_angle;

    int16_t  active_bend_assist_angle;
    int16_t  active_exp_assist_angle;
    int16_t  active_bend_load;
    int16_t  active_exp_load;

    uint8_t  status;
} form20_system_settings_t;

typedef struct {
    uint16_t max_load;
    uint16_t speed;
    uint16_t manual_speed;
    uint16_t cycles;
    uint16_t duration_min;

    uint8_t  stop_by_cycles;
    uint8_t  stop_by_time;

    int16_t  bend_angle;
    int16_t  exp_angle;

    int16_t  active_bend_assist_angle;
    int16_t  active_exp_assist_angle;
    int16_t  active_bend_load;
    int16_t  active_exp_load;
} form21_update_system_settings_t;

#pragma pack(pop)

#define FORM2_LEN ((uint8_t)sizeof(form2_status_t))
#define FORM1_LEN ((uint8_t)sizeof(form1_sync_time_t))
#define FORM7_LEN 0u
#define FORM6_LEN ((uint8_t)sizeof(form6_update_manual_settings_t))
#define FORM5_LEN ((uint8_t)sizeof(form5_manual_cmd_t))
#define FORM4_LEN ((uint8_t)sizeof(form4_set_target_angle_t))
#define FORM3_LEN ((uint8_t)sizeof(form3_initial_state_t))
#define FORM8_LEN ((uint8_t)sizeof(form8_update_passive_settings_t))
#define FORM9_LEN ((uint8_t)sizeof(form9_passive_cmd_t))
#define FORM10_LEN ((uint8_t)sizeof(form10_passive_status_t))
#define FORM11_LEN ((uint8_t)sizeof(form11_manual_settings_t))
#define FORM12_LEN ((uint8_t)sizeof(form12_passive_settings_t))
#define FORM13_LEN 0u
#define FORM14_LEN 0u
#define FORM15_LEN ((uint8_t)sizeof(form15_update_active_settings_t))
#define FORM16_LEN ((uint8_t)sizeof(form16_active_cmd_t))
#define FORM17_LEN ((uint8_t)sizeof(form17_active_settings_t))
#define FORM18_LEN 0u
#define FORM19_LEN 0u
#define FORM20_LEN ((uint8_t)sizeof(form20_system_settings_t))
#define FORM21_LEN ((uint8_t)sizeof(form21_update_system_settings_t))


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
    form1_sync_time_t                f1;
    form4_set_target_angle_t         f4;
    form5_manual_cmd_t               f5;
    form6_update_manual_settings_t   f6;
    form8_update_passive_settings_t  f8;
    form9_passive_cmd_t              f9;
    form15_update_active_settings_t  f15;
    form16_active_cmd_t              f16;
}forms_rx_t;

typedef struct  {
    form2_status_t            f2;
    form3_initial_state_t     f3;
    form10_passive_status_t   f10;
    form11_manual_settings_t  f11;
    form12_passive_settings_t f12;
    form17_active_settings_t  f17;
    form20_system_settings_t  f20;
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
    uint8_t payload[64];
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
    float       angle;
    float       target_angle;
    int16_t     load;
    uint16_t    max_load;
    uint16_t    manual_speed;

    int16_t     bend_angle;
    int16_t     exp_angle;
    uint16_t    cycles_target;
    uint16_t    duration_min;
    bool        stop_by_cycles;
    bool        stop_by_time;
    uint16_t    speed;
    uint16_t    done_cycles;
    uint32_t    elapsed_seconds;
    bool        paused;

    int16_t     active_bend_assist_angle;
    int16_t     active_exp_assist_angle;
    int16_t     active_bend_load;
    int16_t     active_exp_load;

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
