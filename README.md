# eng-aws-dataexfiltration

---
## Repository Structure & Details (Auto-generated)

### Scopo
Monitora e ispeziona il traffico TLS in AWS per prevenzione esfiltrazione, combinando listener SNI custom e infrastruttura di rete/firewall; fornisce telemetria SNI per threat hunting.

### Cartelle
- `sni-listener/`: `sni-listener.go` server TLS che logga SNI/handshake.
- `infra/`: Terraform per EC2/ALB o Network Firewall, TLS inspection, log, Lambda proxy.

### Script
- `sni-listener/sni-listener.go`: server TLS per logging SNI.

### Workflow
Nessuno.

### Note
Listener critico; attenzione a certificati, TLS inspection e rete.
