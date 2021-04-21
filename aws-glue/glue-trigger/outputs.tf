output "id" {
  description = "Glue trigger Name"
  value       = element(concat(aws_glue_trigger.this.*.id, [""]), 0)
}

output "arn" {
  description = "Glue trigger ARN"
  value       = element(concat(aws_glue_trigger.this.*.arn, [""]), 0)
}