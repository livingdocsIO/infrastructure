variable "s3_images_bucket" {
  default = "livingdocs-service-images-production"
}

variable "s3_files_bucket" {
  default = "livingdocs-service-files-production"
}

variable "s3_designs_bucket" {
  default = "livingdocs-service-designs-production"
}

resource "aws_s3_bucket" "images" {
  bucket = "${var.s3_images_bucket}"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 86400
  }
}

resource "aws_s3_bucket" "designs" {
  bucket = "${var.s3_designs_bucket}"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 86400
  }
}

resource "aws_s3_bucket" "files" {
  bucket = "${var.s3_files_bucket}"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 86400
  }
}

resource "aws_iam_user" "service" {
  name = "service-production"
}

resource "aws_iam_user" "service_imgix" {
  name = "service-production-imgix"
}

resource "aws_iam_access_key" "service" {
  user = "${aws_iam_user.service.name}"
}

resource "aws_iam_access_key" "imgix" {
  user = "${aws_iam_user.service_imgix.name}"
}

resource "aws_iam_policy" "s3" {
  name = "service-production-s3-access"
  description = "S3 read-write access policy for the production service"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["${aws_s3_bucket.images.arn}/*", "${aws_s3_bucket.images.arn}", "${aws_s3_bucket.designs.arn}/*", "${aws_s3_bucket.designs.arn}", "${aws_s3_bucket.files.arn}/*", "${aws_s3_bucket.files.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "service" {
    user       = "${aws_iam_user.service.name}"
    policy_arn = "${aws_iam_policy.s3.arn}"
}

resource "aws_iam_user_policy_attachment" "service_imgix" {
    user       = "${aws_iam_user.service_imgix.name}"
    policy_arn = "${aws_iam_policy.s3.arn}"
}

output "s3_images_bucket" {
  value = "${var.s3_images_bucket}"
}

output "s3_files_bucket" {
  value = "${var.s3_files_bucket}"
}

output "s3_designs_bucket" {
  value = "${var.s3_designs_bucket}"
}

output "s3_access_key" {
  value = "${aws_iam_access_key.service.id}"
}

output "s3_access_secret" {
  value = "${aws_iam_access_key.service.secret}"
}


output "s3_access_key_imgix" {
  value = "${aws_iam_access_key.imgix.id}"
}

output "s3_access_secret_imgix" {
  value = "${aws_iam_access_key.imgix.secret}"
}
