output "id" {
  description = "Glue DB Name"
  value       = element(concat(aws_glue_catalog_database.this.*.id, [""]), 0)
}

output "arn" {
  description = "Glue DB ARN"
  value       = element(concat(aws_glue_catalog_database.this.*.arn, [""]), 0)
}