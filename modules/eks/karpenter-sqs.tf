# ---------------------------------------------------------------------------
# Karpenter SQS queue
# Purpose: create the interruption queue that receives Karpenter event notifications.
# ---------------------------------------------------------------------------
resource "aws_sqs_queue" "karpenter_interruption" {
  count                     = var.use_karpenter && var.eks_mode != "auto" ? 1 : 0
  name                      = "${aws_eks_cluster.this.name}-karpenter-interruption-queue"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true
  tags = merge(local.common_tags, {
    "Name" = "${aws_eks_cluster.this.name}-karpenter-interruption-queue"
  })
}

# ---------------------------------------------------------------------------
# Karpenter queue policy
# Purpose: allow AWS event sources to publish interruption messages to the queue.
# ---------------------------------------------------------------------------
resource "aws_sqs_queue_policy" "karpenter_interruption" {
  count     = var.use_karpenter && var.eks_mode != "auto" ? 1 : 0
  queue_url = aws_sqs_queue.karpenter_interruption[0].url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["events.amazonaws.com", "sqs.amazonaws.com"]
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.karpenter_interruption[0].arn
      },
      {
        Sid      = "DenyHTTP"
        Effect   = "Deny"
        Action   = "sqs:*"
        Resource = aws_sqs_queue.karpenter_interruption[0].arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
        Principal = "*"
      }
    ]
  })
}