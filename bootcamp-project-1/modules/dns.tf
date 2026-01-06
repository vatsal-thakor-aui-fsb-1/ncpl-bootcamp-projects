# Retrieve the existing Route 53 Hosted Zone ID using a data source
data "aws_route53_zone" "existing_zone" {
  # Replace with your actual domain name
  name = "vatsal-thakor.com" 
}

# Create an A record that points to the ALB using an alias record
resource "aws_route53_record" "www_record" {
  # The ID of your existing hosted zone
  zone_id = data.aws_route53_zone.existing_zone.zone_id 
  
  # The name of the record (e.g., "www" for www.example.com, or "" for the zone apex)
  name    = var.R53_www_record_name 
  type    = "A"

  # Use the alias block to point to the ALB
  alias {
    # The DNS name of the ALB
    name    = aws_lb.btcmp-project-1.dns_name 
    # The Route 53 Hosted Zone ID for the ALB. This is an AWS constant per region for ALBs.
    # Terraform can get this from the data source.
    zone_id = aws_lb.btcmp-project-1.zone_id 
    # Evaluate target health is usually true for ALB aliases
    evaluate_target_health = true
  }
}