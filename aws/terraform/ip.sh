export IP=$(terraform show -json | jq .values.root_module.resources[0].values.public_ip | sed 's/\"//g')
echo $IP
