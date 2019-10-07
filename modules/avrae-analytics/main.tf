locals {
  common_tags = {
    Component   = var.service
    Environment = var.env
    Team        = var.group
  }
}

# Analytics: dbrestore s3 bucket
resource "aws_s3_bucket" "analytics_dbrestore" {
  bucket = "${var.s3_prefix}-${var.region}-${var.service}-${var.env}-dbrestore"
  acl    = "private"

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.service}-dbrestore"
    },
  )
}

# ==== DMS ====

# DMS access to S3 bucket
resource "aws_iam_role" "analytics_dms_role" {
  name = "${var.service}-${var.env}-dms-iam"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "s3.amazonaws.com",
          "dms.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.common_name} DMS Role"
    },
  )
}

resource "aws_iam_policy" "analytics_dms_policy" {
  name = "${var.service}-${var.env}-dms-policy"
  path        = "/"
  description = "Used to give S3 access to DMS"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:PutObjectTagging"
            ],
            "Resource": [
                "${aws_s3_bucket.analytics_dbrestore.arn}*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.analytics_dbrestore.arn}*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "analytics_dms_attachment" {
  role       = aws_iam_role.analytics_dms_role.name
  policy_arn = aws_iam_policy.analytics_dms_policy.arn
}

# DMS Access to MongoDB
resource "aws_security_group" "analytics_dms_access" {
  name        = "${var.service}-${var.env}-dms-access"
  description = "Security group attached to Avrae DMS"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.service}-${var.env} DMS Access"
    env  = var.env
  }
}

resource "aws_security_group_rule" "analytics_egress" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.analytics_dms_access.id
}

# ---- DMS Scheduled Job ----
# User and policy attachment
resource "aws_iam_user" "dms_cron_user" {
  name = "${var.service}-${var.env}-dms"
}

resource "aws_iam_access_key" "dms_cron" {
  user = aws_iam_user.dms_cron_user.name
}

resource "aws_iam_policy" "dms_cron_policy" {
  name        = "${var.service}-${var.env}-dms-cron"
  path        = "/"
  description = "Used to give access for the DMS cron user"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "dms:*",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "dms_cron_policy_attach" {
  user = aws_iam_user.dms_cron_user.name
  policy_arn = aws_iam_policy.dms_cron_policy.arn
}



# ==== GLUE ====

# Glue access to S3
resource "aws_iam_role" "analytics_glue_role" {
  name = "AWSGlueServiceRole-${var.service}-${var.env}-crawler"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "glue.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY

  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.common_name} Glue Role"
    },
  )
}

resource "aws_iam_policy" "analytics_glue_policy" {
  name = "${var.service}-${var.env}-glue-policy"
  path        = "/"
  description = "Used to give S3 access to Glue"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.analytics_dbrestore.arn}*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "analytics_glue_s3_attachment" {
  role       = aws_iam_role.analytics_glue_role.name
  policy_arn = aws_iam_policy.analytics_glue_policy.arn
}

resource "aws_iam_role_policy_attachment" "analytics_glue_service_attachment" {
  role       = aws_iam_role.analytics_glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
