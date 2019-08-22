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
       "arn:aws:ecr:${var.region}:${var.account_id}:repository/avrae/avrae-service"
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
     "Effect": "Allow",
     "Action": [
       "ecs:DescribeServices",
       "ecs:Update*"
     ],
     "Resource": [
       "*"
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

