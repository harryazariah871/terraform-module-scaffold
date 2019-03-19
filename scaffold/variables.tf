variable "region" {
    description = "Default Azure region"
    default     =   "northeurope"
}

variable "tags" {
    default     = {
        source  = "citadel"
        env     = "training"
    }
}