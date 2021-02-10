##Deploy User and policy attachment
resource "aws_iam_user" "service_deploy" {
  name = "${var.service}-${var.env}-deploy"
}

resource "aws_iam_access_key" "service_deploy" {
  user = aws_iam_user.service_deploy.name
}

resource "aws_iam_policy" "service_deploy_policy" {
  name        = "${var.service}-${var.env}-deploy-policy"
  path        = "/"
  description = "Used to give access for the deploy user"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*"
      ],
      "Resource": [
        "arn:aws:ecr:${var.region}:${var.account_id}:repository/avrae/taine",
        "arn:aws:ecr:${var.region}:${var.account_id}:repository/avrae/avrae-bot",
        "arn:aws:ecr:${var.region}:${var.account_id}:repository/avrae/avrae-service",
        "arn:aws:ecr:${var.region}:${var.account_id}:repository/avrae/avrae-io"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": [
        "*"
      ]
    },
    {
       "Sid":"PassRolesInTaskDefinition",
       "Effect":"Allow",
       "Action":[
          "iam:PassRole"
       ],
       "Resource":[
          "arn:aws:iam::${var.account_id}:role/taine-live-ecs-role",
          "arn:aws:iam::${var.account_id}:role/avrae-bot-live-ecs-role",
          "arn:aws:iam::${var.account_id}:role/avrae-bot-nightly-live-ecs-role",
          "arn:aws:iam::${var.account_id}:role/avrae-service-live-ecs-role",
          "arn:aws:iam::${var.account_id}:role/avrae-io-live-ecs-role"
       ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ecs:Update*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectTagging",
        "s3:PutObjectAcl",
        "s3:DeleteObject",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::media.avrae.io*",
        "arn:aws:s3:::${var.s3_prefix}-${var.region}-${var.service}-${var.env}*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode"
      ],
      "Resource": [
        "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.service}-${var.env}*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "service_deploy_policy_attach" {
  user = aws_iam_user.service_deploy.name
  policy_arn = aws_iam_policy.service_deploy_policy.arn
}

