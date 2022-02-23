data "aws_iam_policy_document" "cw_logs" {
  statement {
    sid    = "CloudwatchLogsAccess"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cw_logs" {
  name   = "${var.cluster_name}-cw-logs-access"
  policy = data.aws_iam_policy_document.cw_logs.json
}

resource "aws_iam_role_policy_attachment" "cw_logs" {
  policy_arn = aws_iam_policy.cw_logs.arn
  role       = aws_iam_role.worker.name
}