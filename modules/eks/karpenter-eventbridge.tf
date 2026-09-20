# ---------------------------------------------------------------------------
# Karpenter EventBridge integration
# Purpose: connect EC2 interruption and health events to the Karpenter SQS queue.
# ---------------------------------------------------------------------------
# ============================================================================
#
# Purpose:
#   EventBridge rules that detect EC2 Spot interruptions, AWS Health events,
#   EC2 rebalance recommendations, and EC2 instance state changes, and send
#   those events to the Karpenter SQS interruption queue.
#
#   This enables Karpenter to gracefully cordon, drain, and replace Spot nodes.
#
# Requirements:
#   - SQS queue must exist (aws_sqs_queue.karpenter_interruption)
#   - IAM policy for Karpenter controller must include sqs:* permissions
#
# Reference:
#   AWS Official Karpenter template:
#   https://github.com/aws/karpenter/
# ============================================================================


# ----------------------------------------------------------------------------
# AWS Health Events → SQS
# ----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "karpenter_health_event" {
  count       = var.use_karpenter && var.eks_mode != "auto" ? 1 : 0
  name        = "${aws_eks_cluster.this.name}-k-health"
  description = "AWS Health Event → Karpenter Interruption Queue"

  event_pattern = jsonencode({
    source        = ["aws.health"]
    "detail-type" = ["AWS Health Event"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "karpenter_health_target" {
  count     = var.use_karpenter && var.eks_mode != "auto" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.karpenter_health_event[0].name
  target_id = "KarpenterHealthTarget"
  arn       = aws_sqs_queue.karpenter_interruption[0].arn
}

# ----------------------------------------------------------------------------
# EC2 Spot Interruption Warning → SQS
# ----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "karpenter_spot_interrupt" {
  name        = "${aws_eks_cluster.this.name}-k-spot"
  count       = var.use_karpenter && var.eks_mode != "auto" ? 1 : 0
  description = "EC2 Spot Interruption Warning → Karpenter SQS Queue"

  event_pattern = jsonencode({
    source        = ["aws.ec2"]
    "detail-type" = ["EC2 Spot Instance Interruption Warning"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "karpenter_spot_target" {
  count     = var.use_karpenter && var.eks_mode != "auto" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.karpenter_spot_interrupt[0].name
  target_id = "KarpenterSpotTarget"
  arn       = aws_sqs_queue.karpenter_interruption[0].arn
}

# ----------------------------------------------------------------------------
# EC2 Instance Rebalance Recommendation → SQS
# ----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "karpenter_rebalance" {
  name        = "${aws_eks_cluster.this.name}-k-rebal"
  count       = var.use_karpenter && var.eks_mode != "auto" ? 1 : 0
  description = "EC2 Instance Rebalance Recommendation → Karpenter SQS Queue"

  event_pattern = jsonencode({
    source        = ["aws.ec2"]
    "detail-type" = ["EC2 Instance Rebalance Recommendation"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "karpenter_rebalance_target" {
  count     = var.use_karpenter && var.eks_mode != "auto" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.karpenter_rebalance[0].name
  target_id = "KarpenterRebalanceTarget"
  arn       = aws_sqs_queue.karpenter_interruption[0].arn
}

# ----------------------------------------------------------------------------
# EC2 Instance State-change Notification → SQS
# ----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "karpenter_instance_state" {
  name        = "${aws_eks_cluster.this.name}-k-state"
  count       = var.use_karpenter && var.eks_mode != "auto" ? 1 : 0
  description = "EC2 Instance State Change Notification → Karpenter SQS Queue"

  event_pattern = jsonencode({
    source        = ["aws.ec2"]
    "detail-type" = ["EC2 Instance State-change Notification"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "karpenter_instance_state_target" {
  count     = var.use_karpenter && var.eks_mode != "auto" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.karpenter_instance_state[0].name
  target_id = "KarpenterStateTarget"
  arn       = aws_sqs_queue.karpenter_interruption[0].arn
}