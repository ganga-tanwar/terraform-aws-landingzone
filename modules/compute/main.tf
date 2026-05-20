resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_security_group" "windows" {
  name_prefix = "${var.name_prefix}-windows-"
  description = "Windows and SQL migration security group"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name_prefix}-windows-sg" })

  dynamic "ingress" {
    for_each = length(var.allowed_management_cidrs) == 0 ? [] : [1]
    content {
      description = "Temporary RDP for migration"
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = var.allowed_management_cidrs
    }
  }

  egress {
    description = "HTTPS egress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  for_each = var.instances

  ami                         = var.ami_id
  instance_type               = each.value.instance_type
  subnet_id                   = var.subnet_ids[each.value.subnet_index]
  vpc_security_group_ids      = concat([aws_security_group.windows.id], var.security_group_ids)
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  key_name                    = var.key_name
  associate_public_ip_address = false
  monitoring                  = true
  ebs_optimized               = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = each.value.os_volume_size
    tags        = merge(var.tags, { Name = "${var.name_prefix}-${each.key}-os" })
  }

  tags = merge(var.tags, {
    Name         = "${var.name_prefix}-${each.key}"
    WorkloadType = each.value.workload_type
  })
}

resource "aws_ebs_volume" "data" {
  for_each = {
    for name, instance in var.instances : name => instance
    if instance.data_volume_size > 0
  }

  availability_zone = aws_instance.this[each.key].availability_zone
  encrypted         = true
  size              = each.value.data_volume_size
  type              = each.value.workload_type == "sql" ? "io2" : "gp3"
  iops              = each.value.workload_type == "sql" ? each.value.data_volume_iops : null
  throughput        = each.value.workload_type == "sql" ? null : each.value.data_volume_throughput

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}-data"
  })
}

resource "aws_volume_attachment" "data" {
  for_each = aws_ebs_volume.data

  device_name = "xvdf"
  volume_id   = each.value.id
  instance_id = aws_instance.this[each.key].id
}
