variable "key_name" {
  description = "Amazon EC2 key pair that can be used to ssh to the created instance."
  type        = string
  default     = "ocean"
}

variable "key_location" {
  description = "The location to which the generated private key should be saved to."
  type        = string
  default     = "/tmp"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "ec2_name" {
  description = "Name to be used on all resources as prefix"
  type        = string
  default     = "nginx"
}

variable "ec2_user" {
  description = "User to access the EC2 instance with"
  type        = string
  default     = "ubuntu"
}

variable "ec2_instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 2
}

variable "ec2_instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.nano"
}

variable "ec2_assign_public_ip" {
  description = "Assign a public IP to created instances [True/False]"
  type        = bool
  default     = true
}

variable "load_balancer_internal" {
  description = "Load-Balancer internal/external [true/false]"
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "Load-Balancer type"
  type        = string
  default     = "application"
}

variable "run_ansible" {
  description = "Run Ansible Playbook"
  type        = bool
  default     = false
}

variable "ansible_host_key_checking" {
  description = "Ansible host key checking environment variable [True/False]"
  type        = string
  default     = "False"
}