# Developer User
resource "aws_iam_user" "service_developer" {
  name = "${var.service}-${var.env}-developer"
}

# Developer DynamoDB Policy
resource "aws_iam_policy" "service_developer_policy" {
  name        = "${var.service}-${var.env}-developer-policy"
  path        = "/"
  description = "Used to give access for the developer user"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": [
                "${var.reports_dynamodb_table_arn}",
                "${var.reportnums_dynamodb_table_arn}"
            ]
        }
    ]
}
EOF
}

# Developer DynamoDB Policy Attachment
resource "aws_iam_user_policy_attachment" "service_developer_policy_attach" {
  user      = "${aws_iam_user.service_developer.name}"
  policy_arn = "${aws_iam_policy.service_developer_policy.arn}"
}
