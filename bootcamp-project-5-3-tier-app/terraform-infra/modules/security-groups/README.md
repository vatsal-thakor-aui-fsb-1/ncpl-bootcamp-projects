# Security Groups Module

This module creates all security groups for the 3-tier Goal Tracker application with proper network isolation.

## Security Architecture

### Traffic Flow
```
Internet → ALB SG (80/443) → Frontend SG (3000) → Backend SG (8080) → RDS SG (5432)
                    ↓
                Bastion SG (22) → Frontend/Backend (SSH)
```

### Security Groups

1. **ALB Security Group**
   - Ingress: HTTP (80) and HTTPS (443) from internet
   - Egress: All traffic
   - Purpose: Public-facing load balancer

2. **Bastion Security Group**
   - Ingress: SSH (22) from specified IPs only
   - Egress: All traffic
   - Purpose: Secure SSH access point

3. **Frontend Security Group**
   - Ingress: Port 3000 from ALB SG, SSH from Bastion SG
   - Egress: All traffic
   - Purpose: Node.js frontend application servers

4. **Backend Security Group**
   - Ingress: Port 8080 from Frontend SG, SSH from Bastion SG
   - Egress: All traffic
   - Purpose: Go backend API servers

5. **RDS Security Group**
   - Ingress: PostgreSQL (5432) from Backend SG only
   - Egress: None (completely isolated)
   - Purpose: Database isolation