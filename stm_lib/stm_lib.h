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

#define FORM5_CMD_IDLE  0u
#define FORM5_CMD_LEFT  1u
#define FORM5_CMD_RIGHT 2u

#define FORM9_CMD_STOP  0u
#define FORM9_CMD_START 1u

void fill_form3_initial();
void fill_form2_status();
void fill_form10_passive_status();
void fill_form11_manual();
void fill_form12_passive();
void send_packet(uint8_t formId, const uint8_t* payload, uint8_t len);
void send_form2_status();
void send_form3_initial();
void send_form10_passive_status();
void send_form11_manual();
void send_form12_passive();

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
    int16_t flexion_angle;
    int16_t extension_angle;
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
    int16_t flexion_angle;
    int16_t extension_angle;
    uint8_t status;
} form12_passive_settings_t;

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


typedef enum  {
    IDLE,
    MANUAL_LEFT,
    MANUAL_RIGHT,
    AUTO,
	PASSIVE
}ControlMode;

// FORMS
typedef struct  {
	form1_sync_time_t             f1;
	form4_set_target_angle_t      f4;
	form5_manual_cmd_t            f5;
    form6_update_manual_settings_t f6;
    form8_update_passive_settings_t f8;
    form9_passive_cmd_t           f9;
}forms_rx_t;

typedef struct  {
	form2_status_t          f2;
	    form3_initial_state_t   f3;
	    form10_passive_status_t f10;
	    form11_manual_settings_t f11;
	    form12_passive_settings_t f12;
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
	    int16_t     weight;
	    uint16_t    max_weight;
	    uint16_t    manual_speed;

	    int16_t     passive_flexion_angle;
	    int16_t     passive_extension_angle;
	    uint16_t    passive_cycles_target;
	    uint16_t    passive_duration_min;
	    bool        passive_stop_by_cycles;
	    bool        passive_stop_by_time;
	    uint16_t    speed;
	    uint16_t    passive_done_cycles;
	    uint32_t    passive_elapsed_seconds;

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
