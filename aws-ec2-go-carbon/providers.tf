provider "aws" {
  profile                = local.environment
  region                 = module.common_config.outputs.aws_region
  skip_region_validation = true
}