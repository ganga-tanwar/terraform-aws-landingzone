moved {
  from = module.vpc.aws_vpc_endpoint.gateway["s3"]
  to   = module.endpoints.aws_vpc_endpoint.gateway["s3"]
}

moved {
  from = module.vpc.aws_vpc_endpoint.gateway["dynamodb"]
  to   = module.endpoints.aws_vpc_endpoint.gateway["dynamodb"]
}

moved {
  from = module.vpc.aws_vpc_endpoint.interface["ssm"]
  to   = module.endpoints.aws_vpc_endpoint.interface["ssm"]
}

moved {
  from = module.vpc.aws_vpc_endpoint.interface["ssmmessages"]
  to   = module.endpoints.aws_vpc_endpoint.interface["ssmmessages"]
}

moved {
  from = module.vpc.aws_vpc_endpoint.interface["ec2messages"]
  to   = module.endpoints.aws_vpc_endpoint.interface["ec2messages"]
}

moved {
  from = module.vpc.aws_vpc_endpoint.interface["logs"]
  to   = module.endpoints.aws_vpc_endpoint.interface["logs"]
}

moved {
  from = module.vpc.aws_vpc_endpoint.interface["monitoring"]
  to   = module.endpoints.aws_vpc_endpoint.interface["monitoring"]
}

moved {
  from = module.vpc.aws_vpc_endpoint.interface["kms"]
  to   = module.endpoints.aws_vpc_endpoint.interface["kms"]
}

moved {
  from = module.vpc.aws_vpc_endpoint.interface["secretsmanager"]
  to   = module.endpoints.aws_vpc_endpoint.interface["secretsmanager"]
}
