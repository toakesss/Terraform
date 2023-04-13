terraform {
  required_providers {
    genesyscloud = {
      source = "mypurecloud/genesyscloud"
    }
  }
}

provider "genesyscloud" {
  sdk_debug = true
}


resource "genesyscloud_user" "sf_johnsmith" {
  email           = "TOjohn.smoke@simplefinancial.com"
  name            = "John Smoke"
  password        = "b@Zinga1972"
  state           = "active"
  department      = "IRA"
  title           = "Agent"
  acd_auto_answer = true
  addresses {

    phone_numbers {
      number     = "+19205551212"
      media_type = "PHONE"
      type       = "MOBILE"
    }
  }
  employer_info {
    official_name = "John Smoke"
    employee_id   = "12345"
    employee_type = "Full-time"
    date_hire     = "2021-03-18"
  }
}

resource "genesyscloud_user" "sf_janesmith" {
  email           = "TOjane.smoke@simplefinancial.com"
  name            = "Jane Smoke"
  password        = "b@Zinga1972"
  state           = "active"
  department      = "IRA"
  title           = "Agent"
  acd_auto_answer = true
  addresses {

    phone_numbers {
      number     = "+19205551212"
      media_type = "PHONE"
      type       = "MOBILE"
    }
  }
  employer_info {
    official_name = "Jane Smoke"
    employee_id   = "67890"
    employee_type = "Full-time"
    date_hire     = "2021-03-18"
  }
}

resource "genesyscloud_routing_queue" "queue_ira" {
  name                     = "TO Simple Financial IRA queue"
  description              = "Simple Financial IRA questions and answers"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300000
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true

  members {
    user_id  = genesyscloud_user.sf_johnsmith.id
    ring_num = 1
  }
}

resource "genesyscloud_routing_queue" "queue_K401" {
  name                     = "TO Simple Financial 401K queue"
  description              = "Simple Financial 401K questions and answers"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300000
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true
  members {
    user_id  = genesyscloud_user.sf_johnsmith.id
    ring_num = 1
  }

  members {
    user_id  = genesyscloud_user.sf_janesmith.id
    ring_num = 1
  }
}

resource "genesyscloud_flow" "mysimpleflow" {
  filepath = "./SimpleFinancialIvr-Trevor_v2-0.yaml"
  file_content_hash = filesha256("./SimpleFinancialIvr-Trevor_v2-0.yaml") 
}


variable "my_ivr_did_number" {
  type = string
  description = "phone number used for simple IVR"
}


resource "genesyscloud_telephony_providers_edges_did_pool" "mygcv_number" {
  start_phone_number = var.my_ivr_did_number
  end_phone_number   = var.my_ivr_did_number
  description        = "GCV Number for inbound calls"
  comments           = "Additional comments"
}

resource "genesyscloud_architect_ivr" "mysimple_ivr" {
  name               = "A simple IVR"
  description        = "A sample IVR configuration"
  dnis               = [var.my_ivr_did_number, var.my_ivr_did_number]
  open_hours_flow_id = genesyscloud_flow.mysimpleflow.id
  depends_on         = [
    genesyscloud_flow.mysimpleflow,
    genesyscloud_telephony_providers_edges_did_pool.mygcv_number
  ]
}

