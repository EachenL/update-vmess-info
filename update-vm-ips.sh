#!/bin/bash
ips=$(az network public-ip list --query "[?ipConfiguration==null].[name,resourceGroup]" -o tsv)

while IFS=$'\t' read -r ip_name resource_group; do
    az network public-ip delete --name "$ip_name" --resource-group "$resource_group"
done <<< "$ips"

# 获取所有 VM 的名称和资源组
vms=$(az vm list --query "[].{name: name, resourceGroup: resourceGroup}" -o tsv)

# 循环遍历每个 VM
while read -r name resourceGroup; do
    echo "处理虚拟机 $name 在资源组 $resourceGroup"

    # 获取网络接口名称
    nic_name=$(az vm show --resource-group $resourceGroup --name $name --query "networkProfile.networkInterfaces[0].id" -o tsv | awk -F '/' '{print $NF}')

    # 删除旧的公共 IP 地址关联
    ip_config_name=$(az network nic show --resource-group $resourceGroup --name $nic_name --query "ipConfigurations[0].name" -o tsv)
    az network nic ip-config update --name $ip_config_name --nic-name $nic_name --resource-group $resourceGroup --remove PublicIpAddress

    # 创建新的公共 IP 地址
    new_ip_name="${name}-publicIP-$(date +"%Y%m%d%H%M")"
    az network public-ip create --resource-group $resourceGroup --name $new_ip_name --allocation-method Static

    # 将新的公共 IP 地址关联到虚拟机
    az network nic ip-config update --name $ip_config_name --nic-name $nic_name --resource-group $resourceGroup --public-ip-address $new_ip_name

    echo "虚拟机 $name 的公共IP已更新为 $new_ip_name"
done <<< "$vms"

