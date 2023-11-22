#!/bin/bash
# 获取所有 VM 的名称和资源组
vms=$(az vm list --query "[].{name: name, resourceGroup: resourceGroup}" -o tsv)

# 遍历每个 VM
while read -r name resourceGroup;
do
    #echo "在 $name 上执行脚本"

    download_info=$(az vm run-command invoke \
      --resource-group $resourceGroup \
      --name $name \
      --command-id RunShellScript \
      --scripts "curl -o /home/azureuser/find_vmess.sh https://raw.githubusercontent.com/EachenL/find_vmess/main/find_vmess.sh")



    # 使用自定义脚本扩展执行脚本

    script_exc_info=$(az vm run-command invoke \
      --resource-group $resourceGroup \
      --name $name \
      --command-id RunShellScript \
      --scripts "sh /home/azureuser/find_vmess.sh")

    #echo $script_exc_info
    vmess_link=$(echo $script_exc_info | jq -r '.value[0].message' | awk '/vmess:\/\//{print $0; exit}')

    #echo $vmess_link
    vmesses_link+="${vmess_link}"$'\n'

done <<< "$vms"
echo "$vmesses_link"