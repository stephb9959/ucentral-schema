{%
if (!interface.ipv4 || !interface.ipv4.subnet || interface.ipv4.addressing != 'static' ) {
        warn("A VXLAN tunnel can only be created with a valid and static ivp4 address");
        return;
}
if (!interface.vlan || !interface.vlan.id ) {
        warn("A VXLAN tunnel can only be created with a valid and static ivp4 address");
        return;
}
if (!interface.tunnel.peer_address) {
        warn("A VXLAN tunnel requires a valid peer-address");
        return;
}
%}

# VXLAN Configuration
set network.{{ name }}_vx=interface
set network.{{ name }}_vx.proto=vxlan
set network.{{ name }}_vx.peeraddr={{ s(interface.tunnel.peer_address) }}
set network.{{ name }}_vx.port={{ interface.tunnel.peer_port }}
set network.{{ name }}_vx.vid={{ interface.vlan.id }}

set network.{{ name }}_vx_l2=interface
set network.{{ name }}_vx_l2.proto='static'
set network.{{ name }}_vx_l2.ifname='@{{ name }}_vx'
set network.{{ name }}_vx_l2.ipaddr={{ ipcalc.generate_prefix(state, interface.ipv4.subnet) }}
set network.{{ name }}_vx_l2.layer=2
set network.{{ name }}_vx_l2.type='bridge'

add firewall rule
set firewall.@rule[-1].name='Allow-VXLAN'
set firewall.@rule[-1].src='up'
set firewall.@rule[-1].proto='udp'
set firewall.@rule[-1].target='ACCEPT'
set firewall.@rule[-1].port={{ interface.tunnel.peer_port }}
