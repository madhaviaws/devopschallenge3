resource "null_resource" "configure-consul-ips" {
provisioner "chef" {
    attributes_json = <<EOF
      {
        "key": "value",
        "app": {
          "cluster1": {
            "nodes": [
              "webserver1"
            ]
          }
        }
      }
    EOF

    environment     = "_default"
    client_options  = ["chef_license 'accept'"]
    run_list        = ["mytomcat::default"]
    node_name       = "webserver1"
    server_url      = "https://manage.chef.io/organizations/devopsapraws"
    recreate_client = true
    user_name       = "madhaviaws"
    user_key        = "${file("./madhaviaws.pem")}"
    # If you have a self signed cert on your chef server change this to :verify_none
    ssl_verify_mode = ":verify_peer"
	}
	connection {
        type                = "ssh"
        user                = "ubuntu"
        private_key         = file("./task.pem")
        host                = data.aws_instance.foo1.public_ip
    }
  }