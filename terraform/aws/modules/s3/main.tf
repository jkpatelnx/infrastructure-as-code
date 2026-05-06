
resource "aws_s3_bucket" "my_bucket" {
  count = var.s3_bucket_count
  bucket = "${var.env}-${var.s3_bucket_name}-${count.index + 1}"

  tags = {
    Name = "${var.env}-${var.s3_bucket_name}-${count.index + 1}"
    Environment = var.env 
  }
}