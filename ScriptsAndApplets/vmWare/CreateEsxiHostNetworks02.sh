#!/bin/sh

##Creates port groups on a vSwitch. Then tags them for the vLan that matches the number used in the name of the port group.
##Example: port_groups="Net-100 Net-200" would create port groups Net-100 and Net-200 tagged for vLan 100 and 200 respectively

# Define the port groups as a space-separated string
port_groups="pg-01 pg-02 pg-03 etc etc"

#Define vSwitch name
vSwitchName="<NameOfvSwitch"

# Loop through each port group and add it to the vSwitch
for pg in $port_groups; do
  # Extract VLAN ID from the port group name
  vlan_id=$(echo "$pg" | grep -o -E '[0-9]+')

  # Add the port group to vSwitch0
  echo "Creating Port Group "$pg
  esxcli network vswitch standard portgroup add --vswitch-name="$vSwitchName" --portgroup-name="$pg"

  # Set the VLAN ID for the port group
  echo "Tagging Port Group "$pg" with vLan "$vlan_id
  esxcli network vswitch standard portgroup set --portgroup-name="$pg" --vlan-id="$vlan_id"
done

echo "All port groups have been added to "$vSwitchName
