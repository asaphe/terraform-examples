output "id" {
  description = "Glue Job Name"
  value       = element(concat(aws_glue_job.this.*.id, [""]), 0)
}

output "arn" {
  description = "Glue Job ARN"
  value       = element(concat(aws_glue_job.this.*.arn, [""]), 0)
}