module "main" {
  source		= "./_main"

  account_id		= var.account_id		# => 'data.aws_caller_identity.current.account_id'
  availability_zones	= var.availability_zones	# => 'data.aws_availability_zones.available.names''
  region		= var.region			# => 'data.aws_region.current.name'
}
