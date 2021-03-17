provider "aws" {
  version                 = "~> 3.22.0"
  assume_role {
    role_arn     = "<fixme>"
    session_name = "terraform"
  }
}
data aws_caller_identity current {}
data aws_region current {}

resource "aws_s3_bucket" "code" {
  bucket = "remote-bash-${data.aws_caller_identity.current.id}-${data.aws_region.current.name}"
}

data "archive_file" "lambda_zip" {
  type = "zip"
  output_path = "${path.module}/code.zip"
  source_file = "${path.module}/lambda_function.py"
}

resource "aws_s3_bucket_object" "lambda_code" {
  key = "code.zip"
  bucket = aws_s3_bucket.code.id
  source = data.archive_file.lambda_zip.output_path
  etag = filemd5(data.archive_file.lambda_zip.output_path)
}

data aws_iam_policy_document assume_role {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "basic" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name = "remote-bash"
}

resource aws_iam_role_policy_attachment basic {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.basic.name
}

resource aws_lambda_function remote_bash {
  function_name = "remote_bash"
  handler = "lambda_function.lambda_handler"
  role = aws_iam_role.basic.arn
  runtime = "python3.8"
  memory_size = 256
  timeout = 10
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  s3_bucket        = aws_s3_bucket_object.lambda_code.bucket
  s3_key           = aws_s3_bucket_object.lambda_code.id
}

output "unified" {
  value = {
    lambda = {
      function_name = aws_lambda_function.remote_bash.function_name
      arn = aws_lambda_function.remote_bash.arn
    }
  }
}