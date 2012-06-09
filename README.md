DESCRIPTION
===========

Cookbook for managing LVM2. Features:

* initialize physical volumes
* create volume groups
* create logical volumes

ATTRIBUTES
==========

`node[:lvm][:on]` is a list, which specifies partitions on which volume groups
and physical volumes must be created.

`node[:logical_volumes]` is a dict of logical volumes properties. See valid
properties in resources/lv.rb.

Example of "lvm" dictionary:

    "lvm" : {
        "on" : ["/dev/sdb"],
        "logical_volumes" : {
            "volume_group_name" : "vg",
            "logical_volume_name" "lv",
            "stripes" : 8,
            "stripe_size" : 256,
            "size" : "10G"
        }
    }


USAGE
=====

Put the values specified in ATTRIBUTES to the node attributes, and add
`recipe[lvm]` to the node run_list.

NOTES
=====

As as side effect, `lvm` cookbook creates these properties for the node:

    node[:lvm][:pv] :: List
    node[:lvm][:vg] :: List
    node[:lvm][:lv] :: List

These properties are essentially outputs of `pvdisplay`, `vgdisplay` and
`lvdisplay`, respectively, for the PVs/VGs/LVs it creates.

TODO
====

Add more flexibility for parameter handling to `pv` and `vg` providers. Now the
only flexible part is `lv`.
