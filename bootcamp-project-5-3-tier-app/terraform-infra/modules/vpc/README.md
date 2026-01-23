# VPC Module

This module creates a complete 3-tier VPC infrastructure for the Goal Tracker application.

## Architecture

### Subnets
- **Public Subnets (Web Tier)**: Internet-facing resources (ALB, Bastion, NAT Gateways)
- **Frontend Subnets (App Tier)**: Node.js frontend application servers
- **Backend Subnets (App Tier)**: Go backend API servers
- **Database Subnets (Data Tier)**: PostgreSQL RDS instances (completely isolated)

### Routing
- Public subnets route to Internet Gateway
- Frontend/Backend subnets route to NAT Gateway for outbound internet access
- Database subnets have no internet access (isolated)