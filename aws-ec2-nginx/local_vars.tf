locals {
  private_key_path = "${var.key_location}/${var.key_name}"
}

resource "random_id" "suffix" {
  byte_length = 4
}