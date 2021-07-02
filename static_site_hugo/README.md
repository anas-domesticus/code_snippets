### Terraform module to deploy a static website on S3 + Cloudfront  

Uses a free AWS certificate for TLS in its current form, you can either put this behind another CDN such as Cloudflare or add a certificate to ACM & use that from the Cloudfront resource.