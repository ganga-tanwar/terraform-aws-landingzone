output "cloudtrail_arn" {
  value       = aws_cloudtrail.organization.arn
  description = "CloudTrail ARN."
}

output "guardduty_detector_id" {
  value       = aws_guardduty_detector.this.id
  description = "GuardDuty detector ID."
}
