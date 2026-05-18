# provider "aws" {
#   region = var.primary_region

#   default_tags {
#     tags = var.tags
#   }
# }
resource "local_file" "hello" {
  content  = "hello world"
  filename = "hello.txt"
}