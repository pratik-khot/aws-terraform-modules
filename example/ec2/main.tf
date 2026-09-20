module "ec2" {
  source        = "../../modules/ec2"
  ami_id        = var.ami_id
  subnet_id     = var.subnet_id
  sg_ids        = var.sg_ids
  app_name      = var.app_name
  env           = var.env
  instance_type = "t3.micro"

  root_volume_specs = {
    size                  = 20
    type                  = "gp3"
    delete_on_termination = true
  }

  data_volume_specs = {
    app_data = {
      size        = 50
      device_name = "/dev/sdf"
    }
  }
}
