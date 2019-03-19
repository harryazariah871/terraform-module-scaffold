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

variable "vnet01Name" {
    description = "Default VNet Name"
    default     =   "vnet01"
}