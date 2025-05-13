variable "table_name" {
  type = string
}
variable "attributes" {
    type = list(map(string))
}
variable "partition_key" {
  type = string
}
variable "sort_key" {
  type = string
}
variable "secondary_index" {
  type = bool
  default = false
}
variable "secondary_partitan_key" {
  type = string
  default = ""
}
variable "secondary_sort_key" {
  type = string
  default = ""
}